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