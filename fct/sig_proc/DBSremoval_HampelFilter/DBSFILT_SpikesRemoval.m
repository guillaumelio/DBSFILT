





function [x]=DBSFILT_SpikesRemoval(spikes, x, sr)
% DBSFILT_SpikesRemoval() -
%     DBSFILT_SpikesRemoval - Remove spectral outliers (spikes) in x, 
%     according to the spikes structure.
%     
%
%    USAGE :
%                x=DBSFILT_SpikesRemoval(spikes, x, sr);
%
%    INPUTS : 
%                - x          ; EEG data (sensors x samples) in microVolt
%                - sr         ; Sampling Rate
%                - spikes     ; Spike structure
%
%    OUTPUT : 
%                - x       ; filtered EEG data. 
%
%                
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Author : G. Lio 
% Centre de Neurosciences Cognitives, CNRS UMR 5229, Lyon, France
% v1.0 November 2012
%
% 


DATAlength=size(x,2);

%) parity check 
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

%)split
Y1=Y(:,1:(FFTlength/2+1));
Y=fliplr(Y);
Y2=0.*Y1;
Y2(:,2:end)=Y(:,1:(FFTlength/2));
Y2(:,1)=Y1(:,1);

%)step 3 - find detected spikes, and spike interpolation

Fdbs=find(spikes(6,:)>0);
nb_spikes=length(Fdbs);

Fres=f(2);
Wl=1;
Wls=round(((Wl/Fres)-1)./2);

for i=1:nb_spikes
    if((Fdbs(i)-Wls)<0)
        Y1w=Y1(:,1:Fdbs(i)+Wls);
        Y2w=Y2(:,1:Fdbs(i)+Wls);
    elseif((Fdbs(i)+Wls)>length(Y1))
        Y1w=Y1(:,Fdbs(i)-Wls:end);
        Y2w=Y2(:,Fdbs(i)-Wls:end);
    else
        Y1w=Y1(:,Fdbs(i)-Wls:Fdbs(i)+Wls);
        Y2w=Y2(:,Fdbs(i)-Wls:Fdbs(i)+Wls);
    end
    
    Y1med=median(Y1w,2);
    Y1(:,Fdbs(i))=Y1med;
    
    Y2med=median(Y2w,2);
    Y2(:,Fdbs(i))=Y2med;
    
end

%)step 4 - Signal reconstruction
Y2=fliplr(Y2);
Y=[Y1(:,1:end-1),Y2(:,1:end-1)];
x = ifft(Y,[],2,'symmetric');

if(DATAlength>FFTlength)
    lastsample=x(:,end)+(x(:,end)-x(:,end-1)); %linear interpolation of the last sample, if necessary.
    x(:,end+1)=lastsample;
end



