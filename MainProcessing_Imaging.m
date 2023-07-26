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
% Edit the participantID and sessionID to adjust which data is 
participantID = "T01";
sessionID = "Session2";
imagePath = strcat("C:\Users\Devin\OneDrive - Washington State University (email.wsu.edu)\Documents\Gleason ALS Project\GleasonData\", participantID, "\", sessionID, "\Images\");
% Get the directory structure for the images
imagesDirectory = dir(imagePath);
% Get the image names
imageNames(:,1) = {imagesDirectory(:).name};
% Get only the calibration image indices
calIndices = contains(imageNames,"Cal", "IgnoreCase",true);
% Get the names of the calibration images
calImageNames(:,1) = {imagesDirectory(calIndices).name};
calImageNamesFull = strcat(imagePath, calImageNames);

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
testImage = imread(strcat(imagePath,"T01-02-06162023-Flexion1.jpg"));
figure; imshow(testImage);
title("Input Image");
% Undistort the image
[im, newOrigin] = undistortImage(testImage, cameraParams, OutputView = "full");
figure; imshow(im);
title("Undistorted Image");

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

[centers, radii, metrics] = imfindcircles(imBW, [10 50])
viscircles(centers, radii)
figure; imshow(imBW); viscircles(centers, radii)
%% Convert the pixel coordinates to global coordinates (in cm?, mm?, need to decide)

%% Calculate the variables of interest (distance variables)

%% Load the dynamometry data

%% Calculate the dynamometry metrics

%% Export the desired variables