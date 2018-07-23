


clear all
close all
clc


%% Init simulation

L=16384;  % data length
SR=2048; % sampling rate 

time=(1:L)./SR;
f=[130 45]; % Noise frequencies
Asimul=30; % Noise amplitude 
LagSimul=round(rand(1)*100);

noise1=Asimul*sin((2*pi*f(1)).*(((1:L)+LagSimul)./SR));
noise2=0.4*Asimul*sin((2*pi*f(2)).*(((1:L)+LagSimul)./SR));
noise=noise1+noise2;

xo=randn(3,L);
x(1,:)=xo(1,:)+noise;
x(2,:)=xo(2,:)+0.5*noise;
x(3,:)=xo(3,:)+0.1*noise;

figure
subplot(411)
    plot(time,noise,'r');
    axis tight
    grid on
    title('Noise')

subplot(412)
    hold on
    plot(time,x(1,:),'r');
    plot(time,xo(1,:));
    hold off
    axis tight
    grid on
    title('Channel 1')
    
subplot(413)
    hold on
    plot(time,x(2,:),'r');
    plot(time,xo(2,:));
    hold off
    axis tight
    grid on
    title('Channel 2')
    
 subplot(414)
    hold on
    plot(time,x(3,:),'r');
    plot(time,xo(3,:));
    hold off
    axis tight
    grid on
    title('Channel 3')
    
    Fmin=0;
    Fmax=300;
    str_title='raw fft spectrum';
    DBSFILT_display_rawfftspectra(x,SR,Fmin,Fmax,str_title)
          
    [spikes, FFTlength, DATAlength]=DBSFILT_PrepareSpikesDetection(x,SR);
    type=1; % Hampel identifier only
    HampelL=2; % windows size for automatic spike detection (Hz) 
    HampelT=3; % Hampel threshold for automatic spike detection.
    
    FdbsL=130;  % not used - only for type 2
    FdbsR=45;   % not used - only for type 2
    nmax=5;     % not used - only for type 2
    eps=0.002;  % not used - only for type 2 
    
    
    [spikes, nb_spikes]=DBSFILT_SpikesDetection(spikes, type, HampelL, HampelT, FdbsL, FdbsR, nmax, eps);
    FlagSpikes=1;
    str_title='automatic detection of outlier frequencies';
    DBSFILT_display_rawfftspectraFAST(spikes,FlagSpikes,Fmin,Fmax,str_title)
    
    
    % filtering... using user determined matched filters. 
    iter=2;
    xfilt= MatchedFilter(f,x,SR,iter);
    
    % filtering... using automatically detected outlier frequencies.
    xfilt2=DBSFILT_SpikesRemoval(spikes, x, SR);
    
    
    
    error=xo-xfilt;
    error2=xo-xfilt2;

    str_title=sprintf('Matched filter - iter=%d - spectral error',iter);
    DBSFILT_display_rawfftspectra(error,SR,Fmin,Fmax,str_title)
    
    str_title=sprintf('Hampel filter - Windows Length = %d Hz - Threshold = %d - spectral error',HampelL,HampelT);
    DBSFILT_display_rawfftspectra(error2,SR,Fmin,Fmax,str_title)
    

figure
subplot(321)
    plot(time,error(1,:),'r');
    axis tight
    grid on
    title('Error channel 1')

subplot(323)
    plot(time,error(2,:),'r');
    axis tight
    grid on
    title('Error channel 2')
    
subplot(325)
    plot(time,error(3,:),'r');
    axis tight
    grid on
    title('Error channel 3')

subplot(322)
    plot(time,error2(1,:),'r');
    axis tight
    grid on
    title('Error2 channel 1')

subplot(324)
    plot(time,error2(2,:),'r');
    axis tight
    grid on
    title('Error2 channel 2')
    
subplot(326)
    plot(time,error2(3,:),'r');
    axis tight
    grid on
    title('Error2 channel 3')
    
    
xoB=reshape(xo,[],1);
xfiltB=reshape(xfilt,[],1);
xB=reshape(x,[],1);

xfilt2B=reshape(xfilt2,[],1);



SE=sum((xoB-xB).^2);
MSEnoise=100.*(SE/(sum(xoB.^2)));

SE=sum((xoB-xfiltB).^2);
MSEfilt=100.*(SE/(sum(xoB.^2)));

SE=sum((xoB-xfilt2B).^2);
MSEfilt2=100.*(SE/(sum(xoB.^2)));








