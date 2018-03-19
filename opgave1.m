%% Midlingsfiltre
%  Vis hvordan midlingsfiltre kan reducere variansen (effekten) af 
%  støjen i støjfyldte DC-signaler.
%  Kigger først på 
%      1) MA-filter
%  Ref.: Lyons, chap. 11.5
%  KPL 2017-03-15

%% Generelt setup:
clear; close all; clc; format compact
Nfft = 2048;
k = 0:Nfft-1;
N = 2500;          %    <-- prøv N = 1e5, hvis teorien skal passe...
n = 0:N-1;


%% Indlæsning af data, samt skabelse af 2 dele af disse

load('vejecelle_data.mat');
x = vejecelle_data;
x1 = vejecelle_data(1:1000);
n1 = (1:1000);
N1 = 1000;
x2 = vejecelle_data(1050:2500);
n2 = (1050:2500);
N2 = 1450;

figure
subplot(2,2,1:2)
plot(n,x), grid
xlabel('n'), ylabel('x(n)'), title('hele signalet DC-signal')

subplot(2,2,3)
plot(n1,x1), grid
xlabel('n'), ylabel('x(n)'), title('første del af DC-signal')

subplot(2,2,4)
plot(n2,x2), grid
xlabel('n'), ylabel('x(n)'), title('anden del af DC-signal')

%% MA-filter (ikke-rekursivt) for første del
M = 16;    % <-- antal filterkoefficienter, prøv med f.eks. 5, 16, 35, 100
hMA = 1/M*ones(1,M); % MA-filter, filterkoefficienter

hMA_imp_resp  = hMA;                        % impulsrespons
hMA_step_resp = filter(hMA,1,ones(1,2*M));  % steprespons
L_MA_trans_resp = M-1;                      % længde af transientrespons
HMA1 = fft(hMA,Nfft);                        % frekvensrespons

yMA1 = filter(hMA,1,x1);                      % filtrerer inputsignal

var_x1 = var(x1(M:N1));      % varians i signal i del efter transientrespons
var_yMA1 = var(yMA1(M:N1));  % varians i signal i del efter transientrespons

% --- kun plotting herunder ---
figure('name', 'første MA-filter')
subplot(2,6,1:3)
stem(0:M-1,hMA_imp_resp)
axis([0 M-1 0 3/2*max(hMA)])
xlabel('n'), title('impulsrespons 1 del')

subplot(2,6,4:6)
stem(0:2*M-1,hMA_step_resp)
line([L_MA_trans_resp L_MA_trans_resp],[0 3/2],'color','r','linestyle',':')
axis([0 2*M-1,0 3/2*max(hMA_step_resp)])
xlabel('n'), title('steprespons 1 del')

subplot(2,6,7:8)
zplane(hMA,1)
title('pol-nulpunktsdiagram 1 del')
subplot(2,6,9:10)
plot(k/Nfft*2*pi,abs(HMA1)),xlim([0 pi])
title('amplituderespons 1 del'),xlabel('\omega'),ylabel('|H(e^{j\omega})|')
subplot(2,6,11:12)
plot(k/Nfft*2*pi,angle(HMA1)),xlim([0 pi])
title('faserespons 1 del'),xlabel('\omega'),ylabel('\angleH(e^{j\omega})')

figure('name', 'første MA-filter')
subplot(3,1,1:2)
plot(n1,x1), grid, hold on
plot(n1,yMA1,'linewidth',2)
xlabel('n'), ylabel('x(n)'), title(['MA-filter, M = ' num2str(M)])
legend('input','output')
subplot(3,1,3)
text(0,0.5,...
    {['første MA-filter, M = ' num2str(M)],...
     ['Transientrespons: ' num2str(L_MA_trans_resp) ' samples'],...
     ['Støjeffekt i inputsignal (varians):  ' num2str(var_x1)],...
     ['Støjeffekt i outputsignal (varians): ' num2str(var_yMA1)],...
     ['Reduktion i støjeffekt: ' num2str((var_x1/var_yMA1)) ' gange'],...
     ['Reduktion i støjeffekt: ' num2str(10*log10(var_x1/var_yMA1)) ' dB']})
 axis off

%% MA-filter (ikke-rekursivt) for anden del
M = 16;    % <-- antal filterkoefficienter, prøv med f.eks. 5, 16, 35, 100
hMA = 1/M*ones(1,M); % MA-filter, filterkoefficienter

hMA_imp_resp  = hMA;                        % impulsrespons
hMA_step_resp = filter(hMA,1,ones(1,2*M));  % steprespons
L_MA_trans_resp = M-1;                      % længde af transientrespons
HMA = fft(hMA,Nfft);                        % frekvensrespons

yMA2 = filter(hMA,1,x2);                      % filtrerer inputsignal

var_x = var(x2(M:N2));      % varians i signal i del efter transientrespons
var_yMA = var(yMA2(M:N2));  % varians i signal i del efter transientrespons

% --- kun plotting herunder ---
figure('name', 'andet MA-filter')
subplot(2,6,1:3)
stem(0:M-1,hMA_imp_resp)
axis([0 M-1 0 3/2*max(hMA)])
xlabel('n'), title('impulsrespons')

subplot(2,6,4:6)
stem(0:2*M-1,hMA_step_resp)
line([L_MA_trans_resp L_MA_trans_resp],[0 3/2],'color','r','linestyle',':')
axis([0 2*M-1,0 3/2*max(hMA_step_resp)])
xlabel('n'), title('steprespons')

subplot(2,6,7:8)
zplane(hMA,1)
title('pol-nulpunktsdiagram')
subplot(2,6,9:10)
plot(k/Nfft*2*pi,abs(HMA)),xlim([0 pi])
title('amplituderespons'),xlabel('\omega'),ylabel('|H(e^{j\omega})|')
subplot(2,6,11:12)
plot(k/Nfft*2*pi,angle(HMA)),xlim([0 pi])
title('faserespons'),xlabel('\omega'),ylabel('\angleH(e^{j\omega})')

figure('name', 'andet MA-filter')
subplot(3,1,1:2)
plot(n2,x2), grid, hold on
plot(n2,yMA2,'linewidth',2)
xlabel('n'), ylabel('x(n)'), title(['MA-filter, M = ' num2str(M)])
legend('input','output')
subplot(3,1,3)
text(0,0.5,...
    {['MA-filter, M = ' num2str(M)],...
     ['Transientrespons: ' num2str(L_MA_trans_resp) ' samples'],...
     ['Støjeffekt i inputsignal (varians):  ' num2str(var_x)],...
     ['Støjeffekt i outputsignal (varians): ' num2str(var_yMA)],...
     ['Reduktion i støjeffekt: ' num2str((var_x/var_yMA)) ' gange'],...
     ['Reduktion i støjeffekt: ' num2str(10*log10(var_x/var_yMA)) ' dB']})
 axis off

