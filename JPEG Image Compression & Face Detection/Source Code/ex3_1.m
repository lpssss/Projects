% 第三章练习题1：空域信息隐藏和提取
clear all; close all; clc;

imgfile=load('hall.mat');
grayimg=imgfile.hall_gray;
rgbimg=imgfile.hall_color;

% 隐藏信息顺序为逐列，逐行到逐通道
message='Hi World123';

% 含信息的原图，含信息的JPEG图
[oriEimg,prcsEimg]=imgencodemsg(grayimg,message);

figure;
subplot(1,3,1),imshow(grayimg);
title('Original Image');
subplot(1,3,2),imshow(oriEimg);
title('Original Image with hidden message');
subplot(1,3,3),imshow(prcsEimg);
title('JPEG Image with hidden message');

% 从原图和JPEG图提取信息
orimsg=imgdecodemsg(oriEimg);
prcsmsg=imgdecodemsg(prcsEimg);

