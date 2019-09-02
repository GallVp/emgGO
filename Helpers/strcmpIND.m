function [ presentAt ] = strcmpIND( inCell, findCell, caseMatch )
%strcmpIND Finds findCell in inCell and returns an index vector
%
%
%   Copyright (c) <2019> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.

if nargin < 3
    caseMatch = 1;
end

presentAt = zeros(size(findCell));

for i=1:max(size(findCell))
    if(caseMatch)
        ind = find(strcmp(inCell, findCell{i}), 1);
    else
        ind = find(strcmpi(inCell, findCell{i}), 1);
    end
    if(~isempty(ind))
        presentAt(i) = ind;
    end
end

presentAt = presentAt(presentAt ~=0);
end

