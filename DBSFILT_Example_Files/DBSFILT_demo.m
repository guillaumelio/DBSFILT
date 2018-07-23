


%% DBSFILT SCRIPT DEMO
% Author : G. Lio 
% Centre de Neurosciences Cognitives, CNRS UMR 5229, Lyon, France
% v1.0 2016
%
% Warning - pause is bugged in matlab r2016a - use without 'pause' in this
% case. 
%
 

clear all
close all
clc

fprintf('Welcome to the DBSFILT script demo\n-----------------------------------\n\n')

fprintf('DBSFILT >> Press any key to continue...\n')
pause %% !! pause is bugged in matlab 2016a... 
clc

fprintf('Welcome to the DBSFILT script demo\n-----------------------------------\n\n')

fprintf('DBSFILT >> Loading the demo EEG file...\n')
EEG=pop_loadset('DBSFILT_P1_dbs_ON_EC.set'); 
fprintf('DBSFILT >> Done.')

fprintf('\n\n-------------------------------------------------------------------------\n')
fprintf('DBSFILT >> Process an high resolution spectrum of the data with the : DBSFILT_display_rawfftspectra function...\n')
str_title='RAW fft spectrum Pre-filtering - DBS ON.';
Fmin=1; % Hz
Fmax=600; % Hz
DBSFILT_display_rawfftspectra(EEG.data,EEG.srate,Fmin,Fmax,str_title)
fprintf('\n\n-------------------------------------------------------------------------\n')
fprintf('DBSFILT >> Huge spike can be observed at the stimulation frequency (130Hz) and their harmonics.\nStandard Low Pass filters will be used to remove the high frequency content of the data.\n\n')
           


fprintf('DBSFILT >> Press any key to continue...\n\n')
pause
close all


%% STEP 1 - TEMPORAL FILTERING
fprintf('\n\n-------------------------------------------------------------------------\n')
fprintf('DBSFILT >> Step 1 : Temporal filtering...\n')
fprintf('-------------------------------------------------------------------------\n')


%) Lowpass filtering.
fprintf('DBSFILT >> Step 1a : Low pass filtering...\n')
             Fcut=94.5;
             Fbandwidth=2.5;
             Aattenuation=120;
             Aripple=0.01;
             EEG.data=DBSFILT_lowpassfilter(EEG.data,EEG.srate,Fcut,Fbandwidth,Aattenuation,Aripple);
             
%) HighPass filtering.
fprintf('DBSFILT >> Step 1b : High pass filtering...\n')
             Fcut=0.75;
             Fbandwidth=0.5;
             Aattenuation=120;
             Aripple=0.01;
             EEG.data=DBSFILT_highpassfilter(EEG.data,EEG.srate,Fcut,Fbandwidth,Aattenuation,Aripple);
             
%) Select data to remove edge effects.
fprintf('DBSFILT >> Step 1c : Edge effect suppression (4s)...\n')
            Tcut=4;
            EEG=pop_select(EEG, 'time', [Tcut EEG.xmax-Tcut]);

%% STEP 2 - AUTOMATIC OUTLIER FREQUENCIES DETECTION 

str_title='RAW fft spectrum Post Temporal Filtering - DBS ON.';
Fmin=1; % Hz
Fmax=100; % Hz
DBSFILT_display_rawfftspectra(EEG.data,EEG.srate,Fmin,Fmax,str_title)
fprintf('\n\n-------------------------------------------------------------------------\n')
fprintf('DBSFILT >> Most DBS artefacts are suppressed after the procedure.\nBut some outlier frequencies can be detected in the high resolution power spectrum.\n - one spike at 50 Hz (Line noise)\n - two spikes at ~32.5 Hz and ~65 Hz (DBS aliased frequencies).\n\n')

fprintf('DBSFILT >> Press any key to continue...\n\n')
pause
close all
clc

fprintf('Welcome to the DBSFILT script demo\n-----------------------------------\n\n')

fprintf('DBSFILT >> Most DBS artefacts are suppressed after the procedure.\nBut some outlier frequencies can be detected in the high resolution power spectrum.\n - one spike at 50 Hz (Line noise)\n - two spikes at ~32.5 Hz and ~65 Hz (DBS aliased frequencies).\n\n')

