function [ onSetPoints, offSsetPoints ] = consecEvents(eventSignal, leastNumEvents)
%consecEvents Takes a multichannel logical signal and produces two index
%   signals indicating start and end of consecutive 'leastNumEvents' 1s.
%
%
%   Copyright (c) <2019> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.
if nargin < 2
    leastNumEvents      = 2;
end

diffOfSignal            = diffWithInitialValue([eventSignal;...
    zeros(1, size(eventSignal, 2))]);
posDiffSignal           = diffOfSignal > 0;
negDiffSignal           = diffOfSignal < 0;
posDiffPoints           = find(posDiffSignal);
negDiffPoints           = find(negDiffSignal);

leastNumEventsFound     = (negDiffPoints - posDiffPoints)...
    >= leastNumEvents;

onSetPoints             = posDiffPoints(leastNumEventsFound);
offSsetPoints           = negDiffPoints(leastNumEventsFound) - 1;
end