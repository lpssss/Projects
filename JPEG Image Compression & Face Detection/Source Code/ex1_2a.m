% 第一章练习题2a
clear all; close all; clc;

testimg=load('hall.mat').hall_color;
[height, width, channel]=size(testimg);
imshow(testimg);

% 画圆圈
radius=min(height,width)/2;
center=[width height]/2;
viscircles(center,radius,'LineWidth',0.5);

newimg=getframe(gca).cdata;
imwrite(newimg,'circle_hall.bmp');




