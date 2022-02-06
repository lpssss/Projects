% 第四章练习题2：训练人脸标准函数
function facestd=train(imgdata,resizeddim,kernel,L,totalcolor)
% 输入：所有图片，参数
% 输出：人脸标准
    startidx=1+floor((resizeddim-kernel)/2);    % 截取照片中间kernel^2的部分进行标准特征训练
    endidx=startidx+kernel-1;
    facestd=zeros(totalcolor,1);
    
    % 进行特征训练
    figure;
    for imgidx=1:size(imgdata,4)
        subplot(5,10,imgidx),imshow(uint8(imgdata(startidx(1):endidx(1),startidx(2):endidx(2),:,imgidx)));

        % 计算每个像素对应的n
        imgcolor=floor(double(imgdata(startidx(1):endidx(1),startidx(2):endidx(2),:,imgidx))/bitshift(1,8-L));
        multiplier=ones(kernel,kernel,3);
        multiplier(:,:,1)=bitshift(1,2*L);
        multiplier(:,:,2)=bitshift(1,L);
        imgcolor=sum(imgcolor.*multiplier,3);

        % 计算特征
        facestd=facestd+calcfeature([1,1],imgcolor,totalcolor,kernel);

    end
    facestd=facestd/size(imgdata,4);
end