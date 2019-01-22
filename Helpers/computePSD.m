function [ X, f ] = computePSD( x, fs, na )
%computePSD Estimates power spectral density pwelch. This code is written
%   in accordance with the recommendations of Hanspeter Schmid, "How to use
%   the FFT and Matlab?s pwelch function for signal and
%   noise simulations and measurements", 2011.
%
%
%   Copyright (c) <2019> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.
if nargin < 3
    na = 16;
end
nx = length(x);
w = hanning(floor(nx/na));

[X, f] = pwelch(x, w, 0, [], fs);

X = 10.*log10(X);
end

