function data_raw = CMV_dataRead_v3(filepath)
%% This function grabs the filepath of the CMV sensor data and ouputs a table version of the data
%   data = output table version of original data
%   filepath = directory of the input file

fd = fopen(filepath, 'rt');

% formatSpec = '%s %*f %f %f'; => doesn't work!!!
% So use the following code to create the same format
%formatSpec = '%s %d %d %d %d %d %d %d %d %d'; 
%formatSpec = '%s %f %f %f %f %f %f %f %f %f'; 
formatSpec = '%f %f %f %f %f %f %f %f %f';

% Transfer csv file data into data_raw array
data_raw = textscan(fd, formatSpec, 'Delimiter',{',','\n'}, 'CollectOutput', 1, 'EndOfLine', '\n');
fclose(fd); %close csv file
end

% for i = 1:length(data_raw{1})
%     date_temp = data_raw{1,1}{i,1};
%     date_temp = date_temp(1:end);
%     date_temp = strrep(date_temp,'T',' '); %remove T from timestamp
%     data_raw{1,1}{i,1} = date_temp;    
% end

%data = [data_raw{:,1} data_raw{:,2}];