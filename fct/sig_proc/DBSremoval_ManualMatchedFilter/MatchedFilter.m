


function [x]= MatchedFilter(f,x,sr,iter)
% 
% Matched filters : remove phase matched sinusoids at frequencies 
% specified in the vector f.
% 
% USAGE :
%         [x]= MatchedFilter(f,x,sr,iter);
%         
% INPUTS :
%         - x         : EEG data (sensors x samples) or (sensors x samples x trials) in MicroVolt
%         - sr        : Sampling Rate
%         - iter      : number of iterations (number of matched sinusoids removals)
%         
% OUTPUT : 
%         - x         : filtered EEG data.
%         
%         
%         
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Author : G. Lio
% Centre de Neurosciences Cognitives, CNRS UMR 5229, Lyon, France
% v1.0 January 2015

nb_f=length(f);
S=size(x);
Dim=length(S);

if Dim==2
    nb_sensors=S(1);
    nb_samples=S(2);
    nb_trials=1;
    x=reshape(x,nb_sensors,nb_samples,nb_trials);
    
else
    
    nb_sensors=S(1);
    nb_samples=S(2);
    nb_trials=S(3);
    
end

for i_f=1:nb_f
    
    L=nb_samples; % signal length
    Freq=f(i_f);  % frequency to remove
    msig=1*sin((2*pi*Freq).*(((1:L)+0)./sr));
               
    for  i_s=1:nb_sensors
        
        
        fprintf('DBSFILT >>> Matched filter : remove F=%0.4fHz - Sensor [%d/%d].\n',Freq,i_s,nb_sensors)
        
        for i_t=1:nb_trials
            
            sig=squeeze(x(i_s,:,i_t));
            for i_i=1:iter
            
                maxlags=ceil(0.5*(sr/Freq));
                [c,lags] = xcov(sig,msig,maxlags);
                M=max(c);
                Mindex=find(c==M,1,'first');
                Mlag=lags(Mindex);
                A=2*(M/L);
                sig=sig-A*sin((2*pi*Freq).*(((1:L)-Mlag)./sr));
                
            end
            x(i_s,:,i_t)=sig;
            
        end
        
        
    end
    
end





                

                 
           

    
    



    
    





