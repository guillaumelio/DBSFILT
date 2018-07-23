


function [peaks, FirstLastIndex, ABR]=DBSFILT_StimPeaksDetection(x,sr,Fc,PPVseglen,threshold,plotfig)

% DBSFILT_StimPeaksDetection() -
%     DBSFILT_StimPeaksDetection - Temporal domain peaks detection
%     
%
%    USAGE :
%                [peaks, FirstLastIndex, ABR]=DBSFILT_StimPeaksDetection(x,sr,Fc,PPVseglen,threshold,plotfig)
%
%    INPUTS : 
%                - x          ; EEG data (sensors x samples) in microVolt
%                - sr         ; Sampling Rate
%                - Fc         ; Cutting frequency for peaks detection
%                              (below the stimulation frequency)
%                - PPVseglen  ; segment length for threshold calculation
%                              (in s)
%                - threshold  ; detection threshold
%                - plotfig   ; plot figures if plotfig==1
%
%    OUTPUT : 
%                - peaks      ; sensors x samples x peaks matrix
%                - FirstLastIndex ; index of the first and last detection
%                - ABR            ; Electrodes Artefact to Background amplitude Ratio  
%
%                
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\nDBSFILT >> Best Matching Template (BMT) filtering : Identification of the lead sensor.\n');

    % Low pass filter
    N  = 3;    % order
    
    h  = fdesign.lowpass('N,F3dB', N, Fc, sr);
    Hd = design(h, 'butter');
    
    nbchan=size(x,1);
    nbpnts=size(x,2);
    
    fprintf('DBSFILT >> Fast Low pass Filtering :\n'); 
    xfilt=x;
    for i=1:nbchan
        fprintf('DBSFILT >> Filtering channel %d ... \n',i);
        reset(Hd);
        xfilt(i,:)=filtfilthd(Hd,x(i,:));

    end 
    disp('DBSFILT >> Fast Low pass Filtering : OK.')
    
    VARraw=var(x,0,2);
    VARcleen=var(xfilt,0,2);
    ABR=VARraw./VARcleen; 
    
    if(plotfig==1)
        figure
        bar(ABR)
        grid on
        title('Artefact to Background amplitude Ratio - (ABR)')
    end
    
    LeadSensor=find(ABR==max(ABR),1,'first');
    fprintf('DBSFILT >> Lead Sensor for artefacts detection = %d. ABR= %0.2f.\n',LeadSensor,max(ABR));

    %) Determination of the DBS artefact onset and duration.

    %) Step 1 : Localization of the artefact peaks in the lead channel. 
    
     index=round(rand(1)*nbpnts);
     nb_samp=PPVseglen*sr;
     nb_samp2=round(0.1*sr);
     nb_samp=round(nb_samp/nb_samp2)*nb_samp2; % check nb_samp multiple of 0.1s.
     if(index+nb_samp>nbpnts)
         index2=index;
         index1=index-nb_samp+1;
     else
         index1=index;
         index2=index+nb_samp-1;
     end
     
      Xfree=xfilt(LeadSensor,index1:index2);
      Xartefact=x(LeadSensor,index1:index2);
      Xfree=reshape(Xfree,nb_samp2,[]);
      Xartefact=reshape(Xartefact,nb_samp2,[]);
      XfreePPV=-min(Xfree,[],1)+max(Xfree,[],1);
      XartefactPPV=-min(Xartefact,[],1)+max(Xartefact,[],1);
      
      PPVfree=mean(XfreePPV);
      PPVartefact=mean(XartefactPPV);
      
      x_thres= 0.5*PPVfree+threshold*0.5*(PPVartefact-PPVfree);
     
     if(plotfig==1)
     figure
     subplot(2,2,[1 2])
     hold on
     plot(Xartefact,'b')
     plot(Xfree,'g')
     plot(ones(1,size(Xfree,1))*x_thres,'r')
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
     end
     
     % launch peaks detection
          
      bin=zeros(1,nbpnts);  
      bin(x(LeadSensor,:)>x_thres)=1;
      bin=diff(bin);
      spikeindex=find(bin==1)+1;
      bin=zeros(1,nbpnts);  
      bin(spikeindex)=1;
      spikeAI=diff(spikeindex);
      
      if(plotfig==1)
          figure
          subplot(211)
          hold on
          plot(x(LeadSensor,1:1000));
          plot(bin(1:1000).*max(x(LeadSensor,1:1000)));
          title('Visualization of peaks detection.')
          hold off
          grid on
          subplot(212)
          hist(spikeAI,100);
          title('Distribution of inter-detections intervals.')

      end
      
      AIm=mean(spikeAI);
      AIf=1/(AIm/sr);

     fprintf('First pass : %d detected spikes - Aver. Int. = %0.6f samples - Frequ = %.6f Hz.\n',length(spikeindex),AIm,AIf);
     
     FirstLastIndex(1)=spikeindex(1);
     FirstLastIndex(2)=spikeindex(end);
     
     spikeindex=spikeindex(1:end-1); % we ignore the last and incomplete detected artefact. 
     decal=0;
     period=floor(AIm);
     indices(:,1)=spikeindex-decal;
     indices(:,2)=spikeindex-decal+period-1;
     
     nb_epochs=length(spikeindex);
     peaks=zeros(nbchan,period,nb_epochs);
     for i=1:nb_epochs
         peaks(:,:,i)=x(:,indices(i,1):indices(i,2));
     end
     
     
     
     
     
      
     
      
      
      
     
    
    
    
    
    
    
    
    