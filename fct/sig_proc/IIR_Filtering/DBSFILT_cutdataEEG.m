


function [x EEG]= DBSFILT_cutdataEEG(x,Tcut,EEG)
% Reject first and last samples for EEG structures.

EEG.data=x;
EEG=pop_select(EEG, 'time', [Tcut EEG.xmax-Tcut]);
x=EEG.data;
EEG.data=[];




