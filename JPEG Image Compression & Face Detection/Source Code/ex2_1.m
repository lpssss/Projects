clear all; close all; clc;

% 录入测试图像，并截取左上角的8x8块
testimg=double(load('hall.mat').hall_gray);
[height, width]=size(testimg);
testblock=testimg(1:8,1:8);     

% 第二章练习题1:分别在预处理和变换域减去128
normalPBlock=dct2(testblock-128);
altPBlock=dct2(testblock)-128;
difference_21=normalPBlock-altPBlock;
