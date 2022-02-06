%第二章练习题11：JPEG解码
function [outputimg,DCTmat]=jpegdecode(filename,qfactor)
%function outputimg=jpegdecode(filename,qfactor)
% 输入：jpegcodes.mat（编码文件输出的码流）
% 输出：码流代表的图片，其长宽与原图相同

% 录入输入文件中的码流和原图长宽
jpegcodes=load(filename);
dcbitstream=jpegcodes.dcbitstream;
acbitstream=jpegcodes.acbitstream;
oriheight=jpegcodes.imgheight;
oriwidth=jpegcodes.imgwidth;

% 计算块的数量
heightmod=mod(oriheight,8);
widthmod=mod(oriwidth,8);
if heightmod~=0
    newheight=oriheight+8-heightmod;
else
    newheight=oriheight;
end
if widthmod~=0
    newwidth=oriwidth+8-widthmod;
else
    newwidth=oriwidth;
end
numBlock=(newheight)*(newwidth)/64;

% 录入码本和量化系数
jpegCoef=load('JpegCoeff.mat');
Qtab=jpegCoef.QTAB/qfactor;
%DCtab=jpegCoef.DCTAB;
ACtab=jpegCoef.ACTAB;

% 建立DC码本的字典，Huffman码：category
keySet={'00','010','011','100','101','110','1110','11110','111110','1111110','11111110','111111110'};
valueSet=0:1:11;
dcmap=containers.Map(keySet,valueSet);

% 建立AC码本的字典，Huffman码：run/size
valueSet=100*ACtab(:,1)+ACtab(:,2);     % run/size以run*100+size表示
valueSet=cat(1,[0;1500],valueSet).';
keySet={'1010','11111111001'};          % 添加0/0与F/0编码
for dcidx=1:size(ACtab,1)
    curCode=ACtab(dcidx,4:3+ACtab(dcidx,3));
    curCode=char(curCode+48);
    keySet{dcidx+2}=curCode;
end
acmap=containers.Map(keySet,valueSet);

% DC码流解码
DCcoef=zeros(1,numBlock);
curblock=1;         % 块序号
hcodestart=1;       % Huffman码起始点
dcidx=1;            % DC码流序号
while dcidx<=length(dcbitstream)
    curCode=char(dcbitstream(hcodestart:dcidx)+48);
    if isKey(dcmap,curCode)     % 判断此码是否为码本中的Huffman码
        category=dcmap(curCode);
        if category==0          % 预测误差为0
            curblock=curblock+1;    
            dcidx=dcidx+2;
            hcodestart=dcidx;
        else
            amp=dcbitstream(dcidx+1:dcidx+category);    %预测误差的二进制表示
            % 处理正负数
            if amp(1)==0  
                ampbitStr=char(double(~amp)+48);
                DCcoef(curblock)=bin2dec(ampbitStr)*-1;
            else 
                ampbitStr=char(amp+48);
                DCcoef(curblock)=bin2dec(ampbitStr);
            end
            
            dcidx=dcidx+category+1;     % 移动到预测误差二进制表示的下一位
            hcodestart=dcidx;
            curblock=curblock+1;
        end
    else
        dcidx=dcidx+1;
    end
end
%curblock
% 对DC系数进行反差分
for curblock=2:numBlock
    DCcoef(curblock)=DCcoef(curblock-1)-DCcoef(curblock);
end


% AC码流解码
ACcoef=zeros(63,numBlock);      % 每一列代表一个块的AC系数
curblock=1;                     % 块序号
inblockCoef=zeros(63,1);        % 用来记录块内系数的中间变量
inblockPtr=1;                   % 中间变量序号
acidx=1;                        % AC码流序号
hcodestart=1;                   % Huffman码起始点
while acidx<=length(acbitstream)
    curCode=char(acbitstream(hcodestart:acidx)+48);
    if isKey(acmap,curCode)
        runsize=acmap(curCode);
        if runsize==0   % run/size为0，代表此块结束
            ACcoef(:,curblock)=inblockCoef;
            inblockCoef=zeros(63,1);    % 重置中间变量
            inblockPtr=1;
            curblock=curblock+1;
            acidx=acidx+1;
            hcodestart=acidx;
        else
            zerorun=floor(runsize/100); % 获取run的值
            amplen=mod(runsize,100);    % 获取size的值
            amp=acbitstream(acidx+1:acidx+amplen);  % 获取非零值的二进制表示
            inblockPtr=inblockPtr+zerorun;  % 移动到非0值所在的位置
            if amplen>=1
                % 处理正负数
                if amp(1)==0  
                    ampbitStr=char(double(~amp)+48);
                    inblockCoef(inblockPtr)=bin2dec(ampbitStr)*-1;
                else  
                    ampbitStr=char(amp+48);
                    inblockCoef(inblockPtr)=bin2dec(ampbitStr);
                end            
            end
            inblockPtr=inblockPtr+1;    % 移动到非零值的下一个位置（已考虑F/0情况） 
            acidx=acidx+amplen+1;
            hcodestart=acidx;
        end
    else
        acidx=acidx+1;
    end
end



% 定义解码图像（含padding）
outputimg=zeros(newheight,newwidth);      
% 将DCCoef与ACCoef转换成一系列8x8块，并反量化和逆dct
curblock=1;
for heightidx=1:newheight/8
    for widthidx=1:newwidth/8
        DCTblock=izigzag(DCcoef(curblock),ACcoef(:,curblock));
        temp=DCTblock.*Qtab;
        %temp
        outputimg(1+8*(heightidx-1):8*heightidx,1+8*(widthidx-1):8*widthidx)=idct2(temp);
        curblock=curblock+1;
    end
end


% 若有，删除padding
outputimg=outputimg(1:oriheight,1:oriwidth);
outputimg=uint8(outputimg+128);

% 将DC系数与AC系数合并形成原来的DCT矩阵
DCTmat=[DCcoef;ACcoef];
    
end