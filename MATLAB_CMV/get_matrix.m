function outputMatrix = get_matrix(inputArray, dataWindow)
  %% This function maps lux data into a matrix
  SENSOR_ORDER  = [5 4 6 8 7 9 2 1 3];

  sensorArray = inputArray(:, SENSOR_ORDER);
  sensorArrayMsum = movsum(sensorArray, dataWindow, 1, Endpoints='discard'); % TODO: Figure out why a moving sum is being applied

  nSensors = width(sensorArray);
  matSize = sqrt(nSensors); %TODO: Replace with more general definition
  outputMatrix = reshape(sensorArrayMsum', matSize, matSize, []);
  outputMatrix = permute(outputMatrix,  [2, 1, 3]);
  outputMatrix = outputMatrix / dataWindow;
end