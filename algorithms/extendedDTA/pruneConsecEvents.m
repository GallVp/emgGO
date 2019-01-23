function [ onS, offS ] = pruneConsecEvents( onSets, offSets, numSepSamples )
%PRUNECONSECEVENTS Takes index onsets and offsets and makes sure that two
%   consecutive sets are separated by atleast numSepSamples.
%
%
%   Copyright (c) <2019> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.

if isempty(onSets)
    onS = [];
    offS = [];
    return
end

onSetsShifted       = onSets(2:end, :);
offSetsTruncated    = offSets(1:end-1, :);

onS = onSets([true; onSetsShifted...
    - offSetsTruncated > numSepSamples], :);
offS = offSets([onSetsShifted...
    - offSetsTruncated > numSepSamples; true], :);
end

