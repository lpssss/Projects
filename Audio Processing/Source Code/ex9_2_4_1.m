% 9.2.4第1题
clear all; close all; clc;

% 定义系数a，b和样点n
a=[1];
b=[1,-1.3789,0.9506];
n=[0:10];

% 提高共振峰频率
[z,p,k]=tf2zpk(a,b);
new_p=p.*exp(1i.*sign(angle(p))*2*pi/8000*150);
[new_b,new_a]=zp2tf(z,new_p,k);