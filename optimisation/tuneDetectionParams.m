function paramsVector =  tuneDetectionParams(singleChannel, fs, initialParams,...
    lowerBounds, upperBounds, uOnsets, uOffsets, detectionAlgo, lambda, funcVer)
%tuneDetectionParams maxConcordance optimisation method.
%
%   The function has two versions. v1 only uses particle swarm optimiser.
%   v2 uses a combination of particle swarm and MATLAB's default
%   interior-point algorithm for faster execution.
%
%   Copyright (c) <2019> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.

if nargin < 9
    lambda = 0;
end

if nargin < 9
    lambda = 0;
    funcVer = 'v2';
elseif nargin < 10
    funcVer = 'v2';
end

% Defaults
PARAM_MULTIPLIER    = 3;
LAMBDA              = lambda;

% Global Variables
haltingState        = 0;

totalParams         = length(initialParams);
f                   = @(P)costFunc(singleChannel, fs, uOnsets, uOffsets, detectionAlgo, P);
lb                  = lowerBounds;
ub                  = upperBounds;
swarmMatrix         = initialParams';                % M by nvars

if strcmp(funcVer, 'v1')
    optimOptions = optimoptions('particleswarm',...
        'SwarmSize', PARAM_MULTIPLIER * totalParams,...
        'UseParallel', true,...
        'OutputFcn', @psOutFunc,...
        'InitialSwarmMatrix', swarmMatrix,...
        'ObjectiveLimit', 0,...
        'FunctionTolerance', 1e-6);
elseif strcmp(funcVer, 'v2')
    hybridopts = optimoptions('fmincon',...
        'Algorithm', 'interior-point',...
        'OutputFcn', @ipOutFunc,...
        'FunctionTolerance', 1e-6);
    optimOptions = optimoptions('particleswarm',...
        'SwarmSize', PARAM_MULTIPLIER * totalParams,...
        'UseParallel', true,...
        'OutputFcn', @psOutFunc,...
        'InitialSwarmMatrix', swarmMatrix,...
        'ObjectiveLimit', 0,...
        'FunctionTolerance', 1e-6,...
        'HybridFcn', {@fmincon, hybridopts});
end

% Run particle swarm optimiser
hMsg = infoDialog('Starting parallel pool...');
drawnow;
[P,~,~,~] = particleswarm(f, totalParams, lb, ub, optimOptions);
paramsVector = P;


    function cost = costFunc(singleChannel, fs, uOnsets, uOffsets, detectionAlgo, P)
        [ onSets, offSets ]     =  detectionAlgo(singleChannel, fs, P);
        uBurst                  = createBusts(singleChannel, uOnsets, uOffsets);
        algoBurst               = createBusts(singleChannel, onSets, offSets);
        concordance             = sum(uBurst == algoBurst) / length(uBurst);
        cost                    = norm(1-concordance) + LAMBDA*norm(P);
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