function outputArray = get_csd(magnitude, theta, threshold)
%% This function gets the raw magnitude and theta converts to a corrected array
[nRows, nCols, nPages] = size(magnitude);

%% Find average angles
angleArray = zeros(nPages, 1);   %initialize list of angles
for iPage = 1:nPages
    thetaAvg = 0; %initialize variable
    cnt = 0;
    for iRow = 1:nRows
        for iCol = 1:nCols
            if magnitude(iRow, iCol, iPage) > threshold
                thetaAvg = thetaAvg + deg2rad(theta(iRow, iCol, iPage));            %get a running tally of angles
                cnt = cnt + 1;
            end
        end
    end

    thetaAvg = thetaAvg / cnt;                                              %get average angle
    angleArray(iPage, 1) = thetaAvg;
end

%% Find the first non - NaN element's sign
testArray = angleArray;
cnt = 0;
for idx = 1:numel(testArray)
    if ~isnan(testArray(idx))
        cnt = cnt + 1;
        angleArray(cnt, 1) = testArray(idx);
    end
end

%Find starting point
start = 1;
while start < numel(testArray) && isnan(testArray(start))
    start = start + 1;
end

%% Check the quadrants of the first 1 / 4 of the elements
angleLabel = get_quadrant(testArray);

checkArray = cell(numel(angleLabel, 1));
checkArray(1, 1) = angleLabel(start);

[maxRow, ~] = size(angleArray);
maxCheck = start + ceil(maxRow / 8);

cnt = 1;
disp([start maxCheck]);
for idx = start:maxCheck
    if ~isequal(angleLabel(idx), checkArray(cnt)) %check if qudrant is not the same
        cnt = cnt + 1;  %increment
        checkArray(cnt, 1) = angleLabel(idx);  %save new quadrant label to another cell
    end
end

%% Correct angles (in radians) opposite that of reference quadrants
for idx = 1:numel(testArray)
    notequal = 0;

    for idx2 = 1:numel(checkArray)
        if isequal(angleLabel{idx}, checkArray{idx2})
            notequal = notequal + 1;
        end
    end

    if ~notequal
        testArray(idx) = testArray(idx) + pi;
        angleLabel{idx} = get_quadrant(testArray(idx));
    end
end

%% Return output
outputArray = testArray;
end
