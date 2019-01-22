function [ diffOfData ] = diffWithInitialValue( data, initValues )
%diffWithInitialValue Takes the differential of a vector or column
%   wise differential of a matrix with initial values appended at the
%   beginning.
%
%
%   Copyright (c) <2018> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.

if (size(data, 1) == 1)
    if nargin < 2
        initValues = 0;
    end
    diffOfData = diff([initValues data]);
else
    if nargin < 2
        initValues = zeros(1, size(data, 2));
    end
    diffOfData = diff([initValues;data]);
end
end

