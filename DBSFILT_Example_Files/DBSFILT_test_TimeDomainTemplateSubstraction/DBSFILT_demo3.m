


%% DBSFILT SCRIPT DEMO 3
%
% Author : G. Lio 
% Centre de Neurosciences Cognitives, CNRS UMR 5229, Lyon, France
% v1.0 2016
%%
%
%   Methods comparison
%   1- Simple LowPass Filtering
%   2- Simple LowPass Filtering + Frequency domain Hampel detection
%   3- Upsampling + Temporal domain peaks detection +  Frequency domain Hampel detection
%
%% 1- Script initialization

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
    Tcut=1; % Time window (s) to suppress to avoid edge effects. 
  

%% 4- Data preparation.

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
upsamprate=10;
EEG=pop_resample(EEG,EEG.srate*upsamprate);

%% 5- Peaks detection

Fc=100;         %  Cutting frequency for peaks detection (below the stimulation frequency (130Hz))
PPVseglen=6;    %  Segment length for threshold estimation (6s, same as Sun and Hinrichs, 2016 paper).
threshold=0.6;  %  Threshold adjustment
plotfig=1;      %  Plot results
[peaks, FirstLastIndex, ABR]=DBSFILT_StimPeaksDetection(EEG.data,EEG.srate,Fc,PPVseglen,threshold,plotfig);

     %) display clocks jitter
     x=squeeze(peaks(10,:,:));
     figure
     imagesc(x);
     title('DBS artefacts aligned data (channel 10)')
     xlabel('Artefacts')
     ylabel('Samples')

