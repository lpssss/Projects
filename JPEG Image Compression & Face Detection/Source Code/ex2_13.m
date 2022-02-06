% 第二章练习题13：雪花图像编解码，测试图像编解码
clear all; close all; clc;

testimg=load('snow.mat').snow;
qfactor=1;

[oriheight,oriwidth]=size(testimg);
DCTmat=imgdct(testimg,qfactor);
cRatio=jpegencode(DCTmat,oriheight,oriwidth);
[jpegimg,~]=jpegdecode('jpegcodes.mat',qfactor);

subplot(1,2,1),imshow(testimg);
title('Original Snow Image');
subplot(1,2,2),imshow(jpegimg);
title('JPEG Snow Image');
psnr=PSNR(double(testimg),double(jpegimg));
