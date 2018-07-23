

%% DBSFILT DBS and ICA
% Author : G. Lio 
% Centre de Neurosciences Cognitives, CNRS UMR 5229, Lyon, France
% v1.0 2016
%
% Simple test for DBS artefacts removal with an Independent Component
% Analysis (ICA) algorithm. 
%
% ICA is applied on the data, then an high resolution power spectrum is
% calculated for each estimated independent component (IC). 
% If the characteristic DBS induced spikes are detected in only one IC, the
% DBS artefact can be considered as well isolated from the neural activity
% by the algoritm.
%
%



%% 1- Script initialisation

clear all
close all
clc

fprintf('Welcome to the DBSFILT ICA demo\n-----------------------------------\n\n')

%% 2- User parameters

%) A- file

%) Pre-attenuation of the DBS artefact by low-pass filtering - only the aliased componente of the artefact have to be removed with the ICA decomposition.
filename='DBSFILT_P1_dbs_ON_EC_filtered.set';  % Bandpass filtered data
flagHighpassFiltering=0;

%) High pass filtering, but no attenuation of the DBS by low pass filtering.
%filename='DBSFILT_P1_dbs_ON_EC.set'; % Raw data
%flagHighpassFiltering=0;


%) B- Display results

    Fmin=1;     % Lower frequency to display 
    %Fmax=135;   % Higher frequency to display 
    Fmax=80;   % Higher frequency to display 
   

%% 3- Data processing

%) A- load data
EEG=pop_loadset(filename); 
if(flagHighpassFiltering==1)

    % High pass filter
    Fcut2=1;          % cutting frequency (Hz)
    Fbandwidth2=1;     % transition and width (Hz)
    Aattenuation2=80;   % amplitude attenuation (dB)
    Aripple2=0.01;       % ripple in the stop band (dB)
    
    % Edge effet suppression
    Tcut=4; % Time window (s) to supress to avoid edge effects. 
    
    EEG.data=DBSFILT_highpassfilter(EEG.data,EEG.srate,Fcut2,Fbandwidth2,Aattenuation2,Aripple2);
    EEG=pop_select(EEG, 'time', [Tcut EEG.xmax-Tcut]);

end

%% 3b - Spectral analysis before ICA

[spikes, FFTlength, DATAlength]=DBSFILT_PrepareSpikesDetection(EEG.data,EEG.srate);
 type=2; % Hampel identifier and refined spike identification (type=1 - Hampel identifier only)
 HampelL=1; % windows size for automatic spike detection (Hz) 
 HampelT=2.2; % Hampel threshold for automatic spike detection.
    FdbsL=130;  % DBS frequency (Hz) (left hemisphere)
    FdbsR=130;  % DBS frequency (Hz) (right hemisphere)
    nmax=5;     % max number of sub-multiples of the stimulation frequency considered
    eps=0.002;  % estimated precision of the frequency measurements
[spikes, nb_spikes]=DBSFILT_SpikesDetection(spikes, type, HampelL, HampelT, FdbsL, FdbsR, nmax, eps);

str='Pre-ICA spectral analysis.';
FlagSpikes=1;
DBSFILT_display_rawfftspectraFAST(spikes,FlagSpikes,Fmin,Fmax,str);
ylim([0 1*10^6])        

%% 4- Process ICA (insert your own ICA algorithm here)

EEG=pop_reref(EEG,[]);
[Wefica, ISRef, Wsymm, ISRsymm, status, icasig]=efica2(EEG.data);
IC=Wefica*EEG.data; % EFICA algorithm
%IC=Wsymm*EEG.data; % Sym-FASTICA algorithm


%% 5- DBS spikes identification component by component (a good DBS artefact identification with ICA should identify only one IC with the caracteristics DBS aliased frequencies)

nb_ic=size(IC,1);
cpt_dbsic=0;
for ic=1:nb_ic 

[spikes, FFTlength, DATAlength]=DBSFILT_PrepareSpikesDetection(IC(ic,:),EEG.srate);
 type=2; % Hampel identifier and refined spike identification (type=1 - Hampel identifier only)
 HampelL=1; % windows size for automatic spike detection (Hz) 
 HampelT=2.2; % Hampel threshold for automatic spike detection.
    FdbsL=130;  % DBS frequency (Hz) (left hemisphere)
    FdbsR=130;  % DBS frequency (Hz) (right hemisphere)
    nmax=5;     % max number of sub-multiples of the stimulation frequency considered
    eps=0.002;  % estimated precision of the frequency measurements
[spikes, nb_spikes]=DBSFILT_SpikesDetection(spikes, type, HampelL, HampelT, FdbsL, FdbsR, nmax, eps);

str=sprintf('IC %d - %d DBS spikes detected.',ic,nb_spikes);
fprintf('%s\n',str);

    %if(nb_spikes~=0)
     % display detection
        FlagSpikes=1;
        DBSFILT_display_rawfftspectraFAST(spikes,FlagSpikes,Fmin,Fmax,str)
    if(nb_spikes~=0)
        cpt_dbsic=cpt_dbsic+1;
    end
    
end

fprintf('\n %d/%d IC with detected DBS artefacts.\n',cpt_dbsic,nb_ic);



