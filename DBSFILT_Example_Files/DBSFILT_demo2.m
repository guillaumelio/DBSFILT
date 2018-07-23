

%% DBSFILT SCRIPT DEMO 2
% Author : G. Lio 
% Centre de Neurosciences Cognitives, CNRS UMR 5229, Lyon, France
% v1.0 2016

%% 1- Script initialisation

clear all
%close all
clc

fprintf('Welcome to the DBSFILT script demo\n-----------------------------------\n\n')

%% 2- User parameters

%) A- file
filename='DBSFILT_P1_dbs_ON_EC.set';

%) B- Pre-filtering

    % Low pass filter
    Fcut=94.5;          % cutting frequency (Hz)
    Fbandwidth=2.5;     % transition and width (Hz)
    Aattenuation=120;   % amplitude attenuation (dB)
    Aripple=0.01;       % ripple in the stop band (dB)
    
    % High pass filter
    Fcut2=0.75;          % cutting frequency (Hz)
    Fbandwidth2=0.5;     % transition and width (Hz)
    Aattenuation2=120;   % amplitude attenuation (dB)
    Aripple2=0.01;       % ripple in the stop band (dB)
    
    % Edge effet suppression
    Tcut=4; % Time window (s) to supress to avoid edge effects. 
    
%) C- Aliased DBS frequencies detection and interpolation

    type=2; % Hampel identifier and refined spike identification (type=1 - Hampel identifier only)
    HampelL=4; % windows size for automatic spike detection (Hz) 
    HampelT=1.5; % Hampel threshold for automatic spike detection.
    
    FdbsL=130;  % DBS frequency (Hz) (left hemisphere)
    FdbsR=130;  % DBS frequency (Hz) (right hemisphere)
    nmax=5;     % max number of sub-multiples of the stimulation frequency considered
    eps=0.01;  % estimated precision of the frequency measurements

%) D- Line noise removal
    
    TargetF=50; % target frequency (Hz)
    WinWidth=2; % windows width (Hz) for the detection and the interpolation of the targeted sinusoid.
    nbspikes=15;% number of sinusoid to interpolate.

%) E- Display results

    Fmin=1;     % Lower frequency to display 
    Fmax=80;   % Higher frequency to display 
    
%% 3- Data processing

%) A- load data
EEG=pop_loadset(filename); 

%) B- pre-filtering
EEG.data=DBSFILT_lowpassfilter(EEG.data,EEG.srate,Fcut,Fbandwidth,Aattenuation,Aripple);
EEG.data=DBSFILT_highpassfilter(EEG.data,EEG.srate,Fcut2,Fbandwidth2,Aattenuation2,Aripple2);
EEG=pop_select(EEG, 'time', [Tcut EEG.xmax-Tcut]);

%) C- Aliased DBS frequencies detection and interpolation
    
    % detection
    [spikes, FFTlength, DATAlength]=DBSFILT_PrepareSpikesDetection(EEG.data,EEG.srate);
    [spikes, nb_spikes]=DBSFILT_SpikesDetection(spikes, type, HampelL, HampelT, FdbsL, FdbsR, nmax, eps);
    
    % display detection
    FlagSpikes=1;
    str_title='Automatic detection of DBS aliased frequencies (refined - DBS @130Hz )';
    DBSFILT_display_rawfftspectraFAST(spikes,FlagSpikes,Fmin,Fmax,str_title)
    
    % interpolation
    EEG.data=DBSFILT_SpikesRemoval(spikes, EEG.data, EEG.srate);
    
    % display interpolation
    str_title='Interpolation of DBS aliased frequencies ( DBS @130Hz )';
    DBSFILT_display_rawfftspectra(EEG.data,EEG.srate,Fmin,Fmax,str_title)

 %) D- Line noise removal
 EEG.data=DBSFILT_ManualSpikesRemoval(TargetF,WinWidth,nbspikes, EEG.data, EEG.srate);

 %) E- Display results
 str_title='High resolution power spectrum of the cleaned data. ( DBS @130Hz )';
 DBSFILT_display_rawfftspectra(EEG.data,EEG.srate,Fmin,Fmax,str_title)
   
     % Power spectral density
     
     segmentLength = EEG.srate;
     noverlap = round(segmentLength/2);
     
     for i=1:EEG.nbchan
          [pxx(:,i), f] = pwelch(EEG.data(i,:)',segmentLength,noverlap,segmentLength,EEG.srate);
     end
     
     index1=find(f>=Fmin,1,'first');
     index2=find(f>=Fmax,1,'first');
     f=f(index1:index2);
     pxx=pxx(index1:index2,:);
     
     for i=1:EEG.nbchan
        pxx(:,i)=pxx(:,i)./sum(pxx(:,i));
     end
     
     figure
     plot(f, 10*log10(pxx))
     grid on
     title('Relative Power spectral density estimation of the cleaned data (low frequency resolution).')
     xlabel('Frequencies (Hz)')
     ylabel('10 Log10 (Relative power)')
   
 
 
fprintf('\n\n-------------------------------------------------------------------------\n')
fprintf('DBSFILT >> DBS artefacts and the line noise are now interpolated.\nThe EEG data is now ready for further processing...\nThanks.\n');
fprintf('-------------------------------------------------------------------------\n\n')

    
 

    




             