function [ onS, offS ] = pruneNontypicalEvents(inSignal, onSets, offSets, numStds)
%purgeNontypicalEvents Take index onsets and offsets and makes sure their
%   corresponding signal lies within given number of stds of mean rms,
%   given 'inSignal'.
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

signalRMS = zeros(length(onSets), 1);
for i = 1 : length(onSets)
    signalRMS(i) = rms(inSignal(onSets(i):offSets(i)));
end

% Find mean rms
meanRMS = mean(signalRMS);
stdRMS = std(signalRMS);


onS = onSets(signalRMS > (meanRMS - stdRMS*numStds) & signalRMS < (meanRMS + stdRMS*numStds));
offS = offSets(signalRMS > (meanRMS - stdRMS*numStds) & signalRMS < (meanRMS + stdRMS*numStds));

end