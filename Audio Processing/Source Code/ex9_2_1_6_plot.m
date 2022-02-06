function ex9_2_1_6_plot(exc,orisig,reconsig)
% 输入：激励信号e(n)，原语音s(n)，重建语音shat(n)
% 输出：三个信号当中一小段的plot
slength=160;
startidx=floor(length(exc)/2);
endidx=startidx+slength-1;
figure;
subplot(3,1,1),plot(exc(startidx:endidx));
title('Excitation Signal');
subplot(3,1,2),plot(orisig(startidx:endidx));
title('Original Audio Signal');
subplot(3,1,3),plot(reconsig(startidx:endidx));
title('Reconstructed Audio Signal');
end