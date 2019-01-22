function [bustSignal] = createBusts(inSignal, fromOnsets, toOffsets)
%createBusts
%
%
%   Copyright (c) <2018> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.
bustSignal = zeros(size(inSignal));

for i=1:length(fromOnsets)
    if(toOffsets(i) > length(inSignal))
        continue;
    end
    bustSignal(fromOnsets(i): toOffsets(i)) = 1;
end
bustSignal = bustSignal == 1;
end

