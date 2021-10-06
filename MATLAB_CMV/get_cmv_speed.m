function cmvSpeed = get_cmv_speed(cmvDirection, dipLocArr)
% This function receives the CMV direction and calculates the cloud shadow
% speed from the local minima locations
theta = deg2rad(cmvDirection);

dipLocArr(dipLocArr == 0) = NaN;
v = zeros(3, 1);

% fullArr = repelem(nan, 9);
% fullArr(1:length(dipLocArr)) = dipLocArr;
fullArr = dipLocArr;
% Initialize variables
deltaT1 = 0;
deltaT2 = 0;
deltaT3 = 0;
deltaT4 = 0;
deltaT5 = 0;
%CMV_direction = ~45 degrees
if theta >= 0.3926991 && theta < 1.178097
        deltaT1 = fullArr(02) - fullArr(04); %sqrt(2) m
        deltaT2 = fullArr(03) - fullArr(07); %2m
        deltaT3 = fullArr(06) - fullArr(08); %sqrt(2) m
        deltaT4 = fullArr(03) - fullArr(05); %1m
        deltaT5 = fullArr(05) - fullArr(07); %1m
%CMV_direction = ~90 degrees
elseif theta >= 1.178097 && theta < 1.9634954
        deltaT1 = fullArr(01) - fullArr(07); %sqrt(2) m
        deltaT2 = fullArr(02) - fullArr(08); %2m
        deltaT3 = fullArr(03) - fullArr(09); %sqrt(2) m
%CMV_direction = ~135 degrees
elseif theta >= 1.9634954 && theta < 2.7488936
        deltaT1 = fullArr(02) - fullArr(06); %sqrt(2) m
        deltaT2 = fullArr(01) - fullArr(09); %2m
        deltaT3 = fullArr(04) - fullArr(08); %sqrt(2) m
        deltaT4 = fullArr(01) - fullArr(05); %1m
        deltaT5 = fullArr(05) - fullArr(09); %1m
%CMV_direction = ~180 degrees
elseif theta >= 2.7488936 && theta < 3.5342917
        deltaT1 = fullArr(01) - fullArr(03); %sqrt(2) m
        deltaT2 = fullArr(04) - fullArr(06); %2m
        deltaT3 = fullArr(07) - fullArr(09); %sqrt(2) m
%CMV_direction = ~225 degrees
elseif theta >= 3.5342917 && theta < 4.3196899
        deltaT1 = fullArr(04) - fullArr(02); %sqrt(2) m
        deltaT2 = fullArr(07) - fullArr(03); %2m
        deltaT3 = fullArr(08) - fullArr(06); %sqrt(2) m
        deltaT4 = fullArr(07) - fullArr(05); %1m
        deltaT5 = fullArr(05) - fullArr(03); %1m
%CMV_direction = ~270 degrees
elseif theta >= 4.3196899 && theta < 5.1050881
        deltaT1 = fullArr(07) - fullArr(01); %sqrt(2) m
        deltaT2 = fullArr(08) - fullArr(02); %2m
        deltaT3 = fullArr(09) - fullArr(03); %sqrt(2) m
%CMV_direction = ~315 degrees
elseif theta >= 5.1050881 && theta < 5.8904862
        deltaT1 = fullArr(06) - fullArr(02); %sqrt(2) m
        deltaT2 = fullArr(09) - fullArr(01); %2m
        deltaT3 = fullArr(08) - fullArr(04); %sqrt(2) m
        deltaT4 = fullArr(09) - fullArr(05); %1m
        deltaT5 = fullArr(05) - fullArr(01); %1m
%CMV_direction = ~360 degrees
elseif theta >= 5.8904862 && theta < 6.6758844
        deltaT1 = fullArr(03) - fullArr(01); %sqrt(2) m
        deltaT2 = fullArr(06) - fullArr(04); %2m
        deltaT3 = fullArr(09) - fullArr(07); %sqrt(2) m
end

v(1) = abs(sqrt(2) / deltaT1);
v(2) = abs(2 / deltaT2);
v(3) = abs(sqrt(2) / deltaT3);
v(4) = abs(1 / deltaT4);
v(5) = abs(1 / deltaT5);

for id = 1:5
    if isinf(v(id))
        v(id) = nan;
    end
end

cmvSpeed = mean(v, 'omitnan') / 150 * 1000; %meters per second