%% 6- Spectral analysis of the signal, aligned on peak detections.

     peaks=reshape(peaks,EEG.nbchan,[]);
     
    %) Hampel detection for highlighting the outlier frequencies
    
    % parameters
    type=1; % Hampel identifier and refined spike identification (type=1 - Hampel identifier only)
    HampelL=1; % windows size for automatic spike detection (Hz) 
    HampelT=2; % Hampel threshold for automatic spike detection.
    
    FdbsL=130;  % DBS frequency (Hz) (left hemisphere)
    FdbsR=130;  % DBS frequency (Hz) (right hemisphere)
    nmax=5;     % max number of sub-multiples of the stimulation frequency considered
    eps=0.002;  % estimated precision of the frequency measurements
 
    % detection on aligned data -------------------------------------------
    [spikes, FFTlength, DATAlength]=DBSFILT_PrepareSpikesDetection(peaks,EEG.srate);
    [spikes, nb_spikes]=DBSFILT_SpikesDetection(spikes, type, HampelL, HampelT, FdbsL, FdbsR, nmax, eps);
    
    % detection on raw data -------------------------------------------
    [spikes2, FFTlength2, DATAlength2]=DBSFILT_PrepareSpikesDetection(EEG.data,EEG.srate);
    [spikes2, nb_spikes2]=DBSFILT_SpikesDetection(spikes2, type, HampelL, HampelT, FdbsL, FdbsR, nmax, eps);
    
    Fmin1=1;     % Lower frequency to display 
    Fmax1=80;    % Higher frequency to display
    Fmin2=120;   % Lower frequency to display 
    Fmax2=140;   % Higher frequency to display 
    
    % display detection
    FlagSpikes=1;
    
    str_title='Spectral analysis of the data, aligned on the stimulation peaks (Low frequencies).';
    DBSFILT_display_rawfftspectraFAST(spikes,FlagSpikes,Fmin1,Fmax1,str_title)
    ylim([0 2.5*10^6])
    
    str_title='Spectral analysis of the data, aligned on the stimulation peaks (High frequencies).';
    DBSFILT_display_rawfftspectraFAST(spikes,FlagSpikes,Fmin2,Fmax2,str_title)
    ylim([0 2.5*10^6])
     
    str_title='Spectral analysis of the raw data (Low frequencies).';
    DBSFILT_display_rawfftspectraFAST(spikes2,FlagSpikes,Fmin1,Fmax1,str_title)
    ylim([0 2.5*10^6])
    
    str_title='Spectral analysis of the raw data (High frequencies).';
    DBSFILT_display_rawfftspectraFAST(spikes2,FlagSpikes,Fmin2,Fmax2,str_title)
    ylim([0 2.5*10^6])
    
    %% ) Power spectral density and %signal change after data alignment.
     segmentLength = EEG.srate;
     noverlap = round(segmentLength/2);
     [pxx, f] = pwelch(EEG.data',segmentLength,noverlap,segmentLength,EEG.srate);  %% Warning - Need matlab builtin pwelch function - potential conflict with the pwelch function of some implementation of eeglab. 
     [pxx2, f] = pwelch(peaks',segmentLength,noverlap,segmentLength,EEG.srate);
   
     Fmin=1;     % Lower frequency to display 
     Fmax=80;    % Higher frequency to display
    
     index1=find(f>=Fmin,1,'first');
     index2=find(f>=Fmax,1,'first');
     f=f(index1:index2);
     pxx=pxx(index1:index2,:);
     pxx2=pxx2(index1:index2,:);
     
     for i=1:EEG.nbchan
        pxx2r(:,i)=pxx2(:,i)./sum(pxx2(:,i));
        pxxr(:,i)=pxx(:,i)./sum(pxx(:,i));
     end
     
     
     
     figure
     subplot(211)
     hold on
     plot(f, 10*log10(pxxr),'k')
     plot(f, 10*log10(pxx2r),'r')
     hold off
     grid on
     title('Relative Power spectral density estimation with and without data alignment.')
     xlabel('Frequencies (Hz)')
     ylabel('10 Log10 (Relative power)')
     
     subplot(212)
     hold on
     plot(f, (((pxx2)-(pxx))./(pxx))*100,'r')
     hold off
     grid on
     title('Data alignment effect.')
     xlabel('Frequencies (Hz)')
     ylabel('% signal change')
     ylim([0 300])
     
     %
     Foi=33;
     index=find(f>=Foi,1,'first');
     Poi=(((pxx2(index,:))-(pxx(index,:)))./(pxx(index,:)))*100;
     
     Foi2=75;
     index=find(f>=Foi2,1,'first');
     Poi2=(((pxx2(index,:))-(pxx(index,:)))./(pxx(index,:)))*100;
     
     
     figure
     subplot(121)
     scatter(ABR, Poi);
     lsline
     title('ABR / %signal change at 33 Hz correlation')
     xlabel('ABR')
     ylabel('% signal change')
     
     subplot(122)
     scatter(ABR, Poi2);
     lsline
     title('ABR / %signal change at 75 Hz correlation')
     xlabel('ABR')
     ylabel('% signal change')
     
     
     
    
    %%
    
    
     
%% 7- Remove the DBS signal

    % crop the EEG structure, based on peaks detection. (remove incomplete 'peaks')
    EEG=pop_select(EEG, 'point', [FirstLastIndex(1) FirstLastIndex(2)-1]);
    
    % DBS signal removal on the aligned data
    peaks=DBSFILT_SpikesRemoval(spikes, peaks, EEG.srate);
    EEG3=EEG;
    EEG3.data=peaks;
        
    % DBS signal removal with low pass filter
    Fcut=94.5;          % cutting frequency (Hz)
    Fbandwidth=2.5;     % transition and width (Hz)
    Aattenuation=120;   % amplitude attenuation (dB)
    Aripple=0.01;       % ripple in the stop band (dB)
    
    EEG.data=DBSFILT_highpassfilter(EEG.data,EEG.srate,Fcut2,Fbandwidth2,Aattenuation2,Aripple2);

    % DBS signal removal with hampel identifier on the low pass filtered data
    [spikes2, FFTlength2, DATAlength2]=DBSFILT_PrepareSpikesDetection(EEG.data,EEG.srate);
    [spikes2, nb_spikes2]=DBSFILT_SpikesDetection(spikes2, type, HampelL, HampelT, FdbsL, FdbsR, nmax, eps);
    EEG2=EEG;
    EEG2.data=DBSFILT_SpikesRemoval(spikes2, EEG.data, EEG.srate);
    
 
    %) remove edge effects
    Tcut=4; % Time window (s) to supress to avoid edge effects. 
    EEG=pop_select(EEG, 'time', [Tcut EEG.xmax-Tcut]);
    EEG2=pop_select(EEG2, 'time', [Tcut EEG.xmax-Tcut]);
    EEG3=pop_select(EEG3, 'time', [Tcut EEG.xmax-Tcut]);

    
    
    
%%    %) 8- Display results
  
    Fmin=1;     % Lower frequency to display 
    Fmax=80;    % Higher frequency to display
    
    str_title='Cleaned data. (LowPass)';
    DBSFILT_display_rawfftspectra(EEG.data,EEG.srate,Fmin,Fmax,str_title)
 
    str_title='Cleaned data. (Hampel)';
    DBSFILT_display_rawfftspectra(EEG2.data,EEG.srate,Fmin,Fmax,str_title)
 
    str_title='Cleaned data. (Temporal thresholding + Hampel)';
    DBSFILT_display_rawfftspectra(EEG2.data,EEG.srate,Fmin,Fmax,str_title)
 
    % Plot relative power.
    
     segmentLength = EEG.srate;
     noverlap = round(segmentLength/2);
     [pxx, f] = pwelch(EEG.data',segmentLength,noverlap,segmentLength,EEG.srate);
     [pxx2, f] = pwelch(EEG2.data',segmentLength,noverlap,segmentLength,EEG.srate);
     [pxx3, f] = pwelch(EEG3.data',segmentLength,noverlap,segmentLength,EEG.srate);
     
     index1=find(f>=Fmin,1,'first');
     index2=find(f>=Fmax,1,'first');
     f=f(index1:index2);
     pxx=pxx(index1:index2,:);
     pxx2=pxx2(index1:index2,:);
     pxx3=pxx3(index1:index2,:);
     
     for i=1:EEG.nbchan
        pxx3r(:,i)=pxx3(:,i)./sum(pxx3(:,i));
        pxx2r(:,i)=pxx2(:,i)./sum(pxx2(:,i));
        pxxr(:,i)=pxx(:,i)./sum(pxx(:,i));
     end
     
     %%
     
     figure
     subplot(211)
     hold on
     plot(f, 10*log10(pxxr),'g')
     plot(f, 10*log10(pxx2r),'k')
     plot(f, 10*log10(pxx3r),'r')
     hold off
     grid on
     title('Relative Power spectral density estimation of the cleaned data (low frequency resolution).')
     xlabel('Frequencies (Hz)')
     ylabel('10 Log10 (Relative power)')
     
     subplot(212)
     hold on
     plot(f, (((pxx2)-(pxx))./(pxx))*100,'k')
     plot(f, (((pxx3)-(pxx))./(pxx))*100,'r')
     hold off
     grid on
     title('Filters effects.')
     xlabel('Frequencies (Hz)')
     ylabel('% signal change')
     
     
     
   