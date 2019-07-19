function [ baselineMean, baselineStd ] = estimateBaseline( inputSignal, baselineLength, baselineRank)
%estimateBaseline Estimates baseline mean and std of length 'numSamples'
%   for 'inChannel' using movmean function.
%
%
%   Copyright (c) <2019> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.

UNIQUE_TOL = 1/max(abs(inputSignal)); % 1 unit of input signal.


% Take the moving average of the signal
movingAverage = movmean(abs(inputSignal), baselineLength, 'Endpoints', 'discard');
% Create a rank order of the moving averages
[~, IA, ~] = uniquetol(movingAverage, UNIQUE_TOL);

% Discard can produce a signal of smaller length: LENGTH(X)-K+1. For that
% case compute the difference in the length of the two signals.
lengthDifference = length(inputSignal) - length(movingAverage);

if baselineRank > length(IA)
    startSampleNo = IA(end);
else
    startSampleNo = IA(baselineRank) + lengthDifference/2;
end

% Select the interval of the baseline segment from the input signal
baselineInterval = startSampleNo - floor(baselineLength/2) + 1 : startSampleNo + floor(baselineLength/2);

% In case of interval problems, return 0, 0
try
    % Compute baseline mean and standard deviation
    baselineSegment         = inputSignal(baselineInterval);
    baselineMean            = mean(abs(baselineSegment));
    baselineStd             = std(abs(baselineSegment));
catch
    baselineMean            = 0;
    baselineStd             = 0;
end
end