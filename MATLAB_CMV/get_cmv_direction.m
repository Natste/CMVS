function cmvDirection = get_cmv_direction(angleRad, histPlot, algorithm)
%% This function gets the CMV direction using algorithm
% (1) without 2 * pi wraparound or
% (2) with 2 * pi wraparound
[max_row, ~] = size(angleRad);
[~, edge_idx] = max(histPlot.Values);
edgeVals = histPlot.BinEdges;
% [~, edge_idx] = max(histo.Values);
% edgeVals = histo.BinEdges;
lowerBound = edgeVals(edge_idx);
upperBound = edgeVals(edge_idx + 1);
directionTemp = zeros(1, 1);
cnt = 1;

switch algorithm
    case 1
        % Get final CMV direction if Algorithm 2.1
        for id = 1:max_row
            if angleRad(id) > lowerBound && angleRad(id) < upperBound
                directionTemp(cnt) = angleRad(id);
                cnt = cnt + 1;
            end
        end

    case 2
        % Get final CMV direction if Algorithm 2.2
        for id = 1:max_row
            if angleRad(id) < 0.3926991
                angleRad(id) = angleRad(id) + 2 * pi;
            end

            if angleRad(id) > lowerBound && angleRad(id) < upperBound
                directionTemp(cnt) = angleRad(id);
                cnt = cnt + 1;
            end
        end
end

cmvDirection = rad2deg(mean(directionTemp));
if cmvDirection < 0
    cmvDirection = cmvDirection + 360;
elseif cmvDirection > 360
    cmvDirection = cmvDirection - 360;
end

end