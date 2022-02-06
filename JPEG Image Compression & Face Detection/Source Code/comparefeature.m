% 第四章练习题2：比较特征函数（与人脸标准比较）
function detected=comparefeature(infeature,stdfeature,epsilon)
%输入：标准特征，待检测特征
%输出：是否为脸部
d=1-sum(sqrt(infeature.*stdfeature));

if d<epsilon
    detected=true;
else
    detected=false;
end
end