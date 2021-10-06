clc;clear;close all;
%%
data1 = thingSpeakRead(1248525,'Fields',[1,2,3,4,5,6,7,8],'NumPoints',62,'ReadKey','EQ4MUCOL8YTU4EBS');
data2 = thingSpeakRead(1307045,'Fields',1,'NumPoints',62,'ReadKey','74F6BCQ36JV3K1EF');
data = [data1,data2];
data_sample = data;
%% Set test parameters
matrix_type = 'I_norm';
x_start = 1;
x_end = 62;
window = 20;
filter_window = 10;
threshold = 0.03;
%% Normalize data
data_sample_norm = getNorm(data_sample);
%% Filter and de-noise data
cmv_sample = smoothdata(data_sample,'sgolay',filter_window);
cmv_sample_norm = smoothdata(data_sample_norm,'sgolay',filter_window);
%% Find peaks and dips
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
for sensor_idx = 1:9
    %[peak,plocation] = findpeaks(cmv_sample_norm(:,sensor_idx),'MinPeakProminence',peak_prominence,'MinPeakDistance',peak_distance,'MinPeakWidth',peak_width,'NPeaks',1);
    sensor_inv = 1./cmv_sample_norm(:,sensor_idx);
    [dip,dlocation] = findpeaks(sensor_inv,'MinPeakProminence',peak_prominence,'MinPeakDistance',peak_distance,'NPeaks',1);
    
    if isempty(dlocation)
        dlocation_arr(sensor_idx) = 0;
    else
        dlocation_arr(sensor_idx) = dlocation;
    end
end
%% Get lux matrix
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
end

%%
% Algorithm 2.1
angle_rad = getCSD_v2(magnitude,theta,threshold);                           %correct raw angles
angle_deg = rad2deg(angle_rad);                                             %convert angles to degrees

% Plot estimated cloud shadow direction
figure
hist = polarhistogram(angle_rad,10);
set(gca,'FontSize',10)

%% Find the optical flow
% OpF = getOpticalFlow(imData); getVid(OpF,strcat(save_filepath,'OpticalFlow'));
% %save OpF run as .AVI file
%% Get CMV final direction and speed

CMV_Direction1 = getCMV_Direction_v2(angle_rad,hist,1);
CMV_Speed1 = getCMV_Speed(CMV_Direction1,dlocation_arr);
CMV = [CMV_Direction1 CMV_Speed1]

%%
function CMV_Direction = getCMV_Direction_v2(angle_rad,hist_plot,algorithm)
%% This function gets the CMV direction using algorithm (1) without 2*pi wraparound or (2) with 2*pi wraparound
[max_row,~] = size(angle_rad);
[~,edge_idx] = max(hist_plot.Values);
edgeValues = hist_plot.BinEdges;
% [~,edge_idx] = max(histo.Values);
% edgeValues = histo.BinEdges;
lower_bound = edgeValues(edge_idx);
upper_bound = edgeValues(edge_idx+1);
direction_temp = zeros(1,1);
cnt = 1;

switch algorithm
    case 1
        % Get final CMV direction if Algorithm 2.1
        for idx = 1:max_row
            if angle_rad(idx) > lower_bound && angle_rad(idx) < upper_bound
                direction_temp(cnt) = angle_rad(idx);
                cnt = cnt + 1;
            end
        end
        
    case 2
        % Get final CMV direction if Algorithm 2.2
        for idx = 1:max_row
            if angle_rad(idx) < 0.3926991
                angle_rad(idx) = angle_rad(idx) + 2 * pi;
            end
            
            if angle_rad(idx) > lower_bound && angle_rad(idx) < upper_bound
                direction_temp(cnt) = angle_rad(idx);
                cnt = cnt + 1;
            end
        end
end

CMV_Direction = rad2deg(mean(direction_temp));
if CMV_Direction < 0
    CMV_Direction = CMV_Direction + 360;
elseif CMV_Direction > 360
    CMV_Direction = CMV_Direction - 360;
end

end

function CMV_Speed = getCMV_Speed(CMV_Direction,dlocation_arr)
% This function receives the CMV direction and calculates the cloud shadow 
% speed from the local minima locations 
theta = deg2rad(CMV_Direction);
dlocation_arr(dlocation_arr==0) = NaN;
v = zeros(3,1);

