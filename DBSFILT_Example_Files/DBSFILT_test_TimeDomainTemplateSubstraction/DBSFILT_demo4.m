


%% DBSFILT SCRIPT DEMO 4
% Author : G. Lio 
% Centre de Neurosciences Cognitives, CNRS UMR 5229, Lyon, France
% v1.0 2016
%%
%
%   Test adaptive template substraction technique based on 
%   k-means clustering of automatically detected DBS peaks 
%   in the temporal domain. 
%  (inspired by the MAS technique - Sun and Hinrichs 2016 - 
%   Not recommanded / for demonstration only ).
%
%% 
%% 1- Script initialisation

clear all
close all
clc

fprintf('Welcome to the DBSFILT script demo\n-----------------------------------\n\n')

%% 2- User parameters

%) A- file
filename='DBSFILT_P1_dbs_ON_EC.set';


%% 3- Pre-filtering High pass filter parameters

 % High pass filter
    Fcut2=0.75;          % cutting frequency (Hz)
    Fbandwidth2=0.5;     % transition and width (Hz)
    Aattenuation2=120;   % amplitude attenuation (dB)
    Aripple2=0.01;       % ripple in the stop band (dB)
    
    % Edge effet suppression
    Tcut=1; % Time window (s) to supress to avoid edge effects. 
  

%% Pre-filtering steps.

%) A- load data
EEG=pop_loadset(filename); 

%) B- pre-filtering
% remove low frequency drifts and others low frequency artefacts
EEG.data=DBSFILT_highpassfilter(EEG.data,EEG.srate,Fcut2,Fbandwidth2,Aattenuation2,Aripple2);
EEG=pop_select(EEG, 'time', [Tcut EEG.xmax-Tcut]);

%) Upsampling
% upsampling for a better artefact identification and simplification for
% the treatment of the clock drift between the stimulation and the
% recording device.
upsamprate=20;
EEG2=pop_resample(EEG,EEG.srate*upsamprate);

%%

%) Identification of the lead channel
% This step identify the channel were the stimulation artefact can be accurately detected.
% The method is equivalent than Sun and Hinrichs 2016. 
fprintf('\nDBSFILT >> Best Matching Template (BMT) filtering : Identification of the lead sensor.\n');
    
    % Low pass filter
    N  = 3;    % order
    Fc = 100;  % cutting frequency (Hz)

    h  = fdesign.lowpass('N,F3dB', N, Fc, EEG2.srate);
    Hd = design(h, 'butter');
    
    nbchan=size(EEG2.nbchan,1);
    fprintf('DBSFILT >> Fast Low pass Filtering :\n'); 
    EEGfilt=EEG2.data;
    for i=1:EEG2.nbchan
        fprintf('DBSFILT >> Filtering channel %d ... \n',i);
        reset(Hd);
        EEGfilt(i,:)=filtfilthd(Hd,EEG2.data(i,:));

    end 
    disp('DBSFILT >> Fast Low pass Filtering : OK.')

VARraw=var(EEG2.data,0,2);
VARcleen=var(EEGfilt,0,2);
ABR=VARraw./VARcleen; 
    
    figure
    bar(ABR)
    grid on
    title('Artefact to Background amplitude Ratio - (ABR)')

MAS_LeadSensor=find(ABR==max(ABR),1,'first');
fprintf('DBSFILT >> BMT filtering : Lead Sensor = %d. ABR= %0.2f.\n',MAS_LeadSensor,max(ABR));
    
%%

%) Determination of the DBS artefact onset and duration.

