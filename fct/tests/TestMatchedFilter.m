


clear all
close all
clc



L=4096;
SR=2048;

time=(1:L)./SR;
f=[130 45];
Asimul=30;
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
    
    


iter=4;
xfilt= MatchedFilter(f,x,SR,iter);

error=xo-xfilt;


figure
subplot(311)
    plot(time,error(1,:),'r');
    axis tight
    grid on
    title('Error channel 1')

subplot(312)
    plot(time,error(2,:),'r');
    axis tight
    grid on
    title('Error channel 2')
    
subplot(313)
    plot(time,error(3,:),'r');
    axis tight
    grid on
    title('Error channel 3')

xo2=reshape(xo,[],1);
xfilt2=reshape(xfilt,[],1);
x2=reshape(x,[],1);

SE=sum((xo2-x2).^2);
MSEnoise=100.*(SE/(sum(xo2.^2)));

SE=sum((xo2-xfilt2).^2);
MSEfilt=100.*(SE/(sum(xo2.^2)));






