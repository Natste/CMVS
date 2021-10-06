clf; close all; clear frames;
%% Load CSV files
dataFile = 'data3.csv';
outputDir = 'output';

if ~exist(dataFile, 'file')
  dataFile = uigetfile('*.csv;*.txt;*.dat', 'Select Input CSV Data', 'data.csv');
end
if ~exist(outputDir, 'dir')
  outputDir = uigetdir('.', 'Select Output Directory');
end
if isempty([dataFile, outputDir])
    exit
end

% Read and transfer raw lux data to new array
data = readmatrix(dataFile);
nNotNan  = sum(~isnan(data),2);
nSensors = round(mean(nNotNan));
data = data(nNotNan == nSensors, :);
data = rmmissing(data, 2);
%% Set test parameters
matrixType = 'iNorm';
iDataStart = 1;
iDataEnd = 200;
iDelta = iDataEnd - iDataStart;

if iDataEnd > length(data(:))
  iDataEnd = length(data(:));
  iDataStart = max(iDataEnd - iDelta, 0);
  warning("Test parameters out of range. Start and end index have been changed to fit input data");
end

dataWindow = 200; % TODO: figure why this var was referred to as 'window'
filterWindowLength = 51;
threshold = 0.03;

%% Get framed dataset
dataSample =  get_sample_range(data, iDataStart, iDataEnd);

%% Normalize data
dataSamplenorm =  get_norm(dataSample);

%% Filter and de - noise data
cmvSample = smoothdata(dataSample, 'sgolay', filterWindowLength);
cmvSamplenorm = smoothdata(dataSamplenorm, 'sgolay', filterWindowLength);

%% Plot and save datasets
axFmt.FontSize = 15;
axFmt.FontWeight = 'bold';
axFmt.YLim = [0 inf];
figFmt.Units = 'Normalized';
figFmt.Visible = false;
figFmt.OuterPosition = [0, 0.04, 0.25, 0.25];

compassStrings = {'NW' 'N' 'NE'
                   'W' 'C'  'E'
                  'SW' 'S' 'SE'};
figure(figFmt);
plotSets = {dataSample
            dataSamplenorm
            cmvSample
            cmvSamplenorm};

dataPlotFmt.LineWidth = 2;
for iPlotSet = 1:length(plotSets)
  dataPlot = plot(plotSets{iPlotSet});
  for iSensor = 1:nSensors
    dataPlotFmt.DisplayName = compassStrings{iSensor};
    set(dataPlot(iSensor), dataPlotFmt);
  end
  % modify labels for tick marks
  legend('show');
  dataAx = gca;
  dataAx.XLabel.String = 'Time Elapsed (milliseconds)';
  dataAx.YLabel.String = 'Illuminance (lux)';
  dataAx.XTickLabel = arrayfun(@(x) sprintf('%d', 150 * x), dataAx.XTick, 'un', 0);
  set(dataAx, axFmt);
  % Save figure and image in folder
  saveas(gca, fullfile(outputDir, 'Dataset'), 'fig');
  saveas(gca, fullfile(outputDir, 'Dataset'), 'png');
  close
end

%% Find peaks and dips
t = (iDataStart:iDataEnd); %/ Fs
peakArr = zeros(nSensors, 1);
peakLocArr = zeros(nSensors, 1);

dipArr = zeros(nSensors, 1);
dipLocArr = zeros(nSensors, 1);

% Peak and dip parameters
dipFmt.MinPeakDistance = 50;
dipFmt.MinPeakProminence = 0.15;
dipFmt.NPeaks = 1;

% Plot local maxima and minima
sensorPlot = repelem(0, nSensors);
figure(figFmt);

hold on
for iSensor = 1:nSensors
    sensorInv = 1 ./ cmvSamplenorm(:, iSensor);
    [dip, dipLoc] = findpeaks(sensorInv, dipFmt);

    if isempty(dipLoc)
        dipLocArr(iSensor) = 0;
    else
        dipLocArr(iSensor) = dipLoc;
    end

    sensorPlot(iSensor) = plot(t, cmvSamplenorm(:, iSensor), 'DisplayName', 'Origin Sensor', 'LineWidth', 2);
    set(sensorPlot(iSensor), dataPlotFmt);
    plot(t(dipLoc), 1 / dip, 'rs', 'MarkerSize', 10);
