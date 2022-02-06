 % 第二章练习题8：图像分块，DCT和量化
function result=imgdct(img,qfactor)
%输入：任意大小的灰度图像
%输出：量化后的DCT矩阵（double），每一列对应一个块，第一行为各块DC分量

    [height, width]=size(img);
    img=double(img);     % important
    % 若图像不是8的倍数，向右方和下方延伸补0
    heigthmod=mod(height,8);
    widthmod=mod(width,8);
    if heigthmod~=0
        img=padarray(img,[8-heigthmod 0],0,'post');
        height=height+8-heigthmod;
    end
    if widthmod~=0
        img=padarray(img,[0 8-widthmod],0,'post');
        width=width+8-widthmod;
    end
    
    %img
    % 块的大小为8x8，所以result有64行；result的列数为8x8块的数量
    result=zeros(64,height*width/64);    
    qCoef=load('JpegCoeff.mat').QTAB/qfactor;   %量化系数  
    curC=1;    %列序号（也代表块序号） 
    
    %由左到右逐块进行DCT和量化
    for i=1:height/8
        for j=1:width/8
            curDCTBlock=img(1+8*(i-1):8*i,1+8*(j-1):8*j);
            curDCTBlock=round(dct2(curDCTBlock-128)./qCoef);
            %curDCTBlock
            result(:,curC)=zigzag(curDCTBlock).';
            curC=curC+1;
        end
    end
end