

function DBSFILT_display_rawfftspectra(x,sr,Fmin,Fmax,str_title)

%disp('DBSFILT >> Process fft... Please wait.')
%tic

L=size(x,2);

%) parity check
if((L/2)~=round(L/2))
    x=x(:,1:end-1);
end

%) process fft
Y = fft(x,[],2);
f = sr/2*linspace(0,1,L/2+1);

%disp('DBSFILT >> Process fft... Done.')
%toc

%) select data
fmin_index=find(f>=Fmin,1,'first');
fmax_index=find(f>=Fmax,1,'first');

f=f(fmin_index:fmax_index);
Y=Y(:,fmin_index:fmax_index);

%) plot mean amplitude spectrum
Y=2*abs(Y);
Y=mean(Y);

fig=figure;
set(fig, 'color',get(0,'defaultUicontrolBackgroundColor'));
plot(f,Y,'LineWidth',2,'Color',[0.2 0.4 1]);
axis tight
grid on
xlabel('Frequency (Hz)')
ylabel('Mean amplitude spectrum')
title(str_title)




