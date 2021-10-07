function dataSampleNorm = get_norm(dataSample)
%% This function normalizes data with respect to each column
[nRows, nCols] = size(dataSample);
dataNorm = zeros(nRows, nCols);
for iCol = 1:nCols
    dataNorm(:, iCol) = dataSample(:, iCol) / max(abs(dataSample(:, iCol)));
end
dataSampleNorm = dataNorm;