end
hold off
sensorAx = gca;
set(sensorAx, axFmt);
sensorAx.XLabel.String = 'Time Elapsed (milliseconds)';
sensorAx.YLabel.String = 'Normalized Illuminance';
sensorAx.XTickLabel = arrayfun(@(x) sprintf('%d', 150 * x), sensorAx.XTick, 'un', 0);
saveas(gca, fullfile(outputDir, 'CMV_Sample_Norm'), 'fig');
saveas(gca, fullfile(outputDir, 'CMV_Sample_Norm'), 'png');

%% Get lux matrix
luxMatrix =  get_matrix(cmvSample, dataWindow, matrixType);
fillmissing(luxMatrix, 'makima');

%% Find cmv direction using Gradient Matrix Method
pages = length(luxMatrix);                                              %find maxnumber of frames
imData =  luxMatrix(:, :, 1:pages);                                            %set dataset to be analyzed
[imageRow, imageCol, ~] = size(imData);
theta = zeros(imageRow, imageCol, pages);
magnitude = zeros(imageRow, imageCol, pages);
theta2 = repelem(0, pages);
frames(pages) = struct('cdata',[],'colormap',[]);
figure(figFmt);
set(gcf, Visible = false);
progressBar = waitbar(0, '1', Name='Creating Video');
v = VideoWriter(strcat(outputDir, 'GradientMatrix'));
open(v);
for iFrame = 1:(pages - 1)
    waitbar(iFrame/dataWindow, progressBar, sprintf("Frame %6d / %6d", iFrame, pages - 1));
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

% Algorithm 2.1
angleRad = get_csd(magnitude, theta, threshold);                           %correct raw angles
angleDeg = rad2deg(angleRad);                                             %convert angles to degrees

% Plot estimated cloud shadow direction
figure(figFmt);
hist = polarhistogram(angleRad, 10);
set(gca, 'FontSize', 10)
saveas(gca, fullfile(outputDir, 'frame - 1'), 'fig');                          %save figure
saveas(gca, fullfile(outputDir, 'frame - 1'), 'png');                          %save image

% Algorithm 2.2
[M, phaseRad] =  get_resultant_vec(magnitude, theta);
phaseDeg = rad2deg(phaseRad);

% Plot polar histogram
figure(figFmt);
histo = polarhistogram(phaseRad, [0.3926991 1.178097 1.9634954 2.7488936... %set bin edges
                       3.5342917 4.3196899 5.1050881 5.8904862 6.6758844]);
% histo = polarhistogram(phaseRad, 10);
set(gca, 'FontSize', 10)
saveas(gca, fullfile(outputDir, 'frame - 2'), 'fig');                          %save figure
saveas(gca, fullfile(outputDir, 'frame - 2'), 'png');                          %save image

%% Find the optical flow
% OpF =  get_optical_flow(imData);
%  get_vid(OpF, strcat(outputDir, 'OpticalFlow'));                          %save OpF run as .AVI file

%% Get cmv final direction and speed
cmvDirection1 = get_cmv_direction(angleRad, hist, 1);
cmvDirection2 = get_cmv_direction(phaseRad, histo, 2);
cmvSpeed1 = get_cmv_speed(cmvDirection1, dipLocArr);
cmvSpeed2 = get_cmv_speed(cmvDirection2, dipLocArr);
cmvSpeed1 = fillmissing(cmvSpeed1, "nearest", EndValues='nearest');
cmvSpeed2 = fillmissing(cmvSpeed2, "nearest", EndValues='nearest');
cmv = [cmvDirection1 cmvDirection2 cmvSpeed1 cmvSpeed2];

% Save cmv array to a text file
fileID = fopen(strcat(outputDir, 'cmv.txt'), 'w');
fprintf(fileID, '%6s %6s %6s %6s\n', 'CMV_Direction1', 'CMV_Direction2', 'CMV_Speed1', 'CMV_Speed2');
fprintf(fileID, '%0.2f %0.2f %0.2f %0.2f\n', cmv);
fclose(fileID);
%([A - Z])([A - Z] + )_([A - Z])?([A - Za - z0 - 9] * )_?(? = \()
%\ (\S * ?)
%\([a - z][a - z0 - 9] * )([A - Z][a - z0 - 9] * )([A - Z][a - z0 - 9] * )?(? = \()



%[A - Z]([A - Z0 - 9] * [a - z][a - z0 - 9] * [A - Z]|[a - z0 - 9] * [A - Z][A - Z0 - 9] * [a - z])[A - Za - z0 - 9]*