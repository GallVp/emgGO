function [trainCostCurve, cvCostCurve, paramMatrix] = genCostCurvesForTDP(trainCell, detectionAlgo, detectionAlgoDefs)
%genCostCurvesForTDP Generates cost cures for
%   `tuneDetectionParams` optimiser. trainCell is a cell array of EMG
%   structures.
%
%
%   Copyright (c) <2018> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.

% Constants
LAMBDA = 0;

[ initParams, paramLowerBounds, paramUpperBounds, ~, ~, ~, paramPrimer ] = detectionAlgoDefs(trainCell{1}.fs);

numDataSets = length(trainCell);

trainCostCurve  = zeros(1, numDataSets);
cvCostCurve     = zeros(numDataSets, numDataSets - 1);
paramMatrix     = zeros(numDataSets, length(initParams));


underLambda = LAMBDA;

for i = 1 : numDataSets
    % Train on ith set
    underParams = tuneDetectionParams(trainCell{i}.channelData, trainCell{i}.fs,...
        initParams, paramLowerBounds, paramUpperBounds,...
        trainCell{i}.events.onSets, trainCell{i}.events.offSets, detectionAlgo, underLambda);
    
    % Prime parameters
    underParams = paramPrimer(underParams);
    
    % Compute train cost on ith set
    trainCostCurve(1, i) = costFuncAbsentLambda(trainCell{i}.channelData, trainCell{i}.fs,...
        trainCell{i}.events.onSets, trainCell{i}.events.offSets, detectionAlgo, underParams);
    
    % Compute CV cost on the remaining sets
    remainingSets = setdiff(1:numDataSets, i);
    for j = 1:length(remainingSets)
        cvCostCurve(i, j) = costFuncAbsentLambda(trainCell{j}.channelData, trainCell{j}.fs,...
            trainCell{j}.events.onSets, trainCell{j}.events.offSets, detectionAlgo, underParams);
    end
    
    paramMatrix(i, :) = underParams;
end


    function cost = costFuncAbsentLambda(singleChannel, fs, uOnsets, uOffsets, detectionAlgo, P)
        [ onSets, offSets ] =  detectionAlgo(singleChannel, fs, P);
        uBurst       = createBusts(singleChannel, uOnsets, uOffsets);
        algoBurst    = createBusts(singleChannel, onSets, offSets);
        concordance = sum(uBurst == algoBurst) / length(uBurst);
        cost = norm(1-concordance);
    end

if nargout < 1
    figure
    plot(1:numDataSets, trainCostCurve, 'k+');
    hold on;
    
    plot(1:numDataSets, cvCostCurve, 'ro');
    
    pt = plot(1:numDataSets, trainCostCurve, 'k-');
    pc = plot(1:numDataSets, mean(cvCostCurve, 2), 'r-');
    xlabel('Set no.');
    ylabel('Cost');
    legend([pt pc], {'Train', 'CV'}, 'Box', 'off');
end
end