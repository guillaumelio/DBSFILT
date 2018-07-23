

function x= DBSFILT_highpassfilter(x,sr,Fcut,Fbandwidth,Aattenuation,Aripple)
% DBSFILT_highpassfilter() -
%     DBSFILT_highpassfilter - Chebychev IIR type II filter design, and
%     zero-phase filtering.
%     
%
%    USAGE :
%                x=DBSFILT_highpassfilter(x,sr,Fcut,Fbandwidth,Aattenuation,Aripple)
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



Fstop = Fcut-(Fbandwidth/2);          % Stopband Frequency
Fpass = Fcut+(Fbandwidth/2);          % Passband Frequency
Astop = Aattenuation;                 % Stopband Attenuation (dB)
Apass = Aripple;                      % Passband Ripple (dB)
match = 'passband';                   % Band to match exactly

h  = fdesign.highpass(Fstop, Fpass, Astop, Apass, sr);
Hd = design(h, 'cheby2', 'MatchExactly', match);

nbchan=size(x,1);

fprintf('DBSFILT >> High pass zero-phase filtering : Fstop %0.1fHz - Fpass %0.1fHz - Att %ddB - Ripple %gdB - iir Chebichev type II\n',Fstop,Fpass,Astop,Apass); 
for i=1:nbchan
    fprintf('DBSFILT >> Filtering channel %d ... \n',i);
    reset(Hd);
    x(i,:)=filtfilthd(Hd,x(i,:));
    
end 
disp('DBSFILT >> High pass Filtering : OK.')

