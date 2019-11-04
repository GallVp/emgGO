function tau =  autoApplyActivationsNoTB(singleChannel, fs, activationKernel, randomInit, initialTau,...
    lowerBound, upperBound)
%autoApplyActivations Minimises baseline energy for a given
%   activationKernel on a single channel of emg data. This version is used
%   when MATLAB's optimisation toolboxes are not installed. 
%
%
%   Copyright (c) <2019> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.

% Defaults
PARAM_MULTIPLIER    = 3;


totalParams         = length(initialTau);
f                   = @(tau)costFunc(singleChannel, fs, activationKernel, tau);
lb                  = lowerBound;
ub                  = upperBound;
swarmMatrix         = initialTau;
swarmMatrix         = repmat(swarmMatrix, PARAM_MULTIPLIER*totalParams, 1);


% Problem preparation
PSOparams(1)        = 1;
PSOparams(2)        = 100;
PSOparams(3)        = PARAM_MULTIPLIER*totalParams;
PSOparams(4)        = 2;
PSOparams(5)        = 2;
PSOparams(6)        = 0.9;
PSOparams(7)        = 0.4;
PSOparams(8)        = 1500;
PSOparams(9)        = 1e-3;
PSOparams(10)       = 20;
PSOparams(11)       = 0;
PSOparams(12)       = 1;
PSOparams(13)       = ~randomInit;


% Run particle swarm optimiser, first pass
[optOUT,~,~]        = pso_Trelea_vectorized(f,totalParams,4,[lb ub], 0, PSOparams, '', swarmMatrix);
tau                 = optOUT(1:end-1);

    function cost                       = costFunc(singleChannel, fs, activationKernel, tau)
        cost                            = zeros(size(tau, 1), 1);
        for i=1:size(tau, 1)
            tauSamples                  = round(tau(i, :)*fs);
            
            onsets                      = activationKernel(:, 1)+tauSamples;
            offsets                     = activationKernel(:, 2)+tauSamples;
            onsets(onsets<=1)           = 1;
            offsets(offsets<=1)         = 1;
            lChannel                    = length(singleChannel);
            onsets(onsets>=lChannel)    = lChannel;
            offsets(offsets>=lChannel)  = lChannel;
            algoBurst                   = createBusts(singleChannel, onsets, offsets);
            [~, tkoEnergy]              = energyop(singleChannel, 0);
            totalEnergy                 = sum(tkoEnergy);
            baseEnergy                  = sum(tkoEnergy(~algoBurst));
            cost(i)                     = baseEnergy / totalEnergy;
        end
    end
end