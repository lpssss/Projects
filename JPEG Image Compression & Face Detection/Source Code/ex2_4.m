clear all; close all; clc;

% 录入测试图像，并截取左上角的8x8块，进行DCT变换
testimg=load('hall.mat').hall_gray;
imgBlock=testimg(1:8,1:8);
DCTCoef=dct2(imgBlock-128);

% 第二章练习题4：分别对DCT系数进行转置，旋转90度（逆时针）与旋转180度，并进行逆变换
transposeImg=uint8(idct2(DCTCoef.')+128);
rot1Img=uint8(idct2(rot90(DCTCoef))+128);
rot2Img=uint8(idct2(rot90(DCTCoef,2))+128);

% 显示所有图像块
subplot(2,2,1),imshow(imgBlock);
title('Original Block');
subplot(2,2,2),imshow(transposeImg);
title('Transposed Block');
subplot(2,2,3),imshow(rot1Img);
title('Rotated 90 Block');
subplot(2,2,4),imshow(rot2Img);
title('Rotated 180 Block');

