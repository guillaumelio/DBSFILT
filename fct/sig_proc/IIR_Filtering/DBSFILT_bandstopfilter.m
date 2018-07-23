


function x= DBSFILT_bandstopfilter(x,sr,Fcut1,Fcut2,Fbandwidth,Aattenuation,Aripple)
% DBSFILT_bandstopfilter() -
%     DBSFILT_bandstopfilter - Chebychev IIR type II filter design, and
%     zero-phase filtering.
%     
%
%    USAGE :
%                x=DBSFILT_bandstopfilter(x,sr,Fcut1,Fcut2,Fbandwidth,Aattenuation,Aripple)
%
%    INPUTS : 
%                - x          ; EEG data (sensors x samples) in microVolt
%                - sr         ; Sampling Rate
%                - Fcut1      ; First cutting frequency (Hz)
%                - Fcut2      ; Second cutting frequency (Hz)
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


Fpass1 = Fcut1-(Fbandwidth/2);          % Passband Frequency
Fstop1 = Fcut1+(Fbandwidth/2);          % Stopband Frequency
Fstop2 = Fcut2-(Fbandwidth/2);          % Stopband Frequency
Fpass2 = Fcut2+(Fbandwidth/2);          % Passband Frequency
Astop = Aattenuation;                 % Stopband Attenuation (dB)
Apass = Aripple;                      % Passband Ripple (dB)
match = 'passband';                   % Band to match exactly

h  = fdesign.bandstop(Fpass1, Fstop1, Fstop2, Fpass2,Apass, Astop, Apass, sr);
Hd = design(h, 'cheby2', 'MatchExactly', match);

nbchan=size(x,1);

fprintf('DBSFILT >> Stop band zero-phase filtering : Fpass1 %0.1fHz - Fstop1 %0.1fHz - Fstop2 %0.1fHz - Fpass2 %0.1fHz - Att %ddB - Ripple %gdB - iir Chebichev type II\n',Fpass1,Fstop1,Fstop2,Fpass2,Astop,Apass); 
for i=1:nbchan
    fprintf('DBSFILT >> Filtering channel %d ... \n',i);
    reset(Hd);
    x(i,:)=filtfilthd(Hd,x(i,:));
    
end 
disp('DBSFILT >> Band stop Filtering : OK.')



