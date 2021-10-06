function dataSampleRange = get_sample_range(data, dataStart, dataEnd)
%% This function gets a specified frame from x_start to x_end of the dataset.
nSamples = dataEnd - dataStart + 1;
nSensors = width(data);
dataSampleRange = zeros(nSamples, nSensors);
for i = 1:nSensors
%     actual_temp = data(x_start:x_end, i);
    dataSampleRange(:, i) = data(dataStart:dataEnd, i);
end
% data_sample = reshape(data_sample, num_samples, num_sensors);