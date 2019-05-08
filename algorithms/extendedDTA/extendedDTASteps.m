function [ resultCellArray ] =  extendedDTASteps(singleChannel, fs, optionsVector)
%extendedDTASteps The sequence of options in the optionsVector the is same
%   as listed in getDefaultOptions. This function provides step wise
%   results as a cell array.
%
%
%   Copyright (c) <2019> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.

resultCellArray = cell(length(optionsVector), 2);

% Round using frequency
optionsVector = round(optionsVector .* fs) ./ fs;

% Round EMG_EVENT_NUM_STDS (2), EMG_BASELINE_LEVEL (3),
% EMG_NON_TYPICAL_NUM_STDS (7)
optionsVector(2) = round(optionsVector(2));
optionsVector(3) = round(optionsVector(3));
optionsVector(7) = round(optionsVector(7));

% Estimate baseline parameters
[ emgBaselineMean, emgBaselineSd ] = estimateBaseline(singleChannel,...
    optionsVector(1) * fs, optionsVector(3));


% Detect events using onset, offset and min time
emgEvents = abs(singleChannel) > emgBaselineMean + optionsVector(2) * emgBaselineSd;

resultCellArray{1, 1} = emgEvents;
resultCellArray{1, 2} = [];
resultCellArray{2, 1} = emgEvents;
resultCellArray{2, 2} = [];
resultCellArray{3, 1} = emgEvents;
resultCellArray{3, 2} = [];

[ onSets, offSets ] = consecEvents( emgEvents , optionsVector(4) * fs);
resultCellArray{4, 1} = onSets;
resultCellArray{4, 2} = offSets;


[ onSets, offSets ] = pruneConsecEvents(onSets, offSets, optionsVector(5) * fs);
resultCellArray{5, 1} = onSets;
resultCellArray{5, 2} = offSets;

[ onSets, offSets ] = pruneShortEvents(onSets, offSets, optionsVector(6) * fs);
resultCellArray{6, 1} = onSets;
resultCellArray{6, 2} = offSets;

[ onSets, offSets ] = pruneNontypicalEvents(singleChannel,...
    onSets, offSets, optionsVector(7));
resultCellArray{7, 1} = onSets;
resultCellArray{7, 2} = offSets;

if(optionsVector(8) > 0)
    [ onSets, offSets ] = joinDiscreteEvents(onSets, offSets, optionsVector(8) * fs);
end
resultCellArray{8, 1} = onSets;
resultCellArray{8, 2} = offSets;
end
