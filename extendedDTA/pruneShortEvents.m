function [ onS, offS ] = pruneShortEvents(onSets, offSets, numMinSamples)
%PURGESHORTEVENTS Takes index onsets and offsets and makes sure each set
%   has at least numMinSamles.
%
%
%   Copyright (c) <2019> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.
onS     = onSets(offSets - onSets > numMinSamples);
offS    = offSets(offSets - onSets > numMinSamples);
end