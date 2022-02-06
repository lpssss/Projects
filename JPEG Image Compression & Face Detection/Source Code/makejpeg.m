% 合并第二章练习题7至12为一个函数
function [newimg,cRatio]=makejpeg(oriimg,qfactor)
% 输入：原图，量化步长
% 输出：原图经jpeg编解码后的图像，压缩比

    [oriheight,oriwidth]=size(oriimg);
    DCTmat=imgdct(oriimg,qfactor);
    cRatio=jpegencode(DCTmat,oriheight,oriwidth);
    [newimg,~]=jpegdecode('jpegcodes.mat',qfactor);
end