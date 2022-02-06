% 9.2.2，第1题
clear all; close all; clc;

% 定义抽样频率，数字信号时长
spfreq=8000;
duration=1;

% 生成200Hz和300Hz信号
sig1=zeros(1,spfreq*duration);
sig2=zeros(1,spfreq*duration);
impfreq1=200;
impfreq2=300;
disperiod1=round(spfreq/impfreq1);
disperiod2=round(spfreq/impfreq2);
sig1(1:disperiod1:length(sig1))=1;
sig2(1:disperiod2:length(sig2))=1;

% 试听
sound(sig1,8000);
pause(5);
sound(sig2,8000);