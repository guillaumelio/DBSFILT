

function [spikes, filename] = DBSFILT_loadspikes()
% DBFILT_loadspikes() -
%     DBSFILT_loadspikes - Display a file selection GUI, and load a .spikes
%     file.
%
%    USAGE :
%                [spikes, filename] = DBSFILT_loadspikes()
%
%    OUTPUTS : 
%                - spikes     ; DBSFILT spikes structure. 
%                - filename   ; file name
%                
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Author : G. Lio 
% Centre de Neurosciences Cognitives, CNRS UMR 5229, Lyon, France
% v1.0 November 2012
%
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


spikes=[];

[filename, pathname] = uigetfile('*.spikes','DBSFILT >> Load .spikes data');
str=strcat(pathname,filename);

fprintf('DBSFILT >> Loading .spikes data...\n-----------------------------\n')
load(str,'-mat');

