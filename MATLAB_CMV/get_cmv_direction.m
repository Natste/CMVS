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