%  %) Step 1 : Localization of the artefact peaks in the lead channel. 

     PPVseglen=6; % segment length for estimation of the DBS threshold
     PPVfreqestimated=130; % estimated frequency for spike detection in the temporal space - here 2xDBS frequency (alterning Left and Right stimulation for the current DBS stimulator.)
     
     index=round(rand(1)*EEG2.pnts);
     nb_samp=PPVseglen*EEG2.srate;
     nb_samp2=round(0.1*EEG2.srate);
     nb_samp=round(nb_samp/nb_samp2)*nb_samp2; % check nb_samp multiple of 0.1s.
     if(index+nb_samp>EEG2.pnts)
         index2=index;
         index1=index-nb_samp+1;
     else
         index1=index;
         index2=index+nb_samp-1;
     end
     
      Xfree=EEGfilt(MAS_LeadSensor,index1:index2);
      Xartefact=EEG2.data(MAS_LeadSensor,index1:index2);
      Xfree=reshape(Xfree,nb_samp2,[]);
      Xartefact=reshape(Xartefact,nb_samp2,[]);
      XfreePPV=-min(Xfree,[],1)+max(Xfree,[],1);
      XartefactPPV=-min(Xartefact,[],1)+max(Xartefact,[],1);
      
      PPVfree=mean(XfreePPV);
      PPVartefact=mean(XartefactPPV);
      
      MAS_thresI=0.6; % = 0.25 in the Sun and Hinrichs paper - Here 0.6 to capture a 130 Hz signal considering the 2 stimulation electrodes.
      MAS_thres= 0.5*PPVfree+MAS_thresI*0.5*(PPVartefact-PPVfree);
      
     
     %
     close all
     figure
     subplot(2,2,[1 2])
     hold on
     plot(Xartefact,'b')
     plot(Xfree,'g')
     plot(ones(1,size(Xfree,1))*MAS_thres,'r')
     hold off
     grid on
     axis tight
     title('Threshold for artefacts detection')
     
     subplot(2,2,3)
     hist(XfreePPV);
     title('PPV_{free}')
     grid on
     axis tight
     
     subplot(2,2,4)
     hist(XartefactPPV);
     title('PPV_{artefact}')
     grid on
     axis tight
     
     % launch peaks detection
     
     index=1;
     cpt=1;
     steprate=0.75; % 0.5 in Sun and Hinrichs paper - 0.75 when two synchronized stimulators are used (alternating Left Right Deep Brain Stimulations).  
     step=round(steprate*(1/PPVfreqestimated)*EEG2.srate);
