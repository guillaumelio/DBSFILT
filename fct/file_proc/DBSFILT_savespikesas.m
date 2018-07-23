


function [flag]= DBSFILT_savespikesas(spikes)
% DBSFILT_savespikesas() -
%     DBSFILT_savespikesas - Save a DBSFILT spike structure in a .spikes
%     file (.mat).
%     
%
%    USAGE :
%                [flag]= DBSFILT_savespikesas(spikes)
%
%    INPUTS : 
%                - spikes     ; spike structure. 
%
%    OUTPUTS : 
%                - flag       ; 1 if ok. 
%
%                
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Author : G. Lio 
% Centre de Neurosciences Cognitives, CNRS UMR 5229, Lyon, France
% v1.0 November 2012
%
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    [filename, pathname] = uiputfile('*.spikes','Save as');
    if isempty(filename)
        flag=0;
    else
        save(strcat(pathname,filename),'spikes','-mat');
        flag=1;
    end
    
    fprintf('DBSFILT [saving...] >> Done.\n')
    
    
    
    



