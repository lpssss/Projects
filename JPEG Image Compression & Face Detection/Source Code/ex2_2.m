%第二章练习题2:自主编程实现二维DCT
clear all; close all; clc;

% 录入测试图像，并截取左上角的8x8块
testimg=double(load('hall.mat').hall_gray);
[height, width]=size(testimg);
testblock=testimg(1:8,1:8);     

% 使用Matlab自带的dct2与自编函数mydct2进行比较
normalPBlock=dct2(testblock-128);
testPBlock=mydct2(testblock-128);
difference_22=testPBlock-normalPBlock;