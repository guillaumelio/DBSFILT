

function HD= DBSFILT_highpassfilterHD(sr,Fcut,Fbandwidth,Aattenuation,Aripple)
% DBSFILT_highpassfilterHD() -
%     DBSFILT_highpassfilterHD - Chebychev IIR type II filter design.
%     
%
%    USAGE :
%                HD=DBSFILT_highpassfilterHD(x,sr,Fcut,Fbandwidth,Aattenuation,Aripple)
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


Fstop = Fcut-(Fbandwidth/2);          % Stopband Frequency
Fpass = Fcut+(Fbandwidth/2);          % Passband Frequency
Astop = Aattenuation;                 % Stopband Attenuation (dB)
Apass = Aripple;                      % Passband Ripple (dB)
match = 'passband';                   % Band to match exactly

h  = fdesign.highpass(Fstop, Fpass, Astop, Apass, sr);
HD = design(h, 'cheby2', 'MatchExactly', match);

