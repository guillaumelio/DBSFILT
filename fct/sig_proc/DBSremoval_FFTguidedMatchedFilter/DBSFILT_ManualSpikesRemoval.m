




function [x]=DBSFILT_ManualSpikesRemoval(TargetF,WinWidth,nbspikes, x, sr)
% DBSFILT_ManualSpikesRemoval() -
%     DBSFILT_ManualSpikesRemoval - Interpolate for the data 'x', sampled at
%     'sr' Hz, the 'nbspikes' most energetic frequencies on a frequency band
%     centered on 'TargetF' (Hz) of width 'WinWidth' (Hz).
%     
%
%    USAGE :
%                   e.g.
%                   x=DBSFILT_ManualSpikesRemoval(50,2,20, x, 2048);
%                
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Author : G. Lio 
% Centre de Neurosciences Cognitives, CNRS UMR 5229, Lyon, France
% v1.0 November 2012
%
%


DATAlength=size(x,2);

%) step 1 - parity check 
if((DATAlength/2)~=round(DATAlength/2))
    x=x(:,1:end-1);
    FFTlength=DATAlength-1;
else
    FFTlength=DATAlength;
end

%) step 2 - transpose data to the frequency space (process fft).
fprintf('DBSFILT >> Process fft...  ')
Y = fft(x,[],2);
f = sr/2*linspace(0,1,FFTlength/2+1);
fprintf('Done.\n');

%) step 3 - split
Y1=Y(:,1:(FFTlength/2+1));
Y=fliplr(Y);
Y2=0.*Y1;
Y2(:,2:end)=Y(:,1:(FFTlength/2));
Y2(:,1)=Y1(:,1);

%) step 4 -  find targeted frequency

F_res=f(2);
F_index=find(f>=TargetF,1,'first');
F_winsize=round((WinWidth/2)/(F_res));

for i=1:nbspikes
    
    Y1med=median(Y1(:,F_index-F_winsize : F_index+F_winsize),2);
    Y2med=median(Y2(:,F_index-F_winsize : F_index+F_winsize),2);
    Y1emean=mean(abs(Y1(:,F_index-F_winsize : F_index+F_winsize)),1);
    Y2emean=mean(abs(Y2(:,F_index-F_winsize : F_index+F_winsize)),1);
    Y1emax=max(Y1emean);
    Y2emax=max(Y2emean);
    Y1emaxID=find(Y1emean==Y1emax,1,'first');
    Y2emaxID=find(Y2emean==Y2emax,1,'first');
    Y1r=Y1(:,F_index-F_winsize : F_index+F_winsize);
    Y2r=Y2(:,F_index-F_winsize : F_index+F_winsize);
    Y1r(:,Y1emaxID)=Y1med;
    Y2r(:,Y2emaxID)=Y2med;
    Y1(:,F_index-F_winsize : F_index+F_winsize)=Y1r;
    Y2(:,F_index-F_winsize : F_index+F_winsize)=Y2r;
    

end

%) step 5 - Signal reconstruction
Y2=fliplr(Y2);
Y=[Y1(:,1:end-1),Y2(:,1:end-1)];
x = ifft(Y,[],2,'symmetric');

if(DATAlength>FFTlength)
    lastsample=x(:,end)+(x(:,end)-x(:,end-1)); %linear interpolation of the last sample, if necessary.
    x(:,end+1)=lastsample;
end







