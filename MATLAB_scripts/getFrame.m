function data_sample = getFrame(data,x_start,x_end)
%% This function gets a specified frame from x_start to x_end of the dataset.
data_length = x_end - x_start + 1;
data_sample = zeros(data_length,1,9);
for i = 1:9
    actual_temp = data(x_start:x_end,i);
    data_sample(:,:,i) = actual_temp;
end
data_sample = reshape(data_sample,data_length,9);