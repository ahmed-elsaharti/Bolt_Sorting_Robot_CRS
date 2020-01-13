% This Code is based on the QUARC real time control software/library:
% https://www.quanser.com/products/quarc-real-time-control-software
% Ahmed Elsaharty 2019

clc
clear all
setup_lab_crs
q_crs_pos_cntrl_world
clc
%---- Make sure the robot is deactivated while listening for tcp input ----
set_param('q_crs_pos_cntrl_world/Ready','Value','0');
set_param('q_crs_pos_cntrl_world/Mode','Value','1');
%---- using the jtcp function to listen for a connection ----
f = waitbar(0,'Waiting for object locations....');
jTcpObj = jtcp('accept',30002,'timeout',0,'acceptZeroTimeouts',true);
ReceivedData = jtcp('read',jTcpObj); 
jtcp('close',jTcpObj);
disp('Received')
close(f);
f = msgbox('Received Object Parameters')
pause(1);
close(f);
%---- Activating robot after receiving data ----
moveCRS('ready')
%---- Counting the number of objects ----
[m,n]=size(ReceivedData);
%---- Making sure data is in a row matrix ----
if n<2
    ReceivedData=ReceivedData';
    [m,n]=size(ReceivedData);
end
%---- Preparing the robot for the motion ----
moveCRS('prep')

ReceivedData
Strt=3;
Strt = menu('Do you wish to proceed?','Yes','No')
    moveCRS('grip',50,1)
    moveCRS('grip',0,1)
    moveCRS('grip',50,1)
while (Strt==1)
for ii=1:m
    x_pos=ReceivedData(ii,1);
    y_pos=ReceivedData(ii,2);
    theta=ReceivedData(ii,3);
    width=ReceivedData(ii,5);
    moveCRS('grip',45,1)
    moveCRS('x',x_pos,0)
    moveCRS('y',y_pos,1)
    moveCRS('roll',theta,2)
    moveCRS('z',-450,1)
    moveCRS('grip',0,1)
    moveCRS('z',-400,1)
    placementdist=-220+((ii-1)*40);
    moveCRS('x',placementdist,0)
    moveCRS('y',-230,0)
    moveCRS('roll',-90,2)
    moveCRS('z',-450,1)
    moveCRS('grip',45,1)
    moveCRS('z',-400,1)
end
%pause(1)
Strt=3;
end
%---- Homing the robot after the motion is done ----

moveCRS('home')
f = msgbox('Task Complete')
pause(1);
