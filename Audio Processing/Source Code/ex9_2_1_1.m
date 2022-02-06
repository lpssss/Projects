% 第9.2.1题
clear all; close all; clc;

% 定义系数a，b和样点n
a=[1];
b=[1,-1.3789,0.9506];
n=[0:10];

% 合成模型共振峰频率（预测模型的逆）
r=roots(b);
formant=angle(r)*8000/(2*pi);

% 针对预测模型，绘制零极点分布图，频率相应，单位样值相应
figure;
subplot(1,3,1),zplane(b,a);
subplot(1,3,2),impz(b,a,n);
title('Impulse Response(impz)');

x=(n==0);   % 冲激信号
hf=filter(b,a,x);
subplot(1,3,3),stem(n,hf);  % 利用filter与impz比较
xlabel('n(samples)');
ylabel('Amplitude');
title('Impulse Response(filter)');

figure,freqz(b,a);

