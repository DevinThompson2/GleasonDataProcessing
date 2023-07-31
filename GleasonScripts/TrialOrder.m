% Devin  Thompson
% 4/25/2023
% 6/23/3023: % Update to do random orders for each participant, not paired
% Script to generate a random order to do the isometric tests

close all
clear all
clc

%% Main script

% Four isometric tests, two lateral, flexion, extension
% Aiming for 12 participants, will do 20, paired-up

% Since making it unpaired, will do 30, write to the second sheet

% Generate numbers between 1-4, for numParticipants
numParticipants = 30;
numIsometricTests = 4;
for i = 1:numParticipants
    randomArray(i,:) = randperm(numIsometricTests);
end

% Make an array of strings that corresponds to the integer array
% Flexion = 1
% Extension = 2
% Right = 3
% Left = 4
for i = 1:numParticipants
    for j = 1:numIsometricTests
        if randomArray(i,j) == 1
            stringArray(i,j) = "Flexion";
        elseif randomArray(i,j) == 2
            stringArray(i,j) = "Extension";
        elseif randomArray(i,j) == 3
            stringArray(i,j) = "Right Lateral";
        elseif randomArray(i,j) == 4
            stringArray(i,j) = "Left Lateral";
        else
            error("Logic error when making a string array of the isometric contraction order")
        end
    end
end

% Output the string array to an Excel sheet
path = "C:\Users\devin.j.thompson\OneDrive - Washington State University (email.wsu.edu)\Documents\Gleason ALS Project\";
file = "RandomParticipantOrder.xlsx";
pathAndFile = strcat(path,file);
writematrix(stringArray,pathAndFile, 'Sheet','Unpaired');
