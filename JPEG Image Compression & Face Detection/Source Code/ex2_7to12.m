% 结合第二章7到12题
clear all; close all; clc
testimg=load('hall.mat').hall_gray;
qfactor=[1,2];
[oriheight,oriwidth]=size(testimg);
psnr=zeros(1,length(qfactor));
cRatio=zeros(1,length(qfactor));

figure;
subplot(1,3,1),imshow(testimg);
title('Original Image');

for idx=1:length(qfactor)
    % imgdct实现了第8题要求的功能，里头使用了第7章要求的zigzag函数
    DCTmat=imgdct(testimg,qfactor(idx));
    % jpegencode实现了第9与第10题要求的功能
    cRatio(idx)=jpegencode(DCTmat,oriheight,oriwidth);
    % jpegdecode和PSNR实现了第10与11题要求的功能，前者程序有使用izigzag函数
    [jpegimg,~]=jpegdecode('jpegcodes.mat',qfactor(idx));
    psnr(idx)=PSNR(double(testimg),double(jpegimg));

    subplot(1,3,idx+1),imshow(jpegimg);
    title("JPEG Image with qfactor="+qfactor(idx));
    
end

