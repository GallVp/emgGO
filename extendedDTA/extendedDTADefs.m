function [ paramVector, paramLowerBounds, paramUpperBounds, paramNames, paramIncrement, paramIsInt, paramPrimer ] = extendedDTADefs(fs)
%extendedDTADefs Provides defaults for the extendedDTA algorithm.
%
%
%   Copyright (c) <2018> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.

paramVector         = [0.1     1       1       0.05    0.05    0.5     2       0]';


% Set param bounds for bounded optimisation routines
paramLowerBounds    = [0.1     1       1       5/fs    5/fs    5/fs    1       0]';
paramUpperBounds    = [1       10      100     1       1       10      10      10]';
paramIncrement      = [1/fs    1       1       1/fs    1/fs    1/fs    1       1/fs]';
paramIsInt          = [0       1       1       0       0       0       1       0]';

paramNames          = {'Baseline length (s)',...
    'Stds. above baseline (n)',...
    'Baseline level (n)',...
    'Onset time (s)',...
    'Offset time (s)',...
    'Min. active time (s)',...
    'Non-typical stds. (n)',...
    'Join events within (s)'};

    function P = paramPrimerFunc(P)
        P       = round(P .* fs) ./ fs;
        P(2)    = round(P(2));
        P(3)    = round(P(3));
        P(7)    = round(P(7));
    end
    paramPrimer = @paramPrimerFunc;
end