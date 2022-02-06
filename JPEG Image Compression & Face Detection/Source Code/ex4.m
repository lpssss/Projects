% 第四章练习题2：人脸检测
clear all; close all; clc;

% 读入训练图片，并调整大小
imgfiles=dir('./Faces/*.bmp');
resizeddim=[40,40];
imgdata=zeros(resizeddim(1),resizeddim(2),3,length(imgfiles));
for idx=1:length(imgfiles)
    temp=imread("./Faces/"+imgfiles(idx).name);
    imgdata(:,:,:,idx)=imresize(temp,resizeddim);
    
end

% 定义参数
L=3;
kernel=30;       
totalcolor=bitshift(1,3*L);                                    
facestd=train(imgdata,resizeddim,kernel,L,totalcolor);

% 定义参数，读入测试图片
epsilon=0.35;
testimg=imread('facetest1.jpg');
facedetection(testimg,epsilon,facestd,kernel,L,totalcolor);

% 第四章练习题3：改动图像并重新检测
[rotatedImg,resizedImg,adjustedImg1,adjustedImg2]=modifyimg(testimg);
facedetection(rotatedImg,epsilon,facestd,kernel,L,totalcolor);
facedetection(resizedImg,epsilon,facestd,kernel,L,totalcolor);
facedetection(adjustedImg1,epsilon,facestd,kernel,L,totalcolor);
facedetection(adjustedImg2,epsilon,facestd,kernel,L,totalcolor);
