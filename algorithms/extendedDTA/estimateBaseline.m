function [ baselineMean, baselineStd ] = estimateBaseline( inChannel, baselineLength, baselineLevel)
%estimateBaseline Estimates baseline mean and std of length 'numSamples'
%   for 'inChannel' using movmean function.
%
%
%   Copyright (c) <2019> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.

UNIQUE_TOL = 1/max(abs(inChannel)); % 1 unit of input signal.

movAvg = movmean(abs(inChannel), baselineLength, 'Endpoints', 'discard');
[~, IA, ~] = uniquetol(movAvg, UNIQUE_TOL);

% Discard can produce a signal of smaller length: LENGTH(X)-K+1
indDiff = length(inChannel) - length(movAvg);

if baselineLevel > length(IA)
    startSampleNo = IA(end);
else
    startSampleNo = IA(baselineLevel) + indDiff/2;
end
interval = startSampleNo - floor(baselineLength/2) + 1 : startSampleNo + floor(baselineLength/2);

% In case of interval problems, return 0, 0
try
    baselineSegment         = inChannel(interval);
    baselineMean            = mean(abs(baselineSegment));
    baselineStd             = std(abs(baselineSegment));
catch
    baselineMean            = 0;
    baselineStd             = 0;
end
end