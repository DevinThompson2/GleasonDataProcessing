% Name: MainProcessing_Imaging
% Authors: Devin Thompson
% Date: 7/11/2023
% Description: Processes the image data to get position of the markers and
% calculate the desired metrics

% Initially write this for one participant, manually edit to switch
% participants. 
% 
% Update to process all participant data at once??????

close all
clear all
clc

%% Load the calibration images
% Edit the participantID and sessionID to adjust which data is being
% processed - The path will likely need to be updated as well
participantID = "T01";
sessionID = "Session1";
currentPath = pwd;
mainFolder = "GleasonDataProcessing";
scriptFolder = "GleasonScripts";
dataFolder = "GleasonData";
% Remove the part after 'GleasonDataProcessing' from the current path
mainPath = extractBefore(currentPath,scriptFolder);
% Set the image location
dataPath = fullfile(mainPath,dataFolder);
imagePath = fullfile(dataPath, participantID, sessionID, "Images");
% Get the directory structure for the images
imagesDirectory = dir(imagePath);
% Get the image names
if size(imagesDirectory) == [0 1] % The path is wrong
    disp("Check to make sure the path is correct: imagePath, participantID, sessionID")
end
imageNames(:,1) = {imagesDirectory(:).name};
% Get only the calibration image indices
calIndices = contains(imageNames,"Cal", "IgnoreCase",true);
% Get the names of the calibration images
calImageNames(:,1) = {imagesDirectory(calIndices).name};
calImageNamesFull = strcat(imagePath,"\", calImageNames);

%% Perform the calibration of the camera to get the camera instrinsics
% Detect calibration pattern in images
detector = vision.calibration.monocular.CheckerboardDetector();
[imagePoints, imagesUsed] = detectPatternPoints(detector, calImageNamesFull);

% Read the first image to obtain image size
originalImage = imread(calImageNamesFull{1});
[mrows, ncols, ~] = size(originalImage);

% Generate world coordinates for the planar pattern keypoints
squareSize = 20;  % in units of 'millimeters'
worldPoints = generateWorldPoints(detector, 'SquareSize', squareSize);

% Calibrate the camera
[cameraParams, imagesUsed, estimationErrors] = estimateCameraParameters(imagePoints, worldPoints, ...
    'EstimateSkew', false, 'EstimateTangentialDistortion', false, ...
    'NumRadialDistortionCoefficients', 2, 'WorldUnits', 'millimeters', ...
    'InitialIntrinsicMatrix', [], 'InitialRadialDistortion', [], ...
    'ImageSize', [mrows, ncols]);

% View reprojection errors
h1=figure; showReprojectionErrors(cameraParams);

% Visualize pattern locations
h2=figure; showExtrinsics(cameraParams, 'CameraCentric');

% Display parameter estimation errors (The camers intrinsics/extrinsics outputs to the command line)
displayErrors(estimationErrors, cameraParams);

% For example, you can use the calibration data to remove effects of lens distortion.
undistortedImage = undistortImage(originalImage, cameraParams);
f =gcf;
figure((f.Number)+1)
image(undistortedImage)
title("Undistorted Image - First Calibration")

%% Load the trial images
% For initial testing, load only one image to calculate the size of the
% marker
testImage = imread(strcat(imagePath, "\","T01-01-06092023-Neutral.jpg"));
figure; imshow(testImage);
title("Input Image");
% Undistort the image
[im, newOrigin] = undistortImage(testImage, cameraParams, OutputView = "full");
figure; imshow(im);
title("Undistorted Image");

%% Compute the camera extrinsics
[imagePoints, boardSize] = detectCheckerboardPoints(im);
imagePoints = imagePoints + newOrigin;
camIntrinsics = cameraParams.Intrinsics;
camExtrinsics = estimateExtrinsics(imagePoints, worldPoints, camIntrinsics);

%% Find the centers of each of the markers, in pixels
% Convert the image to the HSV color space.
imHSV = rgb2hsv(im);
imGray = rgb2gray(im);
imAdjusted = imadjust(imGray);
figure; imshow(imGray);
figure; imshow(imAdjusted);
% Get the saturation channel.
saturation = imHSV(:, :, 2);
% Threshold the image
%t = graythresh(saturation);
% level = graythresh(imGray);
level = 0.982;
imBW = imbinarize(imGray, level);
imBWAdjusted = imbinarize(imAdjusted, level);
%imCoin = (saturation > t);
figure; imshowpair(imGray, imBW, 'montage')
%figure; imshowpair(imGray, imBWAdjusted, 'montage')

%[centers, radii, metrics] = imfindcircles(imBW, [10 50],
%"Method","TwoStage");
[centers, radii, metrics] = imfindcircles(imBW, [8 20],"Sensitivity",0.8);
viscircles(centers, radii)
figure; imshow(imBW); viscircles(centers, radii)
%% Convert the pixel coordinates to global coordinates (in cm?, mm?, need to decide)
% Use the center and radii to calculate two points of each of the circles
circleSides1(:,1) = centers(:,1) - radii;
circleSides1(:,2) = centers(:,2);
circleSides2(:,1) = centers(:,1) + radii;
circleSides2(:,2) = centers(:,2);
% Calculate the world positions of the sides of each circle
worldSides1 = img2world2d(circleSides1, camExtrinsics, camIntrinsics);
worldSides2 = img2world2d(circleSides2, camExtrinsics, camIntrinsics);
% Take the difference to find the diameter
worldDiameter = worldSides1 - worldSides2

% imfindcirlces doesn't get the diameter quite right, use imtool
imtool(im)

%% Convert pixel coordinates to global coordinates
pixelPoints = [point1; point2];
worldPoints = img2world2d(pixelPoints,camExtrinsics,camIntrinsics);
% Compute the distance between them
wordDiameter2 = sqrt((worldPoints(1,1)-worldPoints(2,1)).^2 + (worldPoints(1,2)-worldPoints(2,2)).^2)

pixelPoints = [point11; point21];
worldPoints = img2world2d(pixelPoints,camExtrinsics,camIntrinsics);
% Compute the distance between them
wordDiameter3 = sqrt((worldPoints(1,1)-worldPoints(2,1)).^2 + (worldPoints(1,2)-worldPoints(2,2)).^2)

%% Calculate the variables of interest (distance variables)

%% Load the dynamometry data

%% Calculate the dynamometry metrics

%% Export the desired variables