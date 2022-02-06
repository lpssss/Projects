% 第四章练习题3：修改图片函数
function [rotatedImg,resizedImg,adjustedImg1,adjustedImg2]=modifyimg(inImg)
% 输入：原图
% 输出：旋转，拉长，改变颜色的图片

[heigth,width,~]=size(inImg);

%rotate image
rotatedImg=imrotate(inImg,-90);

%resize image: heigth unchanged, width doubled
resizedImg=imresize(inImg,[heigth,width*2]);

%readjust color
adjustedImg1=imadjust(inImg,[0.2 0.2 0.2; 0.8 0.8 0.8]);
adjustedImg2=imadjust(inImg,[0.2 0.3 0; 0.6 0.7 1]);

end