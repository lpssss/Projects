%第二章练习题2:自主编程实现二维DCT

function DCTCoef=mydct2(imgBlock)
% 输入：8x8块
% 输出：8x8DCT系数

    [M,N]=size(imgBlock);
    % 逐列进行一维DCT，结果为 MxM 矩阵Dm
    firstrow=zeros(1,M);    
    firstrow=firstrow+sqrt(1/2);
    product=1:2:2*M-1;
    omg=pi/(2*M):pi/(2*M):(M-1)*pi/(2*M);
    matDm=cos(kron(omg.',product));
    matDm=[firstrow;matDm];
    
    % 逐行进行一维DCT，结果为 MxM 矩阵Dm
    firstrow=zeros(1,N);
    firstrow=firstrow+sqrt(1/2);
    product=1:2:2*N-1;
    omg=pi/(2*N):pi/(2*N):(N-1)*pi/(2*N);
    matDn=cos(kron(omg.',product));
    matDn=[firstrow;matDn];
    
    % 矩阵相乘形成二维DCT系数矩阵
    DCTCoef=2/sqrt(M*N).*(matDm*double(imgBlock)*(matDn.'));
    
end
