clc;clear;close all;
filepath = 'C:\Users\dell\Desktop\CMV_Research\MATLAB\MATLAB_scripts\data.csv';     %set folder location to save figures
save_filepath = 'C:\Users\dell\Desktop\CMV_Research\MATLAB\MATLAB_scripts\';

data1 = thingSpeakRead(1248525,'Fields',[1,2,3,4,5,6,7,8],'NumPoints',200,'ReadKey','EQ4MUCOL8YTU4EBS');
data2 = thingSpeakRead(1307045,'Fields',1,'NumPoints',200,'ReadKey','74F6BCQ36JV3K1EF');
data = [data1,data2];

while size(data,1)==200
    data1 = thingSpeakRead(1248525,'Fields',[1,2,3,4,5,6,7,8],'NumPoints',200,'ReadKey','EQ4MUCOL8YTU4EBS');
    data2 = thingSpeakRead(1307045,'Fields',1,'NumPoints',200,'ReadKey','74F6BCQ36JV3K1EF');
    data = [data1,data2];
    data_sample = data;
% Set test parameters
    matrix_type = 'I_norm';
    x_start = 1;
    x_end = 200;
    window = 100;
    filter_window = 51;
    threshold = 0.03;
% Normalize data
    data_sample_norm = getNorm(data_sample);

% Filter and de-noise data
    cmv_sample = smoothdata(data_sample,'sgolay',filter_window);
    cmv_sample_norm = smoothdata(data_sample_norm,'sgolay',filter_window);

% Plot and save datasets
    figure
    plot1 = plot(data);
    ylim([0 inf]);
    set(plot1(2),'DisplayName','South-West','LineWidth',2,'Color','k');
    set(plot1(1),'DisplayName','South','LineWidth',2);
    set(plot1(3),'DisplayName','South-East','LineWidth',2);
    set(plot1(8),'DisplayName','West','LineWidth',2);
    set(plot1(7),'DisplayName','Origin','LineWidth',2);
    set(plot1(9),'DisplayName','East','LineWidth',2);
    set(plot1(5),'DisplayName','North-West','LineWidth',2);
    set(plot1(4),'DisplayName','North','LineWidth',2);
    set(plot1(6),'DisplayName','North-East','LineWidth',2);
    set(gca,'FontSize',15,'fontweight','bold');
    % Enlarge figure to full screen.
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
    xlabel('Time Elapsed (milliseconds)')
    ylabel('Irradiance (W/m^2)')
    % modify labels for tick marks
    xticks = get(gca,'xtick');
    scaling  = 150;
    newlabels = arrayfun(@(x) sprintf('%d', scaling * x), xticks, 'un', 0);
    set(gca,'xticklabel',newlabels);
    legend('show');
    % Save figure and image in folder
    saveas(gca, fullfile(save_filepath,'Dataset'),'fig');
    saveas(gca, fullfile(save_filepath,'Dataset'),'png');
    close

    % Plot framed dataset
    figure
    plot1 = plot(data_sample);
    set(plot1(2),'DisplayName','South-West','Color','k');
    set(plot1(1),'DisplayName','South');
    set(plot1(3),'DisplayName','South-East');
    set(plot1(8),'DisplayName','West');
    set(plot1(7),'DisplayName','Origin');
    set(plot1(9),'DisplayName','East');
    set(plot1(5),'DisplayName','North-West');
    set(plot1(4),'DisplayName','North');
    set(plot1(6),'DisplayName','North-East');
    set(gca,'FontSize',15,'fontweight','bold')
    xlabel('Time Elapsed (milliseconds)')
    ylabel('Irradiance (W/m^2)')

    % Plot smoothed framed dataset
    figure
    plot1 = plot(cmv_sample);
    set(plot1(2),'DisplayName','South-West','LineWidth',2,'Color','k');
    set(plot1(1),'DisplayName','South','LineWidth',2);
    set(plot1(3),'DisplayName','South-East','LineWidth',2);
    set(plot1(8),'DisplayName','West','LineWidth',2);
    set(plot1(7),'DisplayName','Origin','LineWidth',2);
    set(plot1(9),'DisplayName','East','LineWidth',2);
    set(plot1(5),'DisplayName','North-West','LineWidth',2);
    set(plot1(4),'DisplayName','North','LineWidth',2);
    set(plot1(6),'DisplayName','North-East','LineWidth',2);
    set(gca,'FontSize',15,'fontweight','bold')
    xlabel('Time Elapsed (milliseconds)')
    ylabel('Irradiance (W/m^2)')
    legend('show');
    % modify labels for tick marks
    xticks = get(gca,'xtick');
    scaling  = 150;
    newlabels = arrayfun(@(x) sprintf('%d', scaling * x), xticks, 'un', 0);
    set(gca,'xticklabel',newlabels)
    % Save figure and image in folder
    saveas(gca, fullfile(save_filepath,'CMV_Sample'),'fig');
    saveas(gca, fullfile(save_filepath,'CMV_Sample'),'png');
    close

    figure
    plot1 = plot(cmv_sample_norm);
    set(plot1(2),'DisplayName','South-West','LineWidth',2,'Color','k');
    set(plot1(1),'DisplayName','South','LineWidth',2);
    set(plot1(3),'DisplayName','South-East','LineWidth',2);
    set(plot1(8),'DisplayName','West','LineWidth',2);
    set(plot1(7),'DisplayName','Origin','LineWidth',2);
    set(plot1(9),'DisplayName','East','LineWidth',2);
    set(plot1(5),'DisplayName','North-West','LineWidth',2);
    set(plot1(4),'DisplayName','North','LineWidth',2);
    set(plot1(6),'DisplayName','North-East','LineWidth',2);
    set(gca,'FontSize',15,'fontweight','bold')
    xlabel('Time Elapsed (milliseconds)')
    ylabel('Normalized Irradiance')
    legend('show');
    % modify labels for tick marks
    xticks = get(gca,'xtick');
    scaling  = 150;
    newlabels = arrayfun(@(x) sprintf('%d', scaling * x), xticks, 'un', 0);
    set(gca,'xticklabel',newlabels)
    % Save figure and image in folder
    saveas(gca, fullfile(save_filepath,'CMV_Sample_Norm'),'fig');
    saveas(gca, fullfile(save_filepath,'CMV_Sample_Norm'),'png');
    close

% Find peaks and dips
    t = (x_start:x_end); %/ Fs
    peak_arr = zeros(9,1);
    plocation_arr = zeros(9,1);

    dip_arr = zeros(9,1);
    dlocation_arr = zeros(9,1);

    % Peak and dip parameters
    peak_distance = 50;
    peak_prominence = 0.15;%0.016;
    peak_width = 15;

    % Plot local maxima and minima
    figure
    for sensor_idx = 1:9
        %[peak,plocation] = findpeaks(cmv_sample_norm(:,sensor_idx),'MinPeakProminence',peak_prominence,'MinPeakDistance',peak_distance,'MinPeakWidth',peak_width,'NPeaks',1);
        sensor_inv = 1./cmv_sample_norm(:,sensor_idx);
        [dip,dlocation] = findpeaks(sensor_inv,'MinPeakProminence',peak_prominence,'MinPeakDistance',peak_distance,'NPeaks',1);

        if isempty(dlocation)
            dlocation_arr(sensor_idx) = 0;
        else
            dlocation_arr(sensor_idx) = dlocation;
        end

        hold on
        plot2(sensor_idx) = plot(t,cmv_sample_norm(:,sensor_idx),'DisplayName','Origin Sensor','LineWidth',2);
        %plot(t(plocation),peak,'ro','markersize',10);
        plot(t(dlocation),1./dip,'rs','markersize',10);
    end

    hold off
    set(plot2(2),'DisplayName','South-West','LineWidth',2,'Color','k');
    set(plot2(1),'DisplayName','South','LineWidth',2);
    set(plot2(3),'DisplayName','South-East','LineWidth',2);
    set(plot2(8),'DisplayName','West','LineWidth',2);
    set(plot2(7),'DisplayName','Origin','LineWidth',2);
    set(plot2(9),'DisplayName','East','LineWidth',2);
    set(plot2(5),'DisplayName','North-West','LineWidth',2);
    set(plot2(4),'DisplayName','North','LineWidth',2);
    set(plot2(6),'DisplayName','North-East','LineWidth',2);
    set(gca,'FontSize',15,'fontweight','bold')
    xlabel('Time Elapsed (milliseconds)')
    ylabel('Normalized Irradiance')
    % legend('show');
    % Modify labels for tick marks
    xticks = get(gca,'xtick');
    scaling  = 150;
    newlabels = arrayfun(@(x) sprintf('%d', scaling * x), xticks, 'un', 0);
    set(gca,'xticklabel',newlabels)
    % Save figure and image in folder
    saveas(gca, fullfile(save_filepath,'CMV_Sample_Norm'),'fig');
    saveas(gca, fullfile(save_filepath,'CMV_Sample_Norm'),'png');

% Get lux matrix
    luxMatrix = getMatrix(cmv_sample,window,matrix_type);

    % Find CMV direction using Gradient Matrix Method
    [~,~,pages] = size(luxMatrix);                                              %find maxnumber of frames
    imData = luxMatrix(:,:,1:pages);                                            %set dataset to be analyzed
    [image_row, image_col, ~] = size(imData);
    theta = zeros(image_row,image_col,pages);
    magnitude = zeros(image_row,image_col,pages);
    theta2 = zeros(pages,1);
    for idx = 1:(pages-1)
        [Gx, Gy] = imgradientxy(imData(:,:,idx),'sobel');
        [Gmag, Gdir] = imgradient(Gx, Gy);

        theta(:,:,idx) = Gdir;
        magnitude(:,:,idx) = Gmag;
        figure;quiver(Gx,-Gy) %invert to correct visual vector orientation
        GM(idx) = getframe(gcf);
        close
    end

    %getVid(GM,strcat(save_filepath,'GradientMatrix'));                          %save GM run as .AVI file

    % Algorithm 2.1
    angle_rad = getCSD_v2(magnitude,theta,threshold);                           %correct raw angles
    angle_deg = rad2deg(angle_rad);                                             %convert angles to degrees

    % Plot estimated cloud shadow direction
    figure
    hist = polarhistogram(angle_rad,10);
    set(gca,'FontSize',10)
    saveas(gca, fullfile(save_filepath,'GM-1'),'fig');                          %save figure
    saveas(gca, fullfile(save_filepath,'GM-1'),'png');                          %save image

    % Algorithm 2.2
    [M, Phase_rad] = getResultantVector(magnitude,theta);
    Phase_deg = rad2deg(Phase_rad);

    % Plot polar histogram
    figure
    histo = polarhistogram(Phase_rad,[0.3926991 1.178097 1.9634954 2.7488936... %set bin edges
        3.5342917 4.3196899 5.1050881 5.8904862 6.6758844]);
    % histo = polarhistogram(Phase_rad,10);
    set(gca,'FontSize',10)
    saveas(gca, fullfile(save_filepath,'GM-2'),'fig');                          %save figure
    saveas(gca, fullfile(save_filepath,'GM-2'),'png');                          %save image

% Find the optical flow
% OpF = getOpticalFlow(imData); getVid(OpF,strcat(save_filepath,'OpticalFlow')); %save OpF run as .AVI file
% Get CMV final direction and speed
    CMV_Direction1 = getCMV_Direction_v2(angle_rad,hist,1);
    CMV_Direction2 = getCMV_Direction_v2(Phase_rad,histo,2);
    CMV_Speed1 = getCMV_Speed(CMV_Direction1,dlocation_arr);
    CMV_Speed2 = getCMV_Speed(CMV_Direction2,dlocation_arr);
    CMV = [CMV_Direction1 CMV_Direction2 CMV_Speed1 CMV_Speed2]

    % Save CMV array to a text file
    fileID = fopen(strcat(save_filepath,'CMV.txt'),'w');
    fprintf(fileID,'%6s %6s %6s %6s\n','CMV_Direction1','CMV_Direction2','CMV_Speed1','CMV_Speed2');
    fprintf(fileID,'%0.2f %0.2f %0.2f %0.2f\n',CMV);
    fclose(fileID);


end
