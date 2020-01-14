% Ahmed Elsaharti 2019

clear all
clc
clf 
close all

vid=webcam;
vid.ExposureMode='manual';
vid.Exposure=-3;

image=imread('Snapshot.jpg');
image=snapshot(vid);
[m,n,z]=size(image);
image(386:m,1:n,1:3)=255;
image(1:m,513:n,1:3)=255;
parameterspixel=DetectObj(image,1,0.45,20,2); %usually 0.45 as thresh
[objectcount,n]=size(parameterspixel);
%Converting pixel coordinates to world coordinates
if objectcount>0 
for i=1:1:objectcount
   x=parameterspixel(i,1);
   y=parameterspixel(i,2);
   [xworld,yworld]=CRS_Image2World(x,y);
   parameterspixel(i,1)=xworld;
   parameterspixel(i,2)=yworld;
end
%Converting theta's datum to match the robot's datum
for i=1:1:objectcount

   %%-----------------parameterspixel(i,3)=270-parameterspixel(i,3);
   if parameterspixel(i,3)>180
       parameterspixel(i,3)=-(360-parameterspixel(i,3));
   end
end
%Arranging the items in order of area
parameterspixel=sortrows(parameterspixel,4)
pause(1)
clc
parameterspixel

jTcpObj = jtcp('request','172.16.235.235',30002,'timeout',0,'acceptZeroTimeouts',true); 
jtcp('write',jTcpObj,parameterspixel);
jtcp('close',jTcpObj);
disp('Sent')
else
    f = msgbox('No Objects Detected')
end