% 第二章练习题11：JPEG解码-逆zigzag部分

function block=izigzag(DCcoef,ACcoef)
% 输入：1x1DC分量，长度为63的AC系数向量
% 输出：8x8量化后DCT系数块
block=zeros(8,8);
block(1,1)=DCcoef;
curindex=1;     % AC向量元素序号

for i=2:8+7
    if mod(i,2)~=0
        rev=true;       % rev为true代表需要翻转
    else
        rev=false;
    end
    
    if i<=8
        curC=i;
        curR=1;
        if rev
            curindex=curindex+i-1;
        end
    else
        curC=8;
        curR=i-7;
        if rev
            curindex=curindex+7-(i-8);
        end
    end

    while curC>=1 && curR<=8
        block(curR,curC)=ACcoef(curindex);
        curR=curR+1;
        curC=curC-1;
        if rev
            curindex=curindex-1;
        else
            curindex=curindex+1;
        end
    end
    if rev
        if i<=8
            curindex=curindex+i+1;      
        else
            curindex=curindex+8-(i-8)+1;
        end
    end
end
end