%      while index<EEG2.pnts
%          spikeindex(cpt)=find(EEG2.data(MAS_LeadSensor,index:end)>MAS_thres,1,'first');
%          cpt=cpt+1;
%          index=index+step;
%          fprintf('%0.2f %%\n',100*(index/EEG2.pnts))
%      end
    
      spikeindex=find(EEG2.data(MAS_LeadSensor,:)>MAS_thres);
      bin=zeros(1,EEG2.pnts);  
      bin(spikeindex)=1;
      bin=diff(bin);
      spikeindex=find(bin==1)+1;
      bin=zeros(1,EEG2.pnts);  
      bin(spikeindex)=1;
      spikeAI=diff(spikeindex);
      
      figure
      subplot(211)
      hold on
      plot(EEG2.data(MAS_LeadSensor,1:1000));
      plot(bin(1:1000).*max(EEG2.data(MAS_LeadSensor,1:1000)));
      title('Visualization of spikes detection.')
      hold off
      grid on
      subplot(212)
      hist(spikeAI,100);
      title('Distribution of inter-detections intervals.')
        
      AIm=mean(spikeAI);
      AIf=1/(AIm/EEG2.srate);

     fprintf('First pass : %d detected spikes - Aver. Int. = %0.6f samples - Frequ = %.6f Hz.\n',length(spikeindex),AIm,AIf);
     
     %%
     spikeindexInit=spikeindex(1);
     spikeindexEnd=spikeindex(end);
     spikeindex=spikeindex(1:end-1); % we ignore the last and incomplete detected artefact. 
     decal=0;
     period=floor(AIm);
     indices(:,1)=spikeindex-decal;
     indices(:,2)=spikeindex-decal+period-1;
     
     nb_epochs=length(spikeindex);
     ChannelSpikes=zeros(EEG.nbchan,period,nb_epochs);
     for i=1:nb_epochs
         ChannelSpikes(:,:,i)=EEG2.data(:,indices(i,1):indices(i,2));
     end
     
     
     %%
     
     %) K-means clustering to creat a dictionnary of artefacts templates and
     %  for the identification of these templates in the data.
     %  This step is an optimisation of the resampling procedure of Sun and
     %  Hinrichs 2016.
     
     nb_clust=10;
     idx=zeros(nb_epochs,EEG.nbchan);
     C=zeros(nb_clust,period,EEG.nbchan);
     for i=1:EEG.nbchan
         fprintf('DBSFILT >> K-means clustering - process channel %d - %d artefacts templates...\n',i,nb_clust)
        %[idx(:,i),C(:,:,i)] = kmeans(squeeze(ChannelSpikes(i, :,:))',nb_clust,'Maxiter',300,'Replicates',2);
        [idx(:,i),C(:,:,i)] = kmeans(squeeze(ChannelSpikes(i, :,:))',nb_clust,'Maxiter',300);
        % equiv :
        %currentchannel=squeeze(ChannelSpikes(i, :,:))';
        %[idx(:,i),C(:,:,i)] = kmeans(currentchannel,6);
     end
     fprintf('DBSFILT >> K-means clustering - Done.\n')
    
     %%
     
     M=mean(ChannelSpikes,3);
     
     figure
     subplot(311)
     plot(M');
     grid on
     title('Mean template for all channels')
     
     subplot(312)
     plot(squeeze(C(:,:,MAS_LeadSensor))');
     grid on
     title('Dictionnary of resampling schemes for the lead sensor.')
    
     
     subplot(313)
     bar(idx(1:1000,MAS_LeadSensor))
     axis tight
     title('Schemes classification of the 1000 first detections')
     
     
%%     
     
     figure
     imagesc(idx(1:500,:)')
     xlabel('Detected artefacts')
     ylabel('Channels')
     title('Schemes classification of the 500 first detections')
     colorbar
     
     
     %%
     
     %) DBS artefact whole template reconstruction
     ChannelDBS=ChannelSpikes;
     C2=permute(C,[3,2,1]);
     
     for i=1:EEG.nbchan 
        for j=1:nb_epochs
            ChannelDBS(i,:,j)=C2(i,:,idx(j,i));
        end
        %fprintf('%0.2f %%\n',100*(i/nb_epochs))
        fprintf('DBSFILT >> Reconstruction of the artifactual DBS signal : channel %d.\n',i)
        
     end
     
     
     %%
     ChannelCleen=ChannelSpikes-ChannelDBS;
     
     %% crop the data to the first detection to the last
     
     EEG2=pop_select(EEG2, 'point', [spikeindexInit spikeindexEnd-1]);

     %%
     ChannelCleen=reshape(ChannelCleen,EEG2.nbchan,[]);
     
     %% resampling correction
     EEG2.data=interpft(ChannelCleen,EEG2.pnts,2);
     %EEG2.data=ChannelCleen;
     %%
     
    Fmin=1;     % Lower frequency to display 
    Fmax=300;   % Higher frequency to display 
    
     str_title='High resolution power spectrum of the cleaned data. ( DBS @130Hz )';
     DBSFILT_display_rawfftspectra(EEG2.data,EEG2.srate,Fmin,Fmax,str_title)
   
     %% Power spectral density
     
     Fmin=1;     % Lower frequency to display 
     Fmax=80;   % Higher frequency to display 
    
     segmentLength = EEG2.srate;
     noverlap = round(segmentLength/2);
     [pxx, f] = pwelch(EEG2.data',segmentLength,noverlap,segmentLength,EEG2.srate);
     
     index1=find(f>=Fmin,1,'first');
     index2=find(f>=Fmax,1,'first');
     f=f(index1:index2);
     pxx=pxx(index1:index2,:);
     
     for i=1:EEG2.nbchan
        pxx(:,i)=pxx(:,i)./sum(pxx(:,i));
     end
     
     figure
     plot(f, 10*log10(pxx))
     grid on
     title('Relative Power spectral density estimation of the cleaned data (low frequency resolution).')
     xlabel('Frequencies (Hz)')
     ylabel('10 Log10 (Relative power)')
     
     
%      M=mean(ChannelSpikes,3);
%      
%      figure
%      subplot(211)
%      plot(M');
%      grid on
%      title('Mean template')
%      
%      nb_samp=size(M,2);
%      smax=floor(nb_samp/upsamprate);
%      ResampSchemes=zeros(upsamprate,smax);
%      for i=1:upsamprate
%          a=M(MAS_LeadSensor,i:upsamprate:nb_samp);
%          ResampSchemes(i,:)=a(1:smax);
%      end
%      
%      subplot(212)
%      plot(ResampSchemes');
%      grid on
%      title('Dictionnary of resampling schemes for the lead sensor.')
     
         
     
     
     
     



