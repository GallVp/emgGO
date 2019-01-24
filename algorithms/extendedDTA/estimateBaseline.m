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

if baselineLevel > length(IA)
    startSampleNo = IA(end);
else
    startSampleNo = IA(baselineLevel);
end
interval = startSampleNo - floor(numSamples/2) + 1 : startSampleNo + floor(numSamples/2);
interval = interval + indDiff;

% In case of interval problems, return 0, 0
try
    signalBaseline = inChannel(interval);
    baselineMean = mean(signalBaseline);
    baselineStd = std(signalBaseline);
catch
    baselineMean = 0;
    baselineStd = 0;
end

end