function outputMatrix = get_matrix(orderedArray, dataWindow)
  %% This function maps lux data into a matrix
  orderedArrayMsum = movsum(orderedArray, dataWindow, 1, Endpoints='discard'); % TODO: Figure out why a moving sum is being applied
  matSize = sqrt(width(orderedArrayMsum)); %TODO: Replace with more general definition
  outputMatrix = reshape(orderedArrayMsum', matSize, matSize, []);
  outputMatrix = permute(outputMatrix,  [2, 1, 3]);
  outputMatrix = outputMatrix / dataWindow;
end