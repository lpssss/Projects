% 第三章练习题2：DCT域信息提取
function message=dctdecodemsg(DCTmat,mode)
% 输入：imgdct输出形式的DCTmat，隐藏信息模式
% 输出：所隐藏的信息

[numCoef,numBlock]=size(DCTmat);
result=[];
curData=zeros(1,8);
countbit=1;

if isequal(mode,'zigzag')       % zigzag模式和其他模式分开
    countbit=1;
    for blockptr=1:numBlock
        if countbit==9
            countbit=1;
            binStr=char(curData+48);
            if isequal(binStr,'00000000')
                break;
            else
                result=cat(2,result,bin2dec(binStr));
            end
        end

        coefptr=numCoef;
        while coefptr>=1
            if DCTmat(coefptr,blockptr)~=0
                break
            else
                coefptr=coefptr-1;
            end
        end

        if DCTmat(coefptr,blockptr)==1
            curData(countbit)=1;
        else
            curData(countbit)=0;
        end
        countbit=countbit+1;
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

    % 恢复信息
    flag=false;     %若发现结束符号，即输出所提取的信息

    for blockptr=1:numBlock
        if flag
            break
        end
        for coefptr=startcoefptr:step:numCoef
            cur=dec2bin(DCTmat(coefptr,blockptr),8);
            curData(countbit)=double(cur(8))-48;  % 获取最后一个bit
            countbit=countbit+1;
            if countbit==9
                countbit=1;
                binStr=char(curData+48);
                if isequal(binStr,'00000000')
                    flag=true;
                    break;
                else
                    result=cat(2,result,bin2dec(binStr));
                end
            end
        end
    end
end
message=char(result);
end