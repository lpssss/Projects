clear all; close all; clc;

fc=3e8;             % 载波频率(Hz)
c=3e8;              % 载波速度(m/s)
lambda=c/fc;        % 载波波长(m)
fs=8000.0;          % 快拍速度(Hz)
M=8;                % 子阵内阵元
S=3;                % 子镇数量
xi=[0 5 10];        % 子阵第一个阵元的位置（以lambda为单位）
D=3;                % 信号源数量
theta=[16 20 70];   % 信号源角度
sigma_n2=[1 2 3 4 5];   % 噪声功率

% 定义阵列和生成高斯随机信号
subarray=phased.ULA('NumElements',M,'ElementSpacing',lambda/2);
osig=randn(fs,D);

% MUSIC算法仿真
rmse=zeros(size(sigma_n2));
snrratio=zeros(size(sigma_n2));
for nidx=1:length(sigma_n2)
    finaldoas=0;
    for sidx=1:S
        arrdiff=exp(1i*2*pi*xi(sidx)*sin(theta));  % 考虑子阵位置的相位差
        sig=collectPlaneWave(subarray,osig.*arrdiff,theta,fc); % 计算阵元的接收信号
        [m, n]=size(sig);
        noise=wgn(m,n,10*log10(sigma_n2(nidx)),'complex');  % 生成噪声
        estimator = phased.MUSICEstimator('SensorArray',subarray,...
            'OperatingFrequency',fc,...
            'DOAOutputPort',true,'NumSignalsSource','Property',...
            'NumSignals',D);
        [y,doas] = estimator(sig + noise);
        finaldoas=finaldoas+sort(doas);
        figure;
        plotSpectrum(estimator,'NormalizeResponse',true)
    end
    finaldoas=finaldoas./S;     % 每个子阵完成测角后取平均
    rmse(nidx)=sqrt(mean(finaldoas-theta).^2);  % 计算方均根误差
    snrratio(nidx)=mag2db((rssq(sig(:)))/rssq(noise(:)));   %计算信噪比
end

% root-MUSIC算法仿真
r_rmse=zeros(size(sigma_n2));
r_snrratio=zeros(size(sigma_n2));
for nidx=1:length(sigma_n2)
    r_finaldoas=0;
    for sidx=1:S
        arrdiff=exp(1i*2*pi*xi(sidx)*sin(theta));
        sig=collectPlaneWave(subarray,osig.*arrdiff,theta,fc);
        [m, n]=size(sig);
        noise=wgn(m,n,10*log10(sigma_n2(nidx)),'complex');
        estimator = phased.RootMUSICEstimator('SensorArray',subarray,...
            'OperatingFrequency',fc,...
            'NumSignalsSource','Property',...
            'NumSignals',D);
        doas = estimator(sig + noise);
        r_finaldoas=r_finaldoas+sort(doas);
    end
    r_finaldoas=r_finaldoas./S;
    r_rmse(nidx)=sqrt(mean(r_finaldoas-theta).^2);
    r_snrratio(nidx)=mag2db((rssq(sig(:)))/rssq(noise(:)));
end

% 绘制RMSE与SNR关系图
figure;
plot(snrratio,rmse,'-o');
hold on;
plot(r_snrratio,r_rmse,'-*');
xlabel("信噪比 SNR (dB)");
ylabel("方均根误差 RMSE"); 
legend('MUSIC','root-MUSIC');
title('MUSIC 与 root-MUSIC 算法在不同信噪比下的性能');










