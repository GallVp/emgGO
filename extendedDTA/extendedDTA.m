function [ onSets, offSets ] =  extendedDTA(singleChannel, fs, optionsVector)
%extendedDTA The sequence of options in the optionsVector is same as
%   listed in getDefaultOptions.
%
%
%   Copyright (c) <2019> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.


% Round using frequency
optionsVector = round(optionsVector .* fs) ./ fs;

% Round EMG_BASELINE_LEVEL, EMG_EVENT_NUM_STDS, EMG_NON_TYPICAL_NUM_STDS
optionsVector(2) = round(optionsVector(2));
optionsVector(3) = round(optionsVector(3));
optionsVector(7) = round(optionsVector(7));

% Estimate baseline parameters
[ emgBaselineMean, emgBaselineSd ] = estimateBaseline(singleChannel,...
    optionsVector(1) * fs, optionsVector(3));


% Detect events using onset, offset and min time
emgEvents = abs(singleChannel) > emgBaselineMean + optionsVector(2) * emgBaselineSd;
[ onSets, offSets ] = consecEvents( emgEvents , optionsVector(4) * fs);

[ onSets, offSets ] = pruneConsecEvents(onSets, offSets, optionsVector(5) * fs);

[ onSets, offSets ] = pruneShortEvents(onSets, offSets, optionsVector(6) * fs);

[ onSets, offSets ] = pruneNontypicalEvents(singleChannel,...
    onSets, offSets, optionsVector(7));

if(optionsVector(8) > 0)
    [ onSets, offSets ] = joinDiscreteEvents(onSets, offSets, optionsVector(8) * fs);
end
end