%) Launch the automatic spike detection with the Hampel identifier.
[spikes, FFTlength, DATAlength]=DBSFILT_PrepareSpikesDetection(EEG.data,EEG.srate);
    type=1; % Hampel identifier only
    HampelL=1; % windows size for automatic spike detection (Hz) 
    HampelT=2; % Hampel threshold for automatic spike detection.
    
    FdbsL=130;  % not used - only for type 2
    FdbsR=130;  % not used - only for type 2
    nmax=5;     % not used - only for type 2
    eps=0.002;  % not used - only for type 2 
    
    
    [spikes, nb_spikes]=DBSFILT_SpikesDetection(spikes, type, HampelL, HampelT, FdbsL, FdbsR, nmax, eps);
    FlagSpikes=1;
    str_title='Automatic detection of outlier frequencies ( DBS @130Hz )';
    DBSFILT_display_rawfftspectraFAST(spikes,FlagSpikes,Fmin,Fmax,str_title)
    
fprintf('\n\n-------------------------------------------------------------------------\n')
fprintf('DBSFILT >> These outlier frequencies can be automatically detected in the power spectrum with the Hampel identifier.\n\n')

pause
close all

%) Launch the automatic spike detection with the Hampel identifier and apriori knowledge about the stimulation frequencies.
[spikes, FFTlength, DATAlength]=DBSFILT_PrepareSpikesDetection(EEG.data,EEG.srate);
    type=2; % Hampel identifier and refined spike identification
    HampelL=1; % windows size for automatic spike detection (Hz) 
    HampelT=2; % Hampel threshold for automatic spike detection.
    
    FdbsL=130;  % DBS frequency (left hemisphere)
    FdbsR=130;  % DBS frequency (right hemisphere)
    nmax=5;     % max number of sub-multiples of the stimulation frequency considered
    eps=0.002;  % estimated precision of the frequency measurement
    
    [spikes, nb_spikes]=DBSFILT_SpikesDetection(spikes, type, HampelL, HampelT, FdbsL, FdbsR, nmax, eps);
    FlagSpikes=1;
    str_title='Automatic detection of outlier frequencies (refined - DBS @130Hz )';
    DBSFILT_display_rawfftspectraFAST(spikes,FlagSpikes,Fmin,Fmax,str_title)
    
fprintf('\n\n-------------------------------------------------------------------------\n')
fprintf('DBSFILT >> And with apriori knowledge of the stimulation frequencies.\n Only spikes at ~32.5Hz and ~65Hz remain detected as stimulation artifacts.\n')
pause

%) Launch the interpolation of the aliased frequencies.
fprintf('\n\n-------------------------------------------------------------------------\n')
fprintf('DBSFILT >> Launch the interpolation of the detected aliased frequencies.\n\n')
EEG.data=DBSFILT_SpikesRemoval(spikes, EEG.data, EEG.srate);

str_title='RAW fft spectrum Post DBS Filtering - (DBS @130Hz).';
Fmin=1; % Hz
Fmax=100; % Hz
DBSFILT_display_rawfftspectra(EEG.data,EEG.srate,Fmin,Fmax,str_title)
%%

fprintf('\n\n-------------------------------------------------------------------------\n')
fprintf('DBSFILT >> DBS filtering done. Only the line noise at 50hz remains.\n\n')

fprintf('\nDBSFILT >> The line noise can also be removed with a fft filter.\nThis method is equivalent than removing a sinusoid with a matched filter, but with semi-automatic detection of the most probable sinusoid frequency.');
fprintf('\nDBSFILT >> Lets remove the line noise with this technique...\n');

pause
%-- automatic detection and interpolation of outlier sinusoids in a specific frequency band. 
TargetF=50; % target frequency = 50hz
WinWidth=2; % +- 2Hz
fprintf('\t - Target frequency = %0.2f Hz +- %0.2f Hz.\n',TargetF,WinWidth/2);
nbspikes=15;
fprintf('\t - Number of sinusoids to remove = %d.\n',nbspikes);

EEG.data=DBSFILT_ManualSpikesRemoval(TargetF,WinWidth,nbspikes, EEG.data, EEG.srate);
%------------------------------------------------------------------------


%-- standard matched filter method - not recommanded -------------------
%iter=20; % number of iterations (number of matched sinusoids to remove).
%EEG.data= MatchedFilter(50,EEG.data,EEG.srate,iter);
%------------------------------------------------------------------------


str_title='RAW fft spectrum Post DBS Filtering and line noise removal - (DBS @130Hz).';
Fmin=1; % Hz
Fmax=100; % Hz
DBSFILT_display_rawfftspectra(EEG.data,EEG.srate,Fmin,Fmax,str_title)

%%

fprintf('\n\n-------------------------------------------------------------------------\n')
fprintf('DBSFILT >> DBS artefacts and the line noise are now interpolated.\nThe EEG data is now ready for further processing...\nThanks.\n');
fprintf('-------------------------------------------------------------------------\n\n')






    




