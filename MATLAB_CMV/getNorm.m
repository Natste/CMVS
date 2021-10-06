function data_sample_norm = getNorm(data_sample)
%% This function normalizes data with respect to each column
[row,col] = size(data_sample); 
data_norm = zeros(row,col);
for i = 1:col
    data_norm(:,i) = data_sample(:,i)/max(abs(data_sample(:,i)));
end
data_sample_norm = data_norm;
end