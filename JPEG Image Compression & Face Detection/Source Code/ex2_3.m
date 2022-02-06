clear all; close all; clc;

% 录入测试图像，并截取左上角的8x8块，进行DCT变换
jpegCoef=load('JpegCoeff.mat');
testimg=load('hall.mat').hall_gray;
imgBlock=testimg(1:8,1:8);
DCTCoef=dct2(imgBlock-128);

% 第二章练习题3:DCT系数置零
% 右侧四列系数为0
newDCTCoef1=DCTCoef;
newDCTCoef1(:,5:8)=0;
newimgBlock1=uint8(idct2(newDCTCoef1))+128;

% 左侧四列系数为0
newDCTCoef2=DCTCoef;
newDCTCoef2(:,1:4)=0;
newimgBlock2=uint8(idct2(newDCTCoef2))+128;

% 显示原块和DCT系数置零后的块
subplot(1,3,1),imshow(imgBlock);
title('Original Block');
subplot(1,3,2),imshow(newimgBlock1);
title('Modified Block 1 (right)');
subplot(1,3,3),imshow(newimgBlock2);
title('Modified Block 2 (left)');