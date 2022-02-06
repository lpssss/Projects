% 第四章练习题2：从任意图片检测人脸函数
function facedetection(testimg,epsilon,facestd,kernel,L,totalcolor)
% 输入：测试图片，epsilon，人脸标准，参数
% 输出：已用红色方框表示人脸的测试图片

    % 定义参数，读入测试图片
    [testheight,testwidth,testchannel]=size(testimg);
    result=zeros(testheight,testwidth);     % 二进制图（白色部分代表通过人脸检测）


    % 计算每个像素对应的n
    testimgcolor=floor(double(testimg)/bitshift(1,8-L));
    multiplier=ones(testheight,testwidth,testchannel);
    multiplier(:,:,1)=bitshift(1,2*L);
    multiplier(:,:,2)=bitshift(1,L);
    testimgcolor=sum(testimgcolor.*multiplier,3);

    % 使用长宽为kernel的方形在测试图上滑动，检测每一块区域的肤色并与人脸标准相比较
    for rowidx=1:testheight-kernel+1
        for colidx=1:testwidth-kernel+1
            curfeature=calcfeature([rowidx,colidx],testimgcolor,totalcolor,kernel);
            if comparefeature(curfeature,facestd,epsilon)
                result(rowidx:rowidx+kernel-1,colidx:colidx+kernel-1)=1;
            end
        end
    end

    % 对已检测到人脸的区域画红色方框，并输出完成检测的图片
    info = regionprops(logical(result),'Boundingbox') ;
    figure;
    imshow(testimg);
    hold on
    for faceidx = 1 : length(info)
         curbox = info(faceidx).BoundingBox;
         rectangle('Position',[curbox(1),curbox(2),curbox(3),curbox(4)],'EdgeColor','red','LineWidth',1);
    end
end