% 第二章练习题9：JPEG编码 
function cRatio=jpegencode(DCTmat,height,width)
% 输入：imgdct输出的DCT矩阵，原图长宽
% 函数直接输出：压缩比
% 函数文件输出：struct（DC和AC系数码流，原图长宽）

% 录入DC和AC系数的码本
jpegCoef=load('JpegCoeff.mat');
DCtab=jpegCoef.DCTAB;
ACtab=jpegCoef.ACTAB;

% DC系数编码（DCT矩阵第一行）
% 步骤1：对DC系数做差分编码
shiftdcrow=cat(2,zeros(1,1),DCTmat(1,1:end-1));
dcdif=shiftdcrow-DCTmat(1,:);
dcdif(1,1)=dcdif(1,1)*-1;
% dcdif=[10,2,-52];
category=ceil(log2(abs(dcdif.')+1));    % 计算每个预测误差的category
dchuffcode=DCtab(category+1,:);     % 查码本获取每个category对应的编码

% 步骤2：将每个预测误差转换为二进制（负数使用1-补码）
% 注：预测误差的二进制形式最多需要11bits，另外需要+1列记录长度（必须维持矩阵形式）
outputbin=zeros(length(dcdif),12);     % double 类
% change output to binary form, use 1-complement for negative number
for i=1:length(dcdif)
    binStr=dec2bin(abs(dcdif(i)));
    bitlength=size(binStr,2);
    outputbin(i,1)=bitlength;
    % 分别处理正负数
    if dcdif(i)>=0
        outputbin(i,2:1+bitlength)=double(binStr)-48;
    else
        outputbin(i,2:1+bitlength)=double(~(double(binStr)-48));
    end
end


% 步骤3：将各预测误差的二进制表示和category的Huffman编码写入DC码流
dcbitstreamlen=sum(dchuffcode(:,1))+sum(outputbin(:,1));
dcbitstream=zeros(1,dcbitstreamlen);
curbit=1;
for i=1:size(dchuffcode,1)
    for j=2:dchuffcode(i,1)+1
        dcbitstream(curbit)=dchuffcode(i,j);
        curbit=curbit+1;
    end
    for j=2:outputbin(i,1)+1
        dcbitstream(curbit)=outputbin(i,j);
        curbit=curbit+1;
    end
end  


% AC系数编码
acbitstream=[];
for col=1:size(DCTmat,2)
    ACcoef=DCTmat(2:end,col).';     % 逐块的AC系数
    run=0;  % 表示连续0的数量
    for i=1:size(ACcoef,2)
        if ACcoef(i)==0
           run=run+1;
        else
            if run>=16      % 连续0的数量超过15，使用F/0编码
                for j=1:floor(run/16)
                    acbitstream=cat(2,acbitstream,[1,1,1,1,1,1,1,1,0,0,1]);
                end
                run=mod(run,16);
            end

            acsize=ceil(log2(abs(ACcoef(i))+1));    % 当前系数的size(category)
            rowindex=run*10+acsize;
            curCode=ACtab(rowindex,4:3+ACtab(rowindex,3));  % 在码本中寻找相应位置
            binStr=dec2bin(abs(ACcoef(i)));

            if ACcoef(i)>0
                amplitude=double(binStr)-48;
            else
                amplitude=double(~(double(binStr)-48));
            end
            
            acbitstream=cat(2,acbitstream,curCode);
            acbitstream=cat(2,acbitstream,amplitude);      
            run=0;
        end
    end
    acbitstream=cat(2,acbitstream,[1,0,1,0]);   % 每块结束前需要进行EOB编码
end

jpegcodes.dcbitstream=dcbitstream;
jpegcodes.acbitstream=acbitstream;
jpegcodes.imgheight=height;
jpegcodes.imgwidth=width;

save('jpegcodes.mat','-struct','jpegcodes');

% 第二章练习题10：计算压缩比（使用bits为单位）
oriImgSize=height*width*8;  % 原图使用uint8，其为8bits
compressedSize=(length(dcbitstream)+length(acbitstream));   % 码流每一个码代表1bit
cRatio=oriImgSize/compressedSize;

end