% Initialize variables
delta_t1 = 0;
delta_t2 = 0;
delta_t3 = 0;
delta_t4 = 0;
delta_t5 = 0;

%CMV_direction = ~45 degrees
if theta >= 0.3926991 && theta < 1.178097
        delta_t1 = dlocation_arr(4) - dlocation_arr(8); %sqrt(2) m
        delta_t2 = dlocation_arr(6) - dlocation_arr(2); %2m
        delta_t3 = dlocation_arr(9) - dlocation_arr(1); %sqrt(2) m
        delta_t4 = dlocation_arr(6) - dlocation_arr(7); %1m
        delta_t5 = dlocation_arr(7) - dlocation_arr(2); %1m
        choice = 45
%CMV_direction = ~90 degrees
elseif theta >= 1.178097 && theta < 1.9634954     
        delta_t1 = dlocation_arr(5) - dlocation_arr(2); %sqrt(2) m
        delta_t2 = dlocation_arr(4) - dlocation_arr(1); %2m
        delta_t3 = dlocation_arr(6) - dlocation_arr(3); %sqrt(2) m
        choice = 90
%CMV_direction = ~135 degrees
elseif theta >= 1.9634954 && theta < 2.7488936
        delta_t1 = dlocation_arr(4) - dlocation_arr(9); %sqrt(2) m
        delta_t2 = dlocation_arr(5) - dlocation_arr(3); %2m
        delta_t3 = dlocation_arr(8) - dlocation_arr(1); %sqrt(2) m
        delta_t4 = dlocation_arr(5) - dlocation_arr(7); %1m
        delta_t5 = dlocation_arr(7) - dlocation_arr(3); %1m        
        choice = 135
%CMV_direction = ~180 degrees
elseif theta >= 2.7488936 && theta < 3.5342917
        delta_t1 = dlocation_arr(5) - dlocation_arr(6); %sqrt(2) m
        delta_t2 = dlocation_arr(8) - dlocation_arr(9); %2m
        delta_t3 = dlocation_arr(2) - dlocation_arr(3); %sqrt(2) m
        choice = 180
%CMV_direction = ~225 degrees
elseif theta >= 3.5342917 && theta < 4.3196899
        delta_t1 = dlocation_arr(8) - dlocation_arr(4); %sqrt(2) m
        delta_t2 = dlocation_arr(2) - dlocation_arr(6); %2m
        delta_t3 = dlocation_arr(1) - dlocation_arr(9); %sqrt(2) m
        delta_t4 = dlocation_arr(2) - dlocation_arr(7); %1m
        delta_t5 = dlocation_arr(7) - dlocation_arr(6); %1m
        choice = 225
%CMV_direction = ~270 degrees
elseif theta >= 4.3196899 && theta < 5.1050881
        delta_t1 = dlocation_arr(2) - dlocation_arr(5); %sqrt(2) m
        delta_t2 = dlocation_arr(1) - dlocation_arr(4); %2m
        delta_t3 = dlocation_arr(3) - dlocation_arr(6); %sqrt(2) m
        choice = 270
%CMV_direction = ~315 degrees
elseif theta >= 5.1050881 && theta < 5.8904862 
        delta_t1 = dlocation_arr(9) - dlocation_arr(4); %sqrt(2) m
        delta_t2 = dlocation_arr(3) - dlocation_arr(5); %2m
        delta_t3 = dlocation_arr(1) - dlocation_arr(8); %sqrt(2) m
        delta_t4 = dlocation_arr(3) - dlocation_arr(7); %1m
        delta_t5 = dlocation_arr(7) - dlocation_arr(5); %1m        
        choice = 315
%CMV_direction = ~360 degrees
elseif theta >= 5.8904862 && theta < 6.6758844
        delta_t1 = dlocation_arr(6) - dlocation_arr(5); %sqrt(2) m
        delta_t2 = dlocation_arr(9) - dlocation_arr(8); %2m
        delta_t3 = dlocation_arr(3) - dlocation_arr(2); %sqrt(2) m
        choice = 360
end
    
v(1) = abs(sqrt(2)/delta_t1);
v(2) = abs(2/delta_t2);
v(3) = abs(sqrt(2)/delta_t3);
v(4) = abs(1/delta_t4);
v(5) = abs(1/delta_t5);

for idx = 1:5 
    if isinf(v(idx)) == 1
        v(idx) = nan;
    end
