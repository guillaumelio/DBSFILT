


function x= DBSFILT_cutdata(x,sr,Tcut)
% Reject first and last samples.

samples=sr*Tcut;
x=x(:,samples:end-samples);






