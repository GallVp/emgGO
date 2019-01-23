function paramsVector =  autoFindActivations(singleChannel, fs, initialParams,...
    lowerBounds, upperBounds, numActiv, detectionAlgo, lParam, funcVer)
%autoFindActivations nOptim Optimisation method.
%
%   The function has two versions. v1 only uses particle swarm optimiser.
%   v2 uses a combination of particle swarm and MATLAB's default
%   interior-point algorithm for faster execution.
%
%
%   Copyright (c) <2019> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.

if nargin < 8
    lParam  = [1 1];
    funcVer = 'v2';
elseif nargin < 9
    funcVer = 'v2';
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

if strcmp(funcVer, 'v1')
    optimOptions = optimoptions('particleswarm',...
        'SwarmSize', PARAM_MULTIPLIER * totalParams,...
        'UseParallel', true,...
        'Display', 'Iter',...
        'InitialSwarmMatrix', swarmMatrix,...
        'ObjectiveLimit', 0);
elseif strcmp(funcVer, 'v2')
    hybridopts = optimoptions('fmincon',...
        'Display', 'iter',...
        'Algorithm', 'interior-point',...
        'FunctionTolerance', 1e-6);
    optimOptions = optimoptions('particleswarm',...
        'SwarmSize', PARAM_MULTIPLIER * totalParams,...
        'UseParallel', true,...
        'Display', 'Iter',...
        'InitialSwarmMatrix', swarmMatrix,...
        'ObjectiveLimit', 0,...
        'FunctionTolerance', 0.1,...
        'HybridFcn', {@fmincon, hybridopts});
end

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



