function dataRaw = read_cmv_data(filepath)
%% This function grabs the filepath of the CMV sensor data and ouputs a table version of the data
%   data = output table version of original data
%   filepath = directory of the input file

fd = fopen(filepath, 'rt');

% formatSpec = '%s % * f %f %f'; => doesn't work!!!
% So use the following code to create the same format
%formatSpec = '%s %d %d %d %d %d %d %d %d %d';
%formatSpec = '%s %f %f %f %f %f %f %f %f %f';
formatSpec = '%s % * f %f % * f %f % * f %f % * f %f % * f %f % * f %f % * f %f % * f %f % * f %f';

% Transfer csv file data into dataRaw array
dataRaw = textscan(fd, formatSpec, 'Delimiter', {', ', '\n'}, 'CollectOutput', 1, 'EndOfLine', '\n');
fclose(fd); %close csv file

for i = 1:length(dataRaw{1})
    dateTemp = dataRaw{1, 1}{i, 1};
    dateTemp = dateTemp(1:end);
    dateTemp = strrep(dateTemp, 'T', ' '); %remove T from timestamp
    dataRaw{1, 1}{i, 1} = dateTemp;
end

%data = [dataRaw{:, 1} dataRaw{:, 2}];