function paramsVector =  autoFindActivations(singleChannel, fs, randomInit, initialParams,...
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

if nargin < 9
    lParam  = [1 1];
    funcVer = 'v2';
elseif nargin < 10
    funcVer = 'v2';
end

% Defaults
PARAM_MULTIPLIER    = 3;
ALPHA               = lParam(1);
BETA                = lParam(2);

% Global Variables
haltingState        = 0;


totalParams         = length(initialParams);
f                   = @(P)costFunc(singleChannel, fs, numActiv, detectionAlgo, P);
lb                  = lowerBounds;
ub                  = upperBounds;
swarmMatrix         = initialParams';                % M by nvars

if strcmp(funcVer, 'v1')
    if randomInit
        optimOptions = optimoptions('particleswarm',...
            'SwarmSize', PARAM_MULTIPLIER * totalParams,...
            'UseParallel', true,...
            'OutputFcn', @psOutFunc,...
            'ObjectiveLimit', 0);
    else
        
        optimOptions = optimoptions('particleswarm',...
            'SwarmSize', PARAM_MULTIPLIER * totalParams,...
            'UseParallel', true,...
            'OutputFcn', @psOutFunc,...
            'InitialSwarmMatrix', swarmMatrix,...
            'ObjectiveLimit', 0);
    end
elseif strcmp(funcVer, 'v2')
    hybridopts = optimoptions('fmincon',...
        'Algorithm', 'interior-point',...
        'OutputFcn', @ipOutFunc,...
        'FunctionTolerance', 1e-6);
    if randomInit
        optimOptions = optimoptions('particleswarm',...
            'SwarmSize', PARAM_MULTIPLIER * totalParams,...
            'UseParallel', true,...
            'OutputFcn', @psOutFunc,...
            'ObjectiveLimit', 0,...
            'FunctionTolerance', 0.1,...
            'HybridFcn', {@fmincon, hybridopts});
    else
        optimOptions = optimoptions('particleswarm',...
            'SwarmSize', PARAM_MULTIPLIER * totalParams,...
            'UseParallel', true,...
            'OutputFcn', @psOutFunc,...
            'InitialSwarmMatrix', swarmMatrix,...
            'ObjectiveLimit', 0,...
            'FunctionTolerance', 0.1,...
            'HybridFcn', {@fmincon, hybridopts});
    end
end

% Run particle swarm optimiser, first pass
hMsg = infoDialog('Starting parallel pool...');
drawnow;
[P,~,~,~] = particleswarm(f, totalParams, lb, ub, optimOptions);

% Check if first pass was successful. If not, run second pass
if f(P) > 1 && isvalid(hMsg)
    % Run particle swarm optimiser, second pass
    set(hMsg.Children(2), 'String', 'Starting second pass...');
    drawnow;
    [P,~,~,~] = particleswarm(f, totalParams, lb, ub, optimOptions);
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

    function stop = psOutFunc(x, ~)
        if haltingState
            stop = true;
        else
            stop = false;
            set(hMsg.Children(2), 'String', sprintf('Running particleswarm\nIter no. %d\nCost: %0.3f', x.iteration, x.bestfval));
            drawnow;
        end
        
    end

    function stop = ipOutFunc(~, optimValues, ~)
        if haltingState
            stop = true;
        else
            stop = false;
            set(hMsg.Children(2), 'String', sprintf('Running interior-point\nIter no. %d', optimValues.iteration));
            drawnow;
        end
        
    end

    function d = infoDialog(msg)
        
        d = dialog('Position', [300 300 250 150],...
            'Name','nOptim',...
            'WindowStyle', 'modal',...
            'CloseRequestFcn', @haltAndCloseOperation);
        
        txtInfo = uicontrol('Parent',d,...
            'Style','text',...
            'Position',[20 80 210 40],...
            'String', msg);
        
        btnCtrl = uicontrol('Parent',d,...
            'Position',[85 20 70 25],...
            'String','Halt!',...
            'Callback', @haltOperation);
    end

    function haltOperation(~, ~)
        haltingState = 1;
    end

    function haltAndCloseOperation(src, ~)
        haltingState = 1;
        delete(src);
    end

if ~isempty(hMsg)
    delete(hMsg);
end
end