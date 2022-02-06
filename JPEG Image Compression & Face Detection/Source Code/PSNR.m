% 第二章练习题11：JPEG解码部分-PSNR 

function result=PSNR(oriImg,newImg)
% 输入：原本图像，处理图像
% 输出：PSNR值（越大表示失真越小）
[heigth,width]=size(oriImg);
mse=sum(pow2(oriImg-newImg),'all')/(heigth*width);
result=10*log10(pow2(255)/mse);
end