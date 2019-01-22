function [filteredData] = filterStream(data, fs, order, fcLow, fcHigh, zeroPhase)
%filterStream(data, fs, order, fcLow, fcHigh, zeroPhase)
%   Applies low and high pass butterworth filter to a stream of data.
%
%
%   Default Parameters:
%   zeroPhase = 1; If true, filtfilt is used instead of filter.
%   fcHigh = 0.05 Hz
%   fcLow = 1 Hz
%   order = 2
%
%   Copyright (c) <2019> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for 
%   license information.

if (nargin < 3)
    zeroPhase = 1;
    fcHigh = 0.05;
    fcLow = 1;
    order = 2;
elseif (nargin < 4)
    zeroPhase = 1;
    fcHigh = 0.05;
    fcLow = 1;
elseif (nargin < 5)
    zeroPhase = 1;
    fcHigh = 0.05;
elseif (nargin < 6)
    zeroPhase = 1;
end

[b, a]  = butter(order, fcLow/(fs/2), 'low');
[bb, aa] = butter(order, fcHigh/(fs/2), 'high');

if(zeroPhase)
    filteredData = filtfilt(b,a, data);
    filteredData = filtfilt(bb,aa,filteredData);
else
    filteredData = filter(b,a, data);
    filteredData = filter(bb,aa,filteredData);
end