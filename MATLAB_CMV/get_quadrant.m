function angleLabel = get_quadrant(array)
  angleLabel = cell(1);
  for idx = 1:numel(array)
    if array(idx)>=0 && array(idx) < pi/2
      angleLabel(idx, 1) = {'Quadrant1'};
    elseif array(idx)>=pi/2 && array(idx) < pi
      angleLabel(idx, 1) = {'Quadrant2'};
    elseif array(idx)>=pi && array(idx) < 3*pi/2
      angleLabel(idx, 1) = {'Quadrant3'};
    elseif array(idx)>=3*pi/2 && array(idx) < 2*pi
      angleLabel(idx, 1) = {'Quadrant4'};
    else 
      angleLabel(idx, 1) = {NaN};
    end
  end
end