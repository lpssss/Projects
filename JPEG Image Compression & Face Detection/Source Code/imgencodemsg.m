% 第三章练习题1：空域信息隐藏
function [oriEimg,prcsEimg]=imgencodemsg(img,message)
% 输入：任意长宽的图像（测试中使用灰度图像）
% 输入：需要隐藏的信息
% 输出：含隐藏信息的图像（未经jpeg编码）
% 输出：含隐藏信息的图像经过jpeg编码处理后的图像
    [heigth, width, ~]=size(img);
    oriEimg=img;

    % 隐藏信息顺序为逐列，逐行到逐通道
    %totalbit=length(message)*8;     % 信息总bit数
    channelptr=1;   % 通道序号
    heigthptr=1;    % 行序号
    widthptr=1;     % 列序号


    % 隐藏信息
    for charidx=1:length(message)+1
        if charidx==length(message)+1
            binStr='00000000';      % 信息结束字符
        else
            binStr=dec2bin(uint8(message(charidx)),8);  % 获取每个字符的8位二进制表示
        end
        for stridx=1:length(binStr)
            curbit=uint8(binStr(stridx))-48;        % 获取当前的bit
            oriEimg(heigthptr,widthptr,channelptr)=bitset(oriEimg(heigthptr,widthptr,channelptr),1,curbit,'uint8');     %替换原图像素最后一位，注意原图像素以uint8表示

            % 检查是否溢出
            widthptr=widthptr+1;
            if widthptr>width
                widthptr=1;
                heigthptr=heigthptr+1;
                if heigthptr>heigth
                    heigthptr=1;
                    channelptr=channelptr+1;
                end
            end
        end
    end
    
    % 进行jpeg编解码（第二章第7到11题所要求的功能）
    [prcsEimg,~]=makejpeg(oriEimg,1);
end