


function [flag]= DBSFILT_savedataas(x,EEG,ext,varname,defaultfilename,defaultsuffix)
% DBFILT_savedataas() -
%     DBSFILT_savedataas - Save x in a .set or a .mat file, according to
%     ext.
%     
%
%    USAGE :
%                [flag]=DBSFILT_savedataas(x,EEG,ext,varname,defaultfilename,defaultsuffix)
%
%    INPUTS : 
%                - x          ; EEG data (sensors x samples) in microVolt 
%                - EEG        ; EEGLAB EEG structure with empty EEG.data
%                - ext        ; file extension (.set or .mat)
%                - varname    ; name of the EEG data variable in the .mat file
%                - defaultfilename + defaultsuffix; default file name.
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

if(strcmp(ext,'.set') || strcmp(ext,'.SET'))

    if(strcmp(ext,'.set'))
       defaultfilename=strrep(defaultfilename,'.set',strcat(defaultsuffix,'.set'));
    else
       defaultfilename=strrep(defaultfilename,'.SET',strcat(defaultsuffix,'.SET')); 
    end
    [filename, pathname] = uiputfile('*.set','Save as',defaultfilename);
    if isempty(filename)
        flag=0;
    else
    EEG.data=x;
    clear x;
    pop_saveset(EEG,'filename',filename,'filepath',pathname,'check','on');
    flag=1;
    end
    
else
    defaultfilename=strrep(defaultfilename,'.mat',strcat(defaultsuffix,'.mat'));
    [filename, pathname] = uiputfile('*.mat','Save as',defaultfilename);
    if isempty(filename)
        flag=0;
    else
    str=sprintf('%s=x;',varname);
    
    eval(str);
    save(strcat(pathname,filename),varname);
    flag=1;
    end
end

fprintf('DBSFILT [saving...] >> Done.\n')
    
    
    



