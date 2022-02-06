function speechproc()

    % 定义常数
    FL = 80;                % 帧长
    WL = 240;               % 窗长
    P = 10;                 % 预测系数个数
    s = readspeech('voice.pcm',100000);             % 载入语音s
    L = length(s);          % 读入语音长度
    FN = floor(L/FL)-2;     % 计算帧数
    % 预测和重建滤波器
    exc = zeros(L,1);       % 激励信号（预测误差）
    s_rec = zeros(L,1);     % 重建语音
    % 合成滤波器
    exc_syn = zeros(L,1);   % 合成的激励信号（脉冲串）
    s_syn = zeros(L,1);     % 合成语音
    % 变调不变速滤波器
    exc_syn_t = zeros(L,1);   % 合成的激励信号（脉冲串）
    s_syn_t = zeros(L,1);     % 合成语音
    % 变速不变调滤波器（假设速度减慢一倍）
    exc_syn_v = zeros(2*L,1);   % 合成的激励信号（脉冲串）
    s_syn_v = zeros(2*L,1);     % 合成语音

    hw = hamming(WL);       % 汉明窗

    % 滤波器状态，初始为0
    zi=zeros(1,P);     % 预测模型
    rezi=zeros(1,P);   % 重建模型
    synzi=zeros(1,P);  % 合成模型（原本）
    synvzi=zeros(1,P); % 合成模型（变速不变调）
    syntzi=zeros(1,P); % 合成模型（变调不变速）

    % 下一段脉冲起始位置，初始为1
    startidx=1;     % 合成模型（原本）
    startidxv=1;    % 合成模型（变速不变调）
    startidxt=1;    % 合成模型（变调不变速）

    % 共振频率增加150Hz换成极点幅角增量
    increaseAngle=2*pi/8000*150;


    % 依次处理每帧语音
    for n = 3:FN

        % 计算预测系数（不需要掌握）
        s_w = s(n*FL-WL+1:n*FL).*hw;    %汉明窗加权后的语音
        [A E] = lpc(s_w, P);            %用线性预测法计算P个预测系数
                                        % A是预测系数，E会被用来计算合成激励的能量

        if n == 27
        % (3) 在此位置写程序，观察预测系统的零极点图     
            figure,zplane(A,1);
        end

        s_f = s((n-1)*FL+1:n*FL);       % 本帧语音，下面就要对它做处理

        % (4) 在此位置写程序，用filter函数s_f计算激励，注意保持滤波器状态
        [excitation,zf]=filter(A,[1],s_f,zi);
        zi=zf;
        exc((n-1)*FL+1:n*FL) = excitation;

        % (5) 在此位置写程序，用filter函数和exc重建语音，注意保持滤波器状态
        [reconSig,rezf]=filter([1],A,excitation,rezi);
        rezi=rezf;
        s_rec((n-1)*FL+1:n*FL) = reconSig;        %将你计算得到的重建语音写在这里

        % 注意下面只有在得到exc后才会计算正确
        s_Pitch = exc(n*FL-222:n*FL);
        PT = findpitch(s_Pitch);    % 计算基音周期PT（不要求掌握）
        G = sqrt(E*PT);           % 计算合成激励的能量G（不要求掌握）


        % (10) 在此位置写程序，生成合成激励，并用激励和filter函数产生合成语音
        curRange=startidx:PT:n*FL;
        exc_syn(curRange)=G;
        [synSig,synzf]=filter([1],A,exc_syn((n-1)*FL+1:n*FL),synzi);
        synzi=synzf;
        startidx=curRange(length(curRange));
        s_syn((n-1)*FL+1:n*FL) = synSig;   %将你计算得到的合成语音写在这里

        % (11)  不改变基音周期和预测系数，将合成激励的长度增加一倍，再作为filter
        % 的输入得到新的合成语音，听一听是不是速度变慢了，但音调没有变。
        FL_v=FL*2;
        curRangev=startidxv:PT:n*FL_v;
        exc_syn_v(curRangev)=G;
        [synvSig,synvzf]=filter([1],A,exc_syn_v((n-1)*FL_v+1:n*FL_v),synvzi);
        synvzi=synvzf;
        startidxv=curRangev(length(curRangev));
        s_syn_v((n-1)*FL_v+1:n*FL_v) = synvSig;   %将你计算得到的加长合成语音写在这里

        % (13) 将基音周期减小一半，将共振峰频率增加150Hz，重新合成语音，听听是啥感受～
        %计算新极点
        [z,p,k]=tf2zpk(1,A);
        incrementval=sign(angle(p))*increaseAngle;
        new_p=p.*exp(1i.*incrementval);
        [new_B,new_A]=zp2tf(z,new_p,k);
        
        % 合成语音
        curRanget=startidxt:round(PT/2):n*FL;
        exc_syn_t(curRanget)=G;
        [syntSig,syntzf]=filter(new_B,new_A,exc_syn_t((n-1)*FL+1:n*FL),syntzi);
        syntzi=syntzf;
        startidxt=curRanget(length(curRanget));
        s_syn_t((n-1)*FL+1:n*FL) = syntSig;            %将你计算得到的变调合成语音写在这里

    end

    ex9_2_1_6_plot(exc,s,s_rec);
    

    % (6) 在此位置写程序，听一听 s ，exc 和 s_rec 有何区别，解释这种区别
    % 后面听语音的题目也都可以在这里写，不再做特别注明
    sound(s,8000);
    pause(5);
    sound(exc,8000);
    pause(5);
    sound(s_rec,8000);
    pause(5);
    sound(exc_syn,8000);
    pause(5);
    sound(s_syn,8000);
    pause(5);
    sound(exc_syn_t,8000);
    pause(5);
    sound(s_syn_t,8000);
    pause(5);
    sound(exc_syn_v,8000);
    pause(5);
    sound(s_syn_v,8000);

    % 保存所有文件
    writespeech('exc.pcm',exc);
    writespeech('rec.pcm',s_rec);
    writespeech('exc_syn.pcm',exc_syn);
    writespeech('syn.pcm',s_syn);
    writespeech('exc_syn_t.pcm',exc_syn_t);
    writespeech('syn_t.pcm',s_syn_t);
    writespeech('exc_syn_v.pcm',exc_syn_v);
    writespeech('syn_v.pcm',s_syn_v);
return


% 从PCM文件中读入语音
function s = readspeech(filename, L)
    fid = fopen(filename, 'r');
    s = fread(fid, L, 'int16');
    fclose(fid);
return

% 写语音到PCM文件中
function writespeech(filename,s)
    fid = fopen(filename,'w');
    fwrite(fid, s, 'int16');
    fclose(fid);
return

% 计算一段语音的基音周期，不要求掌握
function PT = findpitch(s)
[B, A] = butter(5, 700/4000);
s = filter(B,A,s);
R = zeros(143,1);
for k=1:143
    R(k) = s(144:223)'*s(144-k:223-k);
end
[R1,T1] = max(R(80:143));
T1 = T1 + 79;
R1 = R1/(norm(s(144-T1:223-T1))+1);
[R2,T2] = max(R(40:79));
T2 = T2 + 39;
R2 = R2/(norm(s(144-T2:223-T2))+1);
[R3,T3] = max(R(20:39));
T3 = T3 + 19;
R3 = R3/(norm(s(144-T3:223-T3))+1);
Top = T1;
Rop = R1;
if R2 >= 0.85*Rop
    Rop = R2;
    Top = T2;
end
if R3 > 0.85*Rop
    Rop = R3;
    Top = T3;
end
PT = Top;
return