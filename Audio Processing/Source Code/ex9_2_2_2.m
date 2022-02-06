% 9.2.2，第2题
clear all; close all; clc;

% 定义抽样频率，数字信号时长，段长，段的数量，每段数据点
spfreq=8000;
excduration=1;
blockduration=10/1000;
numBlock=excduration/blockduration;
disPt=spfreq*blockduration;

exc=zeros(1,spfreq*excduration);
startidx=1;
for blockidx=1:numBlock
    pitch=80+5*mod(blockidx,50);
    curRange=startidx:pitch:blockidx*disPt;
    exc(curRange)=1;
    startidx=curRange(length(curRange));    % 令最后一个脉冲位置为下一段起始位置
end

sound(exc,8000);

