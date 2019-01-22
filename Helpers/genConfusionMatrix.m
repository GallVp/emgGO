function [CO, TPR, TNR, OD, UD, PPV, NPV, F1] = genConfusionMatrix(trueBursts, apparantBursts)
%genConfusionMatrix Takes two burst vectors and returns confucion measures.
%
%
%   Copyright (c) <2018> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.

TP      = apparantBursts == 1 & trueBursts == 1;
TN      = apparantBursts == 0 & trueBursts == 0;
FP      = apparantBursts == 1 & trueBursts == 0;
FN      = apparantBursts == 0 & trueBursts == 1;

CO      = (sum(TP) + sum(TN)) / length(trueBursts) * 100;
F1      = 2 * sum(TP) / (2*sum(TP) + sum(FN) + sum(FP)) * 100;

TPR     = sum(TP) / (sum(TP) + sum(FN)) * 100;
TNR     = sum(TN) / (sum(TN) + sum(FP)) * 100;
OD      = sum(FP) / (sum(TP) + sum(FN)) * 100;
UD      = sum(FN) / (sum(TN) + sum(FP)) * 100;
PPV     = sum(TP) / (sum(TP) + sum(FP)) * 100;
NPV     = sum(TN) / (sum(TN) + sum(FN)) * 100;
end

