function [filterBankResponse] = prepareAudio(dirAudio, demandSampleRate)
% [filterBankResponse] = prepareAudio(dirAudio) 
% Load Audiofile and return Filter Bank Response of it.
% 
% dirAudio : string that indicate absolute directory of target Audiofile
% demandSampleRate : double. nSample per second (demanding). 
% Default is 50 (1 sample : 20ms)

%	Version 1.00
%	06.07.2016
%	Copyright (c) by Taegyun Kwon
%	ilcobo2@kaist.ac.kr

if nargin<2; demandSampleRate = 50; end;

[wavAudio,wavSampleRate] = audioread(dirAudio);
filterBankResponse = computeFilterBankResponse(wavAudio,wavSampleRate,demandSampleRate); % this response contains unexpected negative values
filterBankResponse(filterBankResponse<0)=0; % for temporal correction for this problem
filterBankResponse=log(1+5000*filterBankResponse);
filterBankResponse=filterBankResponse(21:108,:);


end

