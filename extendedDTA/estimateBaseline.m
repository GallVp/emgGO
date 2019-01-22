function [ baselineMean, baselineStd ] = estimateBaseline( inChannel, numSamples, baselineLevel)
%estimateBaseline Estimates baseline mean and std of length 'numSamples'
%   for 'inChannel' using movsum function.
%
%
%   Copyright (c) <2019> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.

UNIQUE_TOL = 1/max(abs(inChannel)); % 1 unit of input signal.

movSum = movsum(abs(inChannel), numSamples, 'Endpoints', 'discard');    
[~, IA, ~] = uniquetol(movSum, UNIQUE_TOL);

 % Discard can produce a signal of smaller length: LENGTH(X)-K+1
indDiff = numSamples - 1;
startSampleNo = IA(baselineLevel);
interval = startSampleNo - floor(numSamples/2) + 1 : startSampleNo + floor(numSamples/2);
interval = interval + indDiff;

% Temporary solution: If interval(end) - length(inChannel) > 0, push the interval back by L = interval(end) - length(inChannel)
L = interval(end) - length(inChannel);
if(L > 0)
    interval = interval - L;
end

signalBaseline = inChannel(interval);
baselineMean = mean(signalBaseline);
baselineStd = std(signalBaseline);
end