function [ baselineMean, baselineStd ] = estimateBaseline( inputSignal, baselineLength, baselineRank)
%estimateBaseline Estimates baseline mean and std of length 'numSamples'
%   for 'inChannel' using movmean function.
%
%
%   Copyright (c) <2019> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.


% Take the moving average of the signal
movingAverage = movmean(abs(inputSignal), baselineLength, 'Endpoints', 'discard');

% Create a rank order of the moving averages
% Make sure moving average is a double
movingAverage = double(movingAverage);
% Round the moving average to 10 decimal places
movingAverage = round(movingAverage, 10);
% Run the uniquetol function with default tolerance of 1e-12
[~, IA, ~] = uniquetol(movingAverage);

%%%%%%%%%%%%%%%%%%%%%%%%%%% For trouble shooting the uniquetol function
%plot(movingAverage(IA)); The result should be monotonically increasing.
% Wikipedia Entry on Monotonic function: https://en.wikipedia.org/wiki/Monotonic_function
% A sample result is available: /emgGO/docs/figs/rankOder_diag.png
%%%%%%%%%%%%%%%%%%%%%%%%%%%

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