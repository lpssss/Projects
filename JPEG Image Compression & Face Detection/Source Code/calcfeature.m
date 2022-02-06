% 第四章练习题2：计算区域特征函数
function feature=calcfeature(startidx,imgcolor,totalcolor,kernel)
% 输入：区域左上角坐标，待检测区域的颜色序号，参数
% 输出：长度为总颜色数量的向量

% 遍历待检测的区域
feature=zeros(totalcolor,1);
for heightidx=startidx(1):startidx(1)+kernel-1
    for widthidx=startidx(2):startidx(2)+kernel-1
        feature(imgcolor(heightidx,widthidx)+1)=feature(imgcolor(heightidx,widthidx)+1)+1;
    end
end
feature=feature/(kernel*kernel);
end
