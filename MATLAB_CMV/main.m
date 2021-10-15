clf; close all; clear frames paddedData;

DATA_FILE = '';
OUTPUT_DIR = 'output';
% OUTPUT_DIR = 'output';
MATRIX_TYPE = 'normalized';
THRESHOLD = 0.03;
PEAK_DISTANCE = 50;
PEAK_PROMINENCE = 0.15;%0.016;
PEAK_WIDTH = 15;
SENSOR_ORDER  = [5 4 6 8 7 9 2 1 3]; % Northwest to Southeast
FILL_ORDER  =   [4 1 8 9 6 2 5 3 7]; % N S W E NE SW NW SE O
% SENSOR_ORDER = FILL_ORDER;


figure_setup;
load figure_setup SENSOR_STRINGS FIGURE_STRINGS FMT BIN_EDGES SCALE TILE;

if ~isfile(DATA_FILE)
  DATA_FILE = uigetfile('*.csv;*.txt;*.dat', 'Select Input CSV Data', 'data.csv');
end
if ~isfolder(OUTPUT_DIR)
  OUTPUT_DIR = uigetdir('.', 'Select Output Directory');
end


% Read and transfer raw lux data to new array
data = readmatrix(DATA_FILE);
%%%
% data = data(:, 1:end-1);
% data = data(:, FILL_ORDER);
%%%
nNotNan  = sum(~isnan(data),2);
nSensors = round(mean(nNotNan));
data = data(nNotNan == nSensors, :);
data = rmmissing(data, 2);

iDataStart = 1;
iDataEnd = 61;
iDelta = iDataEnd - iDataStart;
dataWindow = 10; % TODO: figure why this var was referred to as 'window'
filter_window = 11;


if dataWindow > length(data)
    dataWindow = length(data);
    dataWindowWarn = sprintf("dataWindow exceeds length of data and has been trimmed");
else
    dataWindowWarn = sprintf('');
end
if filter_window > length(data)
    filter_window = length(data);
    filterWindowWarn = sprintf("filter_window exceeds length of data and has been trimmed");
else
    filterWindowWarn = sprintf('');
end
if iDataEnd > length(data)
    iDataEnd = length(data);
    iDataStart = max(iDataEnd - iDelta, 1);
    dataEndWarn = sprintf("iDataEnd exceeds length of data. Range parameters have been changed");
else
    dataEndWarn = sprintf('');
end
if ~ismissing([dataWindowWarn, filterWindowWarn, dataEndWarn])
    warning('\n\t%s\n\t%s\n\t%s', dataWindowWarn, filterWindowWarn, dataEndWarn);
end

if nSensors < 9
%   paddedData = padarray(data', 9 - width(data), nan, 'post')';
  paddedData = NaN(length(data), 9);
  if mod(nSensors, 2)
    fillOrder = [FILL_ORDER(1:nSensors) FILL_ORDER(end)];
  else
    fillOrder = FILL_ORDER;
  end
  for iSensor = 1:nSensors
    paddedData(:, fillOrder(iSensor)) = data(:, iSensor);
  end
  % paddedData(:, floor(linspace(1,9,nSensors))) = data;
  data = fillmissing(paddedData, 'movmean', max(9 - nSensors,2), 2, ...
                     EndValues='nearest');
  warning("%d sensors detected. Missing data is being interpolated, and may be inaccurate.", ...
      nSensors);
  nSensors = 9;
end

dataSample =  get_sample_range(data, iDataStart, iDataEnd);
dataSampleNorm =  get_norm(dataSample);
smoothSample = smoothdata(dataSample, 'sgolay', filter_window);
smoothSampleNorm = smoothdata(dataSampleNorm, 'sgolay', filter_window);

plotSets       = {data
                  dataSample
                  smoothSample
                  smoothSampleNorm};

figure(FMT.FIG);
dataPlotFmt.LineWidth = 2;
for iPlotSet = 1:length(plotSets)
  dataPlot = plot(plotSets{iPlotSet});
  for iSensor = 1:nSensors
    dataPlotFmt.DisplayName = SENSOR_STRINGS(iSensor, :);
    set(dataPlot(iSensor), dataPlotFmt);
  end
  legend('show');
  dataAx = gca;
  xlabel('Time Elapsed (milliseconds)');
  ylabel('Irradiance (W/m^2)');
  dataAx.XTickLabel = arrayfun(@(x) sprintf('%d', SCALE * x), dataAx.XTick,...
                               'un', 0);
  set(dataAx, FMT.AX);
  saveas(gca, fullfile(OUTPUT_DIR, FIGURE_STRINGS(iPlotSet, :)), 'fig');
  saveas(gca, fullfile(OUTPUT_DIR, FIGURE_STRINGS(iPlotSet, :)), 'png');
  close
end

%% Find peaks and dips
t = (iDataStart:iDataEnd); %/ Fs
peakArr = zeros(nSensors, 1);
peakLocArr = zeros(nSensors, 1);

dipArr = zeros(nSensors, 1);
dipLocArr = zeros(nSensors, 1);

% Peak and dip parameters
dipFmt.MinPeakDistance = PEAK_DISTANCE;
dipFmt.MinPeakProminence = PEAK_PROMINENCE;
dipFmt.NPeaks = PEAK_WIDTH;

% Plot local maxima and minima
sensorPlot = repelem(0, nSensors);
figure(FMT.FIG);

hold on
for iSensor = 1:nSensors
    sensorInv = 1 ./ smoothSampleNorm(:, iSensor);
    [dip, dipLoc] = findpeaks(sensorInv, dipFmt);

    if isempty(dipLoc)
        dipLocArr(iSensor) = 0;
    else
        dipLocArr(iSensor) = dipLoc;
    end

    sensorPlot(iSensor) = plot(t, smoothSampleNorm(:, iSensor), ...
                               DisplayName='Origin Sensor', LineWidth=2);
    set(sensorPlot(iSensor), dataPlotFmt);
    plot(t(dipLoc), 1 / dip, 'rs', 'MarkerSize', 10);
end
hold off
sensorAx = gca;
set(sensorAx, FMT.AX);
xlabel('Time Elapsed (milliseconds)');
ylabel('Normalized Irradiance');
sensorAx.XTickLabel = arrayfun(@(x) sprintf('%d', SCALE * x), sensorAx.XTick, 'un', 0);
saveas(gca, fullfile(OUTPUT_DIR, 'CMV_Sample_Norm'), 'fig');
saveas(gca, fullfile(OUTPUT_DIR, 'CMV_Sample_Norm'), 'png');

if strcmp(MATRIX_TYPE, 'normalized')
  smoothSampleNorm2 = get_norm(smoothSample); % FIXME: Why is the normalization of smooth sample being defined differently here?
  luxMatrix =  get_matrix(smoothSampleNorm2(:, SENSOR_ORDER), dataWindow);
else
  luxMatrix =  get_matrix(smoothSample(:, SENSOR_ORDER), dataWindow);
end


%% Find cmv direction using Gradient Matrix Method
pages = length(luxMatrix);                                              %find maxnumber of frames
imData =  luxMatrix(:, :, 1:pages);                                            %set dataset to be analyzed
[imageRow, imageCol, ~] = size(imData);
theta = zeros(imageRow, imageCol, pages);
magnitude = zeros(imageRow, imageCol, pages);
theta2 = repelem(0, pages);
frames(pages) = struct('cdata',[],'colormap',[]);
figure(FMT.FIG);
% set(gcf, Visible = false);
progressBar = waitbar(0, '1', Name='Creating Video');
v = VideoWriter(strcat(OUTPUT_DIR, 'GradientMatrix'));
open(v);
for iFrame = 1:(pages)
    waitbar(iFrame/pages, progressBar, sprintf("Frame %6d / %6d", iFrame, pages));
    [gx, gy] = imgradientxy( imData(:, :, iFrame), 'sobel');
    [gmag, gdir] = imgradient(gx, gy);

    theta(:, :, iFrame) = gdir;
    magnitude(:, :, iFrame) = gmag;
    quiver(gx, -gy); %invert to correct visual vector orientation
    frames(cast(iFrame, 'uint16')) = getframe(gcf);
    writeVideo(v, frames(iFrame));
end
 close(v);
 delete(progressBar);
mtd1.shadow = struct;
mtd2.shadow = struct;
mtd1.shadow.ang = get_csd(magnitude, theta, THRESHOLD);                           %correct raw angles
[mtd2.shadow.mag, mtd2.shadow.ang] =  get_resultant_vec(magnitude, theta);
%%
figure(FMT.FIG);
figure_setup; load figure_setup %%%%%%% delete me
  tlo = tiledlayout(TILE.ROWS, TILE.COLS);
  set(tlo,FMT.TLO);
    nexttile(TILE.POS(1), TILE.LARGE_SPAN);
      mtd1.phistBig = polarhistogram(mtd1.shadow.ang, 10);
      hold on;
        mtd2.phistBig = polarhistogram(mtd2.shadow.ang, BIN_EDGES);
      hold off;
      % mtd1.phist.BinCounts = round(rescale(mtd1.phist.BinCounts,0, 100));
      % mtd2.phist.BinCounts = round(rescale(mtd2.phist.BinCounts,0, 100));
      bothMtds.polarAx = gca;
      title(bothMtds.polarAx, 'Shadow Direction');
      legend(bothMtds.polarAx, 'Method One', 'Method Two', Location='southoutside');
      set(bothMtds.polarAx, FMT.POLAX);
    nexttile(TILE.POS(2));
      mtd1.phist = polarhistogram(mtd1.shadow.ang, 10);
      mtd1.polarAx = gca;
      mtd1.phist.FaceColor = FMT.COLORORDER(1,:);
      title(mtd1.polarAx, 'Method One');
      set(mtd1.polarAx, FMT.POLAX);

    nexttile(TILE.POS(3));
      mtd2.phist = polarhistogram(mtd2.shadow.ang, BIN_EDGES);
      mtd2.polarAx = gca;
      mtd2.phist.FaceColor = FMT.COLORORDER(2,:);
      title(mtd2.polarAx, 'Method Two');
      set(mtd2.polarAx, FMT.POLAX);

saveas(gca, fullfile(OUTPUT_DIR, 'cmv_histogram'), 'fig');                          %save figure
saveas(gca, fullfile(OUTPUT_DIR, 'cmv_histogram'), 'png');                          %save image

%% Find the optical flow
% OpF =  get_optical_flow(imData);
%  get_vid(OpF, strcat(OUTPUT_DIR, 'OpticalFlow'));                          %save OpF run as .AVI file

cmvDirection1 = get_cmv_direction(mtd1.shadow.ang, mtd1.phist, 1);
cmvDirection2 = get_cmv_direction(mtd2.shadow.ang, mtd2.phist, 2);
cmvSpeed1     = get_cmv_speed(cmvDirection1, dipLocArr);
cmvSpeed2     = get_cmv_speed(cmvDirection2, dipLocArr);
cmvSpeed1     = fillmissing(cmvSpeed1, "nearest", EndValues='nearest');
cmvSpeed2     = fillmissing(cmvSpeed2, "nearest", EndValues='nearest');
cmv           = [cmvDirection1 cmvDirection2 cmvSpeed1 cmvSpeed2];

fileID = fopen(strcat(OUTPUT_DIR, 'cmv.txt'), 'w');
fprintf(fileID, '%6s %6s %6s %6s\n', 'CMV_Direction1', 'CMV_Direction2', 'CMV_Speed1', 'CMV_Speed2');
fprintf(fileID, '%0.2f %0.2f %0.2f %0.2f\n', cmv);
fclose(fileID);