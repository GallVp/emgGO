function [onSets, offSets] =  extendedDTA(singleChannel, fs, optionsVector)
%extendedDTA
%   Takes a single channel of sEMG data along with the sampling frequency
%   and applies the extended double thresholding algorithm with parameters
%   specified in optionsVector.
%
%   Inputs:
%   singleChannel: A vector with single channel sEMG data.
%   fs:            The sampling frequency of the input signal.
%   optionsVector: A vector of algorithm parameters. The parameters are
%                  specified in the following order.
%                  1. Baseline length (seconds)
%                  2. Stds. above baseline (number)
%                  3. Baseline rank (number)
%                  4. On time (seconds)
%                  5. Off time (seconds)
%                  6. Min. active time (seconds)
%                  7. Non-typical stds. (number)
%                  8. Join events within (seconds)
%
%   Outputs:
%   onSets:        A vector of muscle activation onsets represented as
%                  indices of the singleChannel.
%   offSets:       A vector of muscle activation offsets represented as
%                  indices of the singleChannel.
%
%
%   Copyright (c) <2019> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.

%% Prime the algorithm parameters
% Round using frequency. This is done to make sure that the time parameters
% do not result in non-integers when multiplied with the sampling frequency.
optionsVector = round(optionsVector .* fs) ./ fs;
% Round the parameters which are supposed to be integers in case these are
% misspecified by the user or the optimisation method.
optionsVector(2) = round(optionsVector(2));
optionsVector(3) = round(optionsVector(3));
optionsVector(7) = round(optionsVector(7));


%% Algorithm steps

% 1. Baseline detection
[emgBaselineMean, emgBaselineSd] = estimateBaseline(singleChannel,...
    optionsVector(1) * fs, optionsVector(3));

% 2. First threshold using baseline parameters
aboveBaselineEvents = abs(singleChannel) > emgBaselineMean + optionsVector(2) * emgBaselineSd;

% 3. Second threshold using on time
[onSets, offSets] = consecEvents( aboveBaselineEvents , optionsVector(4) * fs);

% 4. Third threshold using offtime
[onSets, offSets] = pruneConsecEvents(onSets, offSets, optionsVector(5) * fs);

% 5. Prune short events
[onSets, offSets] = pruneShortEvents(onSets, offSets, optionsVector(6) * fs);

% 6. Prune non-typical bursts
[onSets, offSets] = pruneNontypicalEvents(singleChannel,...
    onSets, offSets, optionsVector(7));

% 7. Join movement components
if(optionsVector(8) > 0)
    [onSets, offSets] = joinDiscreteEvents(onSets, offSets, optionsVector(8) * fs);
end
end