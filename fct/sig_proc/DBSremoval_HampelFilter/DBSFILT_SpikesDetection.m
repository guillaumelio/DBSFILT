





function [Spikes, nb_spikes]=DBSFILT_SpikesDetection(Spikes, type, HampelL, HampelT, FdbsL, FdbsR, nmax, eps)
% DBSFILT_SpikesDetection() -
%     DBSFILT_SpikesDetection - Works with DBSFILT_PrepareSpikesDetection()
%     to detect spectral outliers according one of the following methods :
%     - type 1 : Hampel identifier
%     - type 2 : Hampel identifier + aliasing frequencies identification
%     
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



Y=Spikes(2,:)'; % Mean spectrum
Fres=Spikes(1,2); % frequency resolution
WL=round(HampelL./Fres); % windows length in the frequency space
nbW=floor(length(Y)/WL); % number of full length windows
L=nbW*WL; % length of reduced data

Ya=Y(1:L);
Yb=Y((end-(WL-1)):end);

%) epoch the data
Ya=reshape(Ya,WL,nbW);
Ya=Ya';
%) calculate the Hampel identifier for each epoch 
YaMedian=median(Ya,2);
YaThres=HampelT.*1.4286.*YaMedian;
%) Transform to a linear threshold
YaMedianLin=kron(ones(1,WL),YaMedian);
YaThresLin=kron(ones(1,WL),YaThres);
YaMedianLin=reshape(YaMedianLin',[],1);
YaThresLin=reshape(YaThresLin',[],1);

%) Last epoch processing
YbMedian=median(Yb);
YbThres=HampelT.*1.4286.*YbMedian;
YbMedianLin=kron(ones(1,WL),YbMedian);
YbThresLin=kron(ones(1,WL),YbThres);

%) merge epochs
Ymedian=0.*Y;
Ythres=0.*Y;
Ymedian(1:L)=YaMedianLin;
Ythres(1:L)=YaThresLin;
Ymedian((end-(WL-1)):end)=YbMedianLin;
Ythres((end-(WL-1)):end)=YbThresLin;

Spikes(3,:)=Ymedian;
Spikes(4,:)=Ythres;
Spikes(5,:)=Y>Ythres;
Spikes(6,:)=Y>Ythres;

nb_spikes=sum(Spikes(5,:));

if(type==2) % launch Spikes Identification
   
    SpikesIndex=find(Spikes(5,:)==1);
    for spk=1:nb_spikes

        Fs=Spikes(1,SpikesIndex(spk));
        [dbs_induced,n,h]=DBSFILT_testspike(Fs,FdbsL,FdbsR,nmax,eps,0);
        Spikes(6,SpikesIndex(spk))=dbs_induced;
        Spikes(7,SpikesIndex(spk))=n;
        Spikes(8,SpikesIndex(spk))=h;

    end
    
    nb_spikes=sum(Spikes(6,:));
    
end


