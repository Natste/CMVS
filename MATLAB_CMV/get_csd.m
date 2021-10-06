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
