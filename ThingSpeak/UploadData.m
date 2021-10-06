clc; clear; close all;
filepath = 'C:\Users\dell\Desktop\CMV_Research\MATLAB\MATLAB_scripts\test_data2.csv';
% Read and transfer raw lux data to new array
data_raw = CMV_dataRead_v3(filepath);
data = data_raw{1};
data1 = data(:,1:8);
data2 = data(:,9);
% Generate timestamps for the data
tStamps = datetime('now')-minutes(61):minutes(1):datetime('now');

channelID1 = 1248525; % Change to your Channel ID
writeKey1 = '6AIGW5JBEYYIU83O'; % Change to your Write API Key
channelID2 = 1307045; % Change to your Channel ID
writeKey2 = 'XOOY50H3DDS4XHHA'; % Change to your Write API Key

% Write 10 values to each field of your channel along with timestamps
thingSpeakWrite(channelID1,data1,'TimeStamp',tStamps,'WriteKey',writeKey1)
thingSpeakWrite(channelID2,data2,'TimeStamp',tStamps,'WriteKey',writeKey2)


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