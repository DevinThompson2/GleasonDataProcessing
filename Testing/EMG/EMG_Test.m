% Devin  Thompson
% 3/7/2023
% Test script for loading in EMG data to examine

clear all
close all
clc

% Load the data
path = "C:\Users\devin.j.thompson\Documents\EMGTesting\";
file = "MVCMuscleNTest1.xlsx";
pathAndFile = strcat(path, file);
data = readtable(pathAndFile);

figure(1)
plot(data.(data.Properties.VariableNames{1}), data.(data.Properties.VariableNames{2}))
xlabel("Time (s)")
ylabel("EMG RMS (% MVC)")
xlim([0 10])
ylim([1 100])