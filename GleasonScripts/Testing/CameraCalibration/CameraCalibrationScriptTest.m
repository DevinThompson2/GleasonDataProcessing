% Devin Thompson
% 5/2/2023
close all
clear all
clc
% Auto-generated by cameraCalibrator app on 02-May-2023
%-------------------------------------------------------


% Define images to process
imageFileNames = {'C:\Users\devin.j.thompson\OneDrive - Washington State University (email.wsu.edu)\Documents\Gleason ALS Project\MATLAB\CalibrationPhotosTest\CalTest1.jpg',...
    'C:\Users\devin.j.thompson\OneDrive - Washington State University (email.wsu.edu)\Documents\Gleason ALS Project\MATLAB\CalibrationPhotosTest\CalTest2.jpg',...
    'C:\Users\devin.j.thompson\OneDrive - Washington State University (email.wsu.edu)\Documents\Gleason ALS Project\MATLAB\CalibrationPhotosTest\CalTest3.jpg',...
    'C:\Users\devin.j.thompson\OneDrive - Washington State University (email.wsu.edu)\Documents\Gleason ALS Project\MATLAB\CalibrationPhotosTest\CalTest4.jpg',...
    'C:\Users\devin.j.thompson\OneDrive - Washington State University (email.wsu.edu)\Documents\Gleason ALS Project\MATLAB\CalibrationPhotosTest\CalTest5.jpg',...
    'C:\Users\devin.j.thompson\OneDrive - Washington State University (email.wsu.edu)\Documents\Gleason ALS Project\MATLAB\CalibrationPhotosTest\CalTest6.jpg',...
    'C:\Users\devin.j.thompson\OneDrive - Washington State University (email.wsu.edu)\Documents\Gleason ALS Project\MATLAB\CalibrationPhotosTest\CalTest7.jpg',...
    'C:\Users\devin.j.thompson\OneDrive - Washington State University (email.wsu.edu)\Documents\Gleason ALS Project\MATLAB\CalibrationPhotosTest\CalTest8.jpg',...
    'C:\Users\devin.j.thompson\OneDrive - Washington State University (email.wsu.edu)\Documents\Gleason ALS Project\MATLAB\CalibrationPhotosTest\CalTest9.jpg',...
    'C:\Users\devin.j.thompson\OneDrive - Washington State University (email.wsu.edu)\Documents\Gleason ALS Project\MATLAB\CalibrationPhotosTest\CalTest10.jpg',...
    'C:\Users\devin.j.thompson\OneDrive - Washington State University (email.wsu.edu)\Documents\Gleason ALS Project\MATLAB\CalibrationPhotosTest\CalTest11.jpg',...
    };
% Detect calibration pattern in images
detector = vision.calibration.monocular.CheckerboardDetector();
[imagePoints, imagesUsed] = detectPatternPoints(detector, imageFileNames);
imageFileNames = imageFileNames(imagesUsed);

% Read the first image to obtain image size
originalImage = imread(imageFileNames{1});
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

% See additional examples of how to use the calibration data.  At the prompt type:
showdemo('MeasuringPlanarObjectsExample')
% showdemo('StructureFromMotionExample')

%% From here on is my code to calculate sizes of objects in the images (markers)
% Read the test image in
path = "C:\Users\devin.j.thompson\OneDrive - Washington State University (email.wsu.edu)\Documents\Gleason ALS Project\MATLAB\CalibrationPhotosTest\";
file = "CalTest_MarkerSize4.jpg";
pathAndFile = strcat(path,file);
inputImage = imread(pathAndFile);

% Undistort the test image 
[inputImageUndistorted, newOrigin] = undistortImage(inputImage, cameraParams, OutputView = "full");

% Display the test image and undistorted image in the same figure
f = gcf;
figure((f.Number)+1);
t = tiledlayout(2,1);
% Bottom plot
ax1 = nexttile;
imshow(inputImage, 'InitialMagnification','fit')
title(ax1,'Original')
%subtitle(ax1, 'Original')
% Right plot
ax2 = nexttile;
imshow(inputImageUndistorted, 'InitialMagnification','fit')
title(ax2,'Undistorted')
%subtitle(ax2,'Test')
%f.WindowState = "maximized";

% Process the image to get only the markers
% Convert the image to the HSV color space.
imHSV = rgb2hsv(inputImageUndistorted);
imGray = rgb2gray(inputImageUndistorted);
f = gcf;
figure((f.Number)+1); imshow(imGray);
title("Gray");
f = gcf;
figure((f.Number)+1); imshow(imHSV);
title("HSV");
% % Get the saturation channel.
% saturation = imHSV(:, :, 2);
% % Threshold the image
% t = graythresh(saturation);
% imMarkers = (saturation > t);
% f = gcf;
% figure((f.Number)+1); imshow(imMarkers);
% title("Segmented Markers");
% imEdge = edge(imGray,"canny", [0.1 0.5]);
imEdge = edge(imGray);
f = gcf;
figure((f.Number)+1); imshow(imEdge);
title("Edges");

f = gcf;
figure((f.Number)+1);
imshow(imGray)
%[centers,radii] = imfindcircles(inputImageUndistorted, [10 30],"EdgeThreshold", 0.8, "Sensitivity", .85);
%[centers,radii] = imfindcircles(imGray, [10 30],"EdgeThreshold", 0.9, "Sensitivity", .85);
[centers,radii] = imfindcircles(imGray, [10 30]);
hGrayCircles = viscircles(centers,radii);


f = gcf;
figure((f.Number)+1);
imshow(inputImageUndistorted)
[centers,radii] = imfindcircles(inputImageUndistorted, [10 30]);
hColorCircles = viscircles(centers,radii);






