function paramsVector =  autoFindActivations(singleChannel, fs, initialParams, lowerBounds, upperBounds, numActiv, detectionAlgo, lParam)
%autoFindActivations nOptim Optimisation method.
%
%
%   Copyright (c) <2018> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.

if nargin < 8
    lParam = [1 1];
end

% Defaults
PARAM_MULTIPLIER    = 3;
ALPHA               = lParam(1);
BETA                = lParam(2);


totalParams         = length(initialParams);
f                   = @(P)costFunc(singleChannel, fs, numActiv, detectionAlgo, P);
lb                  = lowerBounds;
ub                  = upperBounds;
swarmMatrix         = initialParams';                % M by nvars

optimOptions = optimoptions('particleswarm',...
    'SwarmSize', PARAM_MULTIPLIER * totalParams,...
    'UseParallel', true,...
    'Display', 'Iter',...
    'InitialSwarmMatrix', swarmMatrix,...
    'ObjectiveLimit', 0);

% Run particle swarm optimiser, first pass
hMsg = msgbox('First pass optimisation in progress...', 'nOptim', 'Modal');
[P,~,~,~] = particleswarm(f, totalParams, lb, ub, optimOptions);
close(hMsg);

% Check if first pass was successful. If not, run second pass
if f(P) > 1
    % Run particle swarm optimiser, second pass
    hMsg = msgbox('Second pass optimisation in progress...', 'nOptim', 'Modal');
    [P,~,~,~] = particleswarm(f, totalParams, lb, ub, optimOptions);
    close(hMsg);
end

paramsVector = P;

    function cost = costFunc(singleChannel, fs, numActiv, detectionAlgo, P)
        [ onSets, offSets ] =  detectionAlgo(singleChannel, fs, P);
        algoBurst    = createBusts(singleChannel, onSets, offSets);
        burstSamples = sum(algoBurst);
        N = length(algoBurst);
        [~, tkoEnergy] = energyop(singleChannel, 0);
        totalEnergy = sum(tkoEnergy);
        baseEnergy = sum(tkoEnergy(~algoBurst));
        cost = norm(numActiv - length(onSets)) + ALPHA * burstSamples / N + BETA * baseEnergy / totalEnergy;
    end
end



