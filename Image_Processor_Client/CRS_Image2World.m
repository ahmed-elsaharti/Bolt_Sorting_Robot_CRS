function [Xworld,Yworld] = CRS_Image2World(xpixels,ypixels)
%-------------------------------------------------------------------------------------
%This function converts x and y positions on the image frame to real world
%x and y positions and returns the corresponding x and y offset from the
%robot's home poisition
%-------------------------------------------------------------------------------------
%Note: This function loads calibration data produced by the camera
%calibration app on matlab. If a different camera is used this calibration
%date needs to be regenerated.
%-------------------------------------------------------------------------------------

load('CameraCalibrationApril19.mat')

imOrig = imread('image14.png'); %Loading calibration grid picture taken from camera POV to be studied.
[im, newOrigin] = undistortImage(imOrig, cameraParams, 'OutputView', 'full');
[imagePoints, boardSize] = detectCheckerboardPoints(im);
imagePoints = bsxfun(@plus, imagePoints, newOrigin);
%imagePoints = imagePoints + newOrigin; %UNCOMMENT if using new revision
[R, t] = extrinsics(imagePoints, worldPoints, cameraParams);

imagePoints1=[xpixels,ypixels];
worldPoints1 = pointsToWorld(cameraParams, R, t, imagePoints1); %extract position relative to calibrated origin
Xworld=-188+worldPoints1(1,1); %Convert calibrated origin to robot origin coordinates
Yworld=38-worldPoints1(1,2); %Convert calibrated origin to robot origin coordinates
end

