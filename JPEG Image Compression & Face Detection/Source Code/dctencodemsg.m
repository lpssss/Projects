% 第三章练习题2：DCT域信息隐藏
function DCTmat=dctencodemsg(DCTmat,message,mode)
% 输入：imgdct输出的DCT矩阵，待隐藏的信息
% 输入：选择模式-all（全替换）,normal(普通)，odd(奇数)，even(偶数)，zigzag
% 输出：隐藏信息后的DCT矩阵

[numCoef, numBlock]=size(DCTmat);   % numCoef is 64
blockptr=1;     % 块序号
if isequal(mode,'zigzag')
    for charidx=1:length(message)+1
        if charidx==length(message)+1
            binStr='00000000';      % 结束符号
        else
            binStr=dec2bin(double(message(charidx)),8);
        end
        %binStr
        for stridx=1:length(binStr)
            curbit=double(binStr(stridx))-48;
            coefptr=numCoef;
            % 从每一列最后一个系数开始遍历，遇到非零数时跳出循环
            while coefptr>=1
                if DCTmat(coefptr,blockptr)~=0
                    break
                else
                    coefptr=coefptr-1;
                end
            end
            if coefptr~=numCoef
                coefptr=coefptr+1;
            end
            if curbit==1
                DCTmat(coefptr,blockptr)=1;
            else
                DCTmat(coefptr,blockptr)=-1;
            end
            blockptr=blockptr+1;    
        end
    end
else
    if isequal(mode,'odd') 
        step=2;
        startcoefptr=1;
    elseif isequal(mode,'even')
        step=2;
        startcoefptr=2;
    else
        step=1;
        startcoefptr=1;
    end
    coefptr=startcoefptr;

    % 信息隐藏
    for charidx=1:length(message)+1
        if charidx==length(message)+1
            if isequal(mode,'all')
                % 剩下的系数中的最后一位都改成0
                while blockptr<=numBlock
                    DCTmat(coefptr,blockptr)=bitset(DCTmat(coefptr,blockptr),1,0,'int64');
                    coefptr=coefptr+step;
                    if coefptr>numCoef
                        coefptr=startcoefptr;
                        blockptr=blockptr+1;
                    end
                end
                break
            else
                binStr='00000000';      % 结束符号
            end
        else
            binStr=dec2bin(double(message(charidx)),8);
        end
        %binStr
        for stridx=1:length(binStr)
            curbit=uint8(binStr(stridx))-48;
            DCTmat(coefptr,blockptr)=bitset(DCTmat(coefptr,blockptr),1,curbit,'int64');     % 由于DCT为double，需要使用int64
            coefptr=coefptr+step;
            if coefptr>numCoef
                coefptr=startcoefptr;
                blockptr=blockptr+1;
            end
        end
    end
end
end