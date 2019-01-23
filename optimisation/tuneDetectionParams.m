function paramsVector =  tuneDetectionParams(singleChannel, fs, initialParams, lowerBounds, upperBounds, uOnsets, uOffsets, detectionAlgo, lambda)
%tuneDetectionParams
%
%
%   Copyright (c) <2019> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.

if nargin < 9
    lambda = 0;
end

% Defaults
PARAM_MULTIPLIER    = 3;
LAMBDA              = lambda;

totalParams         = length(initialParams);
f                   = @(P)costFunc(singleChannel, fs, uOnsets, uOffsets, detectionAlgo, P);
lb                  = lowerBounds;
ub                  = upperBounds;
swarmMatrix         = initialParams';                % M by nvars

optimOptions = optimoptions('particleswarm',...
    'SwarmSize', PARAM_MULTIPLIER * totalParams,...
    'UseParallel', true,...
    'Display', 'Iter',...
    'InitialSwarmMatrix', swarmMatrix,...
    'ObjectiveLimit', 0,...
    'FunctionTolerance', 1/fs);

% Run particle swarm optimiser
hMsg = msgbox('Optimisation in progress...', 'Info', 'Modal');
[P,~,~,~] = particleswarm(f, totalParams, lb, ub, optimOptions);
close(hMsg);
paramsVector = P;


    function cost = costFunc(singleChannel, fs, uOnsets, uOffsets, detectionAlgo, P)
        [ onSets, offSets ]     =  detectionAlgo(singleChannel, fs, P);
        uBurst                  = createBusts(singleChannel, uOnsets, uOffsets);
        algoBurst               = createBusts(singleChannel, onSets, offSets);
        concordance             = sum(uBurst == algoBurst) / length(uBurst);
        cost                    = norm(1-concordance) + LAMBDA*norm(P);
    end
end