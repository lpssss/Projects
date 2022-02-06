% 第三章练习题2：DCT域信息隐藏和提取方法1,2,3
clear all; close all; clc;

testimg=load('hall.mat').hall_gray;
qfactor=1;
message=' Wor123&*ja';
% 可选四种模式：all（全替换）,normal(普通)，odd(奇数)，even(偶数)，zigzag
mode='odd';

[oriheight,oriwidth]=size(testimg);
[prcsimg,oricRatio]=makejpeg(testimg,qfactor);      % 对原图进行jpeg编解码（未隐藏信息）

% 将信息隐藏在DCT域，并进行jpeg编解码
DCTmat=imgdct(testimg,qfactor);
newDCTmat=dctencodemsg(DCTmat,message,mode);
cRatio=jpegencode(newDCTmat,oriheight,oriwidth);
[newimg,reDCTmat]=jpegdecode('jpegcodes.mat',qfactor);
decodedmsg=dctdecodemsg(reDCTmat,mode);     % 提取所隐藏的信息

figure;
subplot(1,3,1),imshow(testimg);
title('Original Image');
subplot(1,3,2),imshow(newimg);
title('JPEG Image with hidden message')
subplot(1,3,3),imshow(prcsimg);
title('JPEG Image');
sgtitle("Mode: "+mode);

