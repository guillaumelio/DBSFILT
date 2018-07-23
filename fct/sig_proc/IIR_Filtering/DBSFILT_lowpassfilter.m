



function x= DBSFILT_lowpassfilter(x,sr,Fcut,Fbandwidth,Aattenuation,Aripple)
% DBSFILT_lowpassfilter() -
%     DBSFILT_lowpassfilter - Chebychev IIR type II filter design, and
%     zero-phase filtering.
%     
%
%    USAGE :
%                x=DBSFILT_lowpassfilter(x,sr,Fcut,Fbandwidth,Aattenuation,Aripple)
%
%    INPUTS : 
%                - x          ; EEG data (sensors x samples) in microVolt
%                - sr         ; Sampling Rate
%                - Fcut       ; Cutting frequency (Hz)
%                - Fbandwidth ; Transition band width (Hz)
%                - Aattenuation    ; attenuation in the rejection band (in dB)
%                - Aripple    ; Maximum ripple in the pass-band (in dB)
%                (Note : flat pass-band for Chebychev type II filter)
%
%    OUTPUT : 
%                - x       ; filtered EEG data. 
%
%                
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Author : G. Lio 
% Centre de Neurosciences Cognitives, CNRS UMR 5229, Lyon, France
% v1.0 November 2012
%
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



Fpass = Fcut-(Fbandwidth/2);          % Passband Frequency
Fstop = Fcut+(Fbandwidth/2);          % Stopband Frequency
Apass = Aripple;                      % Passband Ripple (dB)
Astop = Aattenuation;                 % Stopband Attenuation (dB)
match = 'passband';                   % Band to match exactly

h  = fdesign.lowpass(Fpass, Fstop, Apass, Astop, sr);
Hd = design(h, 'cheby2', 'MatchExactly', match);

nbchan=size(x,1);

fprintf('DBSFILT >> Low pass zero-phase filtering : Fpass %0.1fHz - Fstop %0.1fHz - Att %ddB - Ripple %gdB - iir Chebichev type II\n',Fpass,Fstop,Astop,Apass); 
for i=1:nbchan
    fprintf('DBSFILT >> Filtering channel %d ... \n',i);
    reset(Hd);
    x(i,:)=filtfilthd(Hd,x(i,:));
    
end 
disp('DBSFILT >> Low pass Filtering : OK.')



