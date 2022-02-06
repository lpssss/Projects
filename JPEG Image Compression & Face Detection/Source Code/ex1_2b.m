% 第一章练习题2b

clear all; close all; clc;
testimg=load('hall.mat').hall_color;
[row, column, channel]=size(testimg);
testimg(1:2:row,1:2:column,:)=0;
testimg(2:2:row,2:2:column,:)=0;
imwrite(testimg,'chess_hall.bmp');

