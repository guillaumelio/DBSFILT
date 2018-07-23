





function [Spikes, FFTlength, DATAlength]=DBSFILT_PrepareSpikesDetection(x,sr)
% DBSFILT_PrepareSpikesDetection() -
%     DBSFILT_PrepareSpikesDetection - Works with DBSFILT_SpikesDetection()
%     to detect spectral outliers.
%
%    USAGE :
%                   e.g.
%                   [spikes, FFTlength, DATAlength]=DBSFILT_PrepareSpikesDetection(x,sr);
%                   [spikes, nb_spikes]=DBSFILT_SpikesDetection(spikes, type, HampelL, HampelT, FdbsL, FdbsR, nmax, eps);
%                
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Author : G. Lio 
% Centre de Neurosciences Cognitives, CNRS UMR 5229, Lyon, France
% v1.0 November 2012
%
% 

tic

DATAlength=size(x,2);

%) parity check
if((DATAlength/2)~=round(DATAlength/2))
    x=x(:,1:end-1);
    FFTlength=DATAlength-1;
else
    FFTlength=DATAlength;
end

%) process fft
fprintf('DBSFILT >> Process fft...  ')
Y = fft(x,[],2);
Y=2*abs(Y);
f = sr/2*linspace(0,1,FFTlength/2+1);
fprintf('Done.\n')

%)split
if(isvector(Y))
    Ym=Y;
else
    Ym=mean(Y);
end
Ym1=Ym(1:(FFTlength/2+1));

%)prepare Spikes matrix
Spikes=zeros(8,length(f));
Spikes(1,:)=f;
Spikes(2,:)=Ym1;





