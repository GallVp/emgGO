function paramsVector =  tuneDetectionParamsNoTB(singleChannel, fs, randomInit, initialParams,...
    lowerBounds, upperBounds, uOnsets, uOffsets, detectionAlgo, lambda)
%tuneDetectionParamsNoTB maxConcordance optimisation method when MATLAB's
%   optimisation toolboxes are not installed.
%
%   Copyright (c) <2019> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.

% Defaults
PARAM_MULTIPLIER    = 3;
LAMBDA              = lambda;

totalParams         = length(initialParams);
f                   = @(P)costFunc(singleChannel, fs, uOnsets, uOffsets, detectionAlgo, P);
lb                  = lowerBounds;
ub                  = upperBounds;
swarmMatrix         = initialParams';     % Pop. size by numParams
swarmMatrix         = repmat(swarmMatrix, PARAM_MULTIPLIER*totalParams, 1);


% Problem preparation
PSOparams(1) = 1;
PSOparams(2) = 100;
PSOparams(3) = PARAM_MULTIPLIER*totalParams;
PSOparams(4) = 2;
PSOparams(5) = 2;
PSOparams(6) = 0.9;
PSOparams(7) = 0.4;
PSOparams(8) = 1500;
PSOparams(9) = 1e-6;
PSOparams(10) = 20;
PSOparams(11) = 0;
PSOparams(12) = 1;
PSOparams(13) = ~randomInit;

% Run particle swarm optimiser, first pass
[optOUT,~,~]= pso_Trelea_vectorized(f,totalParams,4,[lb ub], 0, PSOparams, 'psoStatus', swarmMatrix);
paramsVector = optOUT(1:end-1);


    function cost = costFunc(singleChannel, fs, uOnsets, uOffsets, detectionAlgo, P)
        cost = zeros(size(P, 1), 1);
        for i=1:size(P, 1)
            [ onSets, offSets ]     =  detectionAlgo(singleChannel, fs, P(i, :));
            uBurst                  = createBusts(singleChannel, uOnsets, uOffsets);
            algoBurst               = createBusts(singleChannel, onSets, offSets);
            concordance             = sum(uBurst == algoBurst) / length(uBurst);
            cost(i)                 = norm(1-concordance) + LAMBDA*norm(P);
        end
    end
end