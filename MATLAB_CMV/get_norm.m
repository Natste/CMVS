function dataSampleNorm = get_norm(dataSample)
%% This function normalizes data with respect to each column
[row, col] = size(dataSample);
dataNorm = zeros(row, col);
for i = 1:col
    dataNorm(:, i) = dataSample(:, i) / max(abs(dataSample(:, i)));
end
dataSampleNorm = dataNorm;