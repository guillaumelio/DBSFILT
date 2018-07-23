



function HD= DBSFILT_lowpassfilterHD(sr,Fcut,Fbandwidth,Aattenuation,Aripple)
% DBSFILT_lowpassfilterHD() -
%     DBSFILT_lowpassfilterHD - Chebychev IIR type II filter design.
%     
%
%    USAGE :
%                HD=DBSFILT_lowpassfilterHD(x,sr,Fcut,Fbandwidth,Aattenuation,Aripple)
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
%                - HD       ; Designed filter structure. 
%
%                
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Author : G. Lio 
% Centre de Neurosciences Cognitives, CNRS UMR 5229, Lyon, France
% v1.0 November 2012
%
% 


Fpass = Fcut-(Fbandwidth/2);          % Passband Frequency
Fstop = Fcut+(Fbandwidth/2);          % Stopband Frequency
Apass = Aripple;                      % Passband Ripple (dB)
Astop = Aattenuation;                 % Stopband Attenuation (dB)
match = 'passband';                   % Band to match exactly

h  = fdesign.lowpass(Fpass, Fstop, Apass, Astop, sr);
HD = design(h, 'cheby2', 'MatchExactly', match);





