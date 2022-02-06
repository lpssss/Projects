% 第二章练习题7：矩阵zigzag扫描 
function result=zigzag(A)
%输入：MxN 矩阵A
%输出：zigzag扫描后的向量
    [M,N]=size(A);
    result=zeros(1,M*N);
    diagstart=1;
    diagend=1;
    
    for i=1:N+M-1       % 左上角第一个元素（DC量）要包括
        if i<=N
            curR=1;
            curC=i;
        else
            curR=i-N+1;
            curC=N;
        end
        while curR<=M && curC>=1
            result(diagend)=A(curR,curC);
            curR=curR+1;
            curC=curC-1;
            diagend=diagend+1;
        end
        if mod(i,2)==0   
            diagstart=diagend;
        else
            % 序号为奇数（从1算起）的斜对角需要倒序排列
            result(diagstart:diagend-1)=flip(result(diagstart:diagend-1));
            diagstart=diagend;
        end
    end
end