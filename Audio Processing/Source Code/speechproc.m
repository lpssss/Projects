function speechproc()

    % ���峣��
    FL = 80;                % ֡��
    WL = 240;               % ����
    P = 10;                 % Ԥ��ϵ������
    s = readspeech('voice.pcm',100000);             % ��������s
    L = length(s);          % ������������
    FN = floor(L/FL)-2;     % ����֡��
    % Ԥ����ؽ��˲���
    exc = zeros(L,1);       % �����źţ�Ԥ����
    s_rec = zeros(L,1);     % �ؽ�����
    % �ϳ��˲���
    exc_syn = zeros(L,1);   % �ϳɵļ����źţ����崮��
    s_syn = zeros(L,1);     % �ϳ�����
    % ����������˲���
    exc_syn_t = zeros(L,1);   % �ϳɵļ����źţ����崮��
    s_syn_t = zeros(L,1);     % �ϳ�����
    % ���ٲ�����˲����������ٶȼ���һ����
    exc_syn_v = zeros(2*L,1);   % �ϳɵļ����źţ����崮��
    s_syn_v = zeros(2*L,1);     % �ϳ�����

    hw = hamming(WL);       % ������

    % �˲���״̬����ʼΪ0
    zi=zeros(1,P);     % Ԥ��ģ��
    rezi=zeros(1,P);   % �ؽ�ģ��
    synzi=zeros(1,P);  % �ϳ�ģ�ͣ�ԭ����
    synvzi=zeros(1,P); % �ϳ�ģ�ͣ����ٲ������
    syntzi=zeros(1,P); % �ϳ�ģ�ͣ���������٣�

    % ��һ��������ʼλ�ã���ʼΪ1
    startidx=1;     % �ϳ�ģ�ͣ�ԭ����
    startidxv=1;    % �ϳ�ģ�ͣ����ٲ������
    startidxt=1;    % �ϳ�ģ�ͣ���������٣�

    % ����Ƶ������150Hz���ɼ����������
    increaseAngle=2*pi/8000*150;


    % ���δ���ÿ֡����
    for n = 3:FN

        % ����Ԥ��ϵ��������Ҫ���գ�
        s_w = s(n*FL-WL+1:n*FL).*hw;    %��������Ȩ�������
        [A E] = lpc(s_w, P);            %������Ԥ�ⷨ����P��Ԥ��ϵ��
                                        % A��Ԥ��ϵ����E�ᱻ��������ϳɼ���������

        if n == 27
        % (3) �ڴ�λ��д���򣬹۲�Ԥ��ϵͳ���㼫��ͼ     
            figure,zplane(A,1);
        end

        s_f = s((n-1)*FL+1:n*FL);       % ��֡�����������Ҫ����������

        % (4) �ڴ�λ��д������filter����s_f���㼤����ע�Ᵽ���˲���״̬
        [excitation,zf]=filter(A,[1],s_f,zi);
        zi=zf;
        exc((n-1)*FL+1:n*FL) = excitation;

        % (5) �ڴ�λ��д������filter������exc�ؽ�������ע�Ᵽ���˲���״̬
        [reconSig,rezf]=filter([1],A,excitation,rezi);
        rezi=rezf;
        s_rec((n-1)*FL+1:n*FL) = reconSig;        %�������õ����ؽ�����д������

        % ע������ֻ���ڵõ�exc��Ż������ȷ
        s_Pitch = exc(n*FL-222:n*FL);
        PT = findpitch(s_Pitch);    % �����������PT����Ҫ�����գ�
        G = sqrt(E*PT);           % ����ϳɼ���������G����Ҫ�����գ�


        % (10) �ڴ�λ��д�������ɺϳɼ��������ü�����filter���������ϳ�����
        curRange=startidx:PT:n*FL;
        exc_syn(curRange)=G;
        [synSig,synzf]=filter([1],A,exc_syn((n-1)*FL+1:n*FL),synzi);
        synzi=synzf;
        startidx=curRange(length(curRange));
        s_syn((n-1)*FL+1:n*FL) = synSig;   %�������õ��ĺϳ�����д������

        % (11)  ���ı�������ں�Ԥ��ϵ�������ϳɼ����ĳ�������һ��������Ϊfilter
        % ������õ��µĺϳ���������һ���ǲ����ٶȱ����ˣ�������û�б䡣
        FL_v=FL*2;
        curRangev=startidxv:PT:n*FL_v;
        exc_syn_v(curRangev)=G;
        [synvSig,synvzf]=filter([1],A,exc_syn_v((n-1)*FL_v+1:n*FL_v),synvzi);
        synvzi=synvzf;
        startidxv=curRangev(length(curRangev));
        s_syn_v((n-1)*FL_v+1:n*FL_v) = synvSig;   %�������õ��ļӳ��ϳ�����д������

        % (13) ���������ڼ�Сһ�룬�������Ƶ������150Hz�����ºϳ�������������ɶ���ܡ�
        %�����¼���
        [z,p,k]=tf2zpk(1,A);
        incrementval=sign(angle(p))*increaseAngle;
        new_p=p.*exp(1i.*incrementval);
        [new_B,new_A]=zp2tf(z,new_p,k);
        
        % �ϳ�����
        curRanget=startidxt:round(PT/2):n*FL;
        exc_syn_t(curRanget)=G;
        [syntSig,syntzf]=filter(new_B,new_A,exc_syn_t((n-1)*FL+1:n*FL),syntzi);
        syntzi=syntzf;
        startidxt=curRanget(length(curRanget));
        s_syn_t((n-1)*FL+1:n*FL) = syntSig;            %�������õ��ı���ϳ�����д������

    end

    ex9_2_1_6_plot(exc,s,s_rec);
    

    % (6) �ڴ�λ��д������һ�� s ��exc �� s_rec �к����𣬽�����������
    % ��������������ĿҲ������������д���������ر�ע��
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

    % ���������ļ�
    writespeech('exc.pcm',exc);
    writespeech('rec.pcm',s_rec);
    writespeech('exc_syn.pcm',exc_syn);
    writespeech('syn.pcm',s_syn);
    writespeech('exc_syn_t.pcm',exc_syn_t);
    writespeech('syn_t.pcm',s_syn_t);
    writespeech('exc_syn_v.pcm',exc_syn_v);
    writespeech('syn_v.pcm',s_syn_v);
return


% ��PCM�ļ��ж�������
function s = readspeech(filename, L)
    fid = fopen(filename, 'r');
    s = fread(fid, L, 'int16');
    fclose(fid);
return

% д������PCM�ļ���
function writespeech(filename,s)
    fid = fopen(filename,'w');
    fwrite(fid, s, 'int16');
    fclose(fid);
return

% ����һ�������Ļ������ڣ���Ҫ������
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