end

CMV_Speed = nanmean(v)/150*1000; %meters per second
end

function outputArray = getCSD_v2(magnitude,theta,threshold)

%% This function gets the raw magnitude and theta converts to a corrected array
[~,~,pages] = size(magnitude);

%% Find average angles
angle_array = zeros(pages,1);   %initialize list of angles
for idx = 1:pages
    theta_avg = 0; %initialize variable
    cnt = 0;
    for i = 1:3
        for j = 1:3
            if magnitude(i,j,idx) > threshold                              
                theta_avg = theta_avg + deg2rad(theta(i,j,idx));            %get a running tally of angles
                cnt = cnt + 1;
            end
        end
    end
    
    theta_avg = theta_avg/cnt;                                              %get average angle
    angle_array(idx,1) = theta_avg;
end

%% Find the first non-NaN element's sign 
test_array = angle_array;
cnt = 0;
for idx = 1:numel(test_array)
    if isnan(test_array(idx)) ~= 1
        cnt = cnt + 1;
        angle_array(cnt,1) = test_array(idx);       
    end
end

%Find starting point
start = 1;
while start < numel(test_array) && isnan(test_array(start)) ~= 0
    start = start + 1;      
end

%% Check the quadrants of the first 1/4 of the elements
angle_label = getQUADRANT(test_array);

check_array = cell(numel(angle_label,1));
check_array(1,1) = angle_label(start);

[max_row,~] = size(angle_array);
max_check = start + ceil(max_row/8);

cnt = 1;
for idx = start:max_check
    if isequal(angle_label(idx),check_array(cnt)) == 0 %check if qudrant is not the same
        cnt = cnt + 1;  %increment
        check_array(cnt,1) = angle_label(idx);  %save new quadrant label to another cell
    end
end

%% Correct angles (in radians) opposite that of reference quadrants
for idx = 1:numel(test_array) 
    notequal = 0;
    
    for idx2 = 1:numel(check_array)
        if isequal(angle_label{idx},check_array{idx2}) == 1
            notequal = notequal + 1;
        end       
    end
    
    if notequal == 0
        test_array(idx) = test_array(idx) + pi;
        angle_label{idx} = getQUADRANT(test_array(idx));
    end
end   

%% Return output
outputArray = test_array;
end

function data_sample = getFrame(data,x_start,x_end)
%% This function gets a specified frame from x_start to x_end of the dataset.
data_length = x_end - x_start + 1;
data_sample = zeros(data_length,1,9);
for i = 1:9
    actual_temp = data(x_start:x_end,i);
    data_sample(:,:,i) = actual_temp;
end
data_sample = reshape(data_sample,data_length,9);
end

function outputArray = getMatrix(cmv_sample,window,matrix_type)
%% This function maps lux data into a selected matrix type
[data_length,~] = size(cmv_sample);
cmv_sample_norm = getNorm(cmv_sample);
pages = data_length - window + 1

% Get raw pixels
I_raw = zeros(3,3,pages);
for j = 1:data_length
    I_temp = [cmv_sample(j,5) cmv_sample(j,4) cmv_sample(j,6);
              cmv_sample(j,8) cmv_sample(j,7) cmv_sample(j,9);
              cmv_sample(j,2) cmv_sample(j,1) cmv_sample(j,3)];
    
    I_raw(:,:,j) = I_temp;
end

% Get pixels
switch matrix_type
    case 'I'
        I = zeros(3,3,pages);
        for j = 1:pages
            for k = 1:window
                I_temp = [cmv_sample(j-1+k,5) cmv_sample(j-1+k,4) cmv_sample(j-1+k,6);
                    cmv_sample(j-1+k,8) cmv_sample(j-1+k,7) cmv_sample(j-1+k,9);
                    cmv_sample(j-1+k,2) cmv_sample(j-1+k,1) cmv_sample(j-1+k,3)];
                
                I(:,:,j) = I(:,:,j) + I_temp;
            end
            I(:,:,j) = I(:,:,j)/window;
        end
        outputArray = I;
        
    case 'I_norm'
        % Get normalized pixels
        I_norm = zeros(3,3,pages);
        for j = 1:pages
            for k = 1:window
                I_temp = [cmv_sample_norm(j-1+k,5) cmv_sample_norm(j-1+k,4) cmv_sample_norm(j-1+k,6);
                    cmv_sample_norm(j-1+k,8) cmv_sample_norm(j-1+k,7) cmv_sample_norm(j-1+k,9);
                    cmv_sample_norm(j-1+k,2) cmv_sample_norm(j-1+k,1) cmv_sample_norm(j-1+k,3)];
                
                I_norm(:,:,j) = I_norm(:,:,j) + I_temp;
            end
            I_norm(:,:,j) = I_norm(:,:,j)/window;
        end
        outputArray = I_norm;
        
    case 'I_norm_v2'
        I_norm_v2 = zeros(3,3,pages);
        for j = 1:pages
            for k = 1:window
                I_temp = [cmv_sample_norm(j-1+k,7) cmv_sample_norm(j-1+k,8) cmv_sample_norm(j-1+k,9);
                    cmv_sample_norm(j-1+k,4) cmv_sample_norm(j-1+k,5) cmv_sample_norm(j-1+k,6);
                    cmv_sample_norm(j-1+k,1) cmv_sample_norm(j-1+k,2) cmv_sample_norm(j-1+k,3)];
                
                I_norm_v2(:,:,j) = I_norm_v2(:,:,j) + I_temp;
            end
            I_norm_v2(:,:,j) = I_norm_v2(:,:,j)/window;
        end
        outputArray = I_norm_v2;
        
    case 'I_ave_norm'
        I_ave_norm = zeros(3,3,pages);
        idx = 1;
        for j = 1:data_length
            I_temp = [cmv_sample_norm(j,5) cmv_sample_norm(j,4) cmv_sample_norm(j,6);
                cmv_sample_norm(j,8) cmv_sample_norm(j,7) cmv_sample_norm(j,9);
                cmv_sample_norm(j,2) cmv_sample_norm(j,1) cmv_sample_norm(j,3)];
            
            I_ave_norm(:,:,idx) = I_ave_norm(:,:,idx) + I_temp;
            if mod(j,window) == 0
                I_ave_norm(:,:,idx) = I_ave_norm(:,:,idx)/window;
                idx = idx + 1;
            end
        end
        outputArray = I_ave_norm;
        
    otherwise
        fprintf('ERROR')
end

end

function data_sample_norm = getNorm(data_sample)
%% This function normalizes data with respect to each column
[row,col] = size(data_sample); 
data_norm = zeros(row,col);
for i = 1:col
    data_norm(:,i) = data_sample(:,i)/max(abs(data_sample(:,i)));
end
data_sample_norm = data_norm;
end

function angle_label = getQUADRANT(array)

angle_label = cell(1);

for idx = 1:numel(array) 
    if array(idx)>=0 && array(idx) < pi/2
        angle_label(idx, 1) = {'Quadrant1'};
    elseif array(idx)>=pi/2 && array(idx) < pi 
        angle_label(idx, 1) = {'Quadrant2'};
    elseif array(idx)>=pi && array(idx) < 3*pi/2 
        angle_label(idx, 1) = {'Quadrant3'};    
    elseif array(idx)>=3*pi/2 && array(idx) < 2*pi 
        angle_label(idx, 1) = {'Quadrant4'};
    else
        angle_label(idx, 1) = {NaN};
    end
end

end

function [M, Phase] = getResultantVector(magnitude,theta)
% This function converts the magnitudes and angles into a phasor. The
% resultant vector's is then decomposed as magnitude, M, and angle, Phase.

z_total = 0;
threshold = 0.02;
[~,~,pages] = size(magnitude);
M = zeros(pages,1);
Phase = zeros(pages,1);

for idx = 1:(pages-1)
    for i = 1:3
        for j = 1:3
            R = magnitude(i,j,idx);
            rtheta = deg2rad(theta(i,j,idx));
            
            if R > threshold                       
                z = R*(cos(rtheta)+1i*sin(rtheta));                         %convert into complex form
                z_total = z_total + z;                                      %add complex numbers
            end
        end
    end
    
    M(idx) = abs(z_total);
    Phase(idx) = angle(z_total);
end
end

function getVid(inputStruct,filename)
%% Turn images in struct into an avi file
v = VideoWriter(filename);
open(v);

for k = 1:length(inputStruct)
   frame = inputStruct(:,k);
   writeVideo(v,frame);
end

close(v);
end