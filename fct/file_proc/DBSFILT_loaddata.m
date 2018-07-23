

function [x,filename,sr,EEG, ext,varname,flag] = DBSFILT_loaddata()
% DBFILT_loaddata() -
%     DBSFILT_loaddata - Display a file selection GUI (Graphical User Interface),
%     load a .set (if EEGLAB available) or a .mat file and return available
%     dataset informations. A .mat file must have one variable of size
%     sensors x samples.
%     
%
%    USAGE :
%                [x,filename,sr,EEG, ext,varname,flag] = DBSFILT_loaddata()
%
%    OUTPUTS : 
%                - x          ; EEG data (sensors x samples) in microVolt 
%                - filename   ; file name
%                - sr         ; Sampling Rate (Hz)
%                - EEG        ; EEGLAB EEG structure with empty EEG.data
%                - ext        ; file extension (.set or .mat)
%                - varname    ; name of the EEG data variable in the .mat file
%                - flag       ; 1 if ok. 

%                
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Author : G. Lio 
% Centre de Neurosciences Cognitives, CNRS UMR 5229, Lyon, France
% v1.0 November 2012
%
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% v1.0 .set and .mat only.
%


x=[];
sr=[];
EEG=[];
varname='';
flag=0;

%[filename, pathname] = uigetfile({'*.set';'*.SET';'*.mat';'*.txt';'*.ascii'},'DBSFILT >> Load data');
[filename, pathname] = uigetfile({'*.set';'*.SET';'*.mat'},'DBSFILT >> Load data');
str=strcat(pathname,filename);
[pathstr, name, ext] = fileparts(str);

fprintf('DBSFILT >> Loading data...\n-----------------------------\n')
tic

if(strcmp(ext,'.set') || strcmp(ext,'.SET'))

    fprintf('.set file extension detected.\n')
    s = which('pop_loadset','-all');
    if isempty(s)
        fprintf('Warning : EEGLAB function pop_loadset not found in the matlab path. .set file not loaded.\n')
        fprintf('DBSFILT >> Loading data : ERROR.\n-----------------------------\n')

    else 
        EEG=pop_loadset(str);
        x=EEG.data;
        sr=EEG.srate;
        EEG.data=[];
        flag=1;
        fprintf('DBSFILT >> Loading data : OK.\n-----------------------------\n')
    end
    


elseif(strcmp(ext,'.mat'))
    
    fprintf('.mat file extension detected.\nLoading data... Please wait.\n')
    x=load(str,'-mat');
    varname=fieldnames(x);
    varname=varname{1};
    x = struct2cell(x);
    x = x{1};
    flag=1;
    fprintf('DBSFILT >> Loading data : OK.\n-----------------------------\n')
    

%) Slow...    
% elseif(strcmp(ext,'.txt') || strcmp(ext,'.ascii'))
%     
%     fprintf('ASCII file extension detected.\nLoading data... Please wait.\n')
%     x=load(str,'-ascii');
%     fprintf('DBSFILT >> Loading data : OK.\n-----------------------------\n')
    
else
    
    fprintf('Warning : Unknown file extension - File not loaded.\n')
    fprintf('DBSFILT >> Loading data : ERROR.\n-----------------------------\n')
    
end


toc


