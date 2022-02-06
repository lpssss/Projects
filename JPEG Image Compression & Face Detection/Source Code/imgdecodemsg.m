% 第三章练习题1：空域信息提取
function recmsg=imgdecodemsg(img)
% 输入：含隐藏信息的图像
% 输出：所隐藏的信息
    [heigth, width, channel]=size(img);
    % 解读信息
    countbit=1;     % 一个字符中每个bit的序号
    result=[];      % 解读后字符串的ascii十进制表示
    curData=uint8(zeros(1,8));  % 当前字符
    flag=false;                 % 在解读完毕后用来跳出循环
    for channelptr=1:channel
        if flag
            break
        end
        for heigthptr=1:heigth
            if flag
                break
            end
            for widthptr=1:width
                cur=dec2bin(img(heigthptr,widthptr,channelptr),8);
                curData(countbit)=uint8(cur(8))-48;  % 获取最后一个bit
                countbit=countbit+1;
                if countbit==9
                    countbit=1;
                    binStr=char(curData+48);    % 当前字符ascii码二进制表示
                    %binStr
                    if isequal(binStr,'00000000')
                        flag=true;
                        break;
                    else
                        result=cat(2,result,bin2dec(binStr));   % 以字符ascii码十进制储存
                    end
                end
            end
        end
    end

    recmsg=char(result);    % 从ascii码转换成字符
end