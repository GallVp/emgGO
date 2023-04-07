function outputEMG              = ecgFilter(inputEMG, powerLineFreq, algoName)
%ECGFILTER Filters ECG from EMG using the ecg-removal toolbox.
% Default algorithm is template sebtraction ('ts').
%
% Available algorithms:
% 'ts':     Template sebtraction (very fast)
% 'ats':    Adaptive template sebtraction (reference)
% 'pats':   Probabilistic adaptive template sebtraction (very very slow)
% 'swt':    Stationary wavelet transform (fast)
% 'ekf2':   Second order extended kalman smoother (slow)
% 'ekf25':  25th order extended kalman smoother (slow)
% 'emd':    Empirical mode decomposition (very slow)


if nargin < 3
    algoName = 'ts';
end

inputChannelData                = inputEMG.channelData;
fs                              = inputEMG.fs;

outputChannelData               = NaN .* ones(size(inputChannelData));

% Algo setup
useFiltFilt                     = 1;
filerPLRemoval                  = @(sig) butter_filt_stabilized(sig, [powerLineFreq-1 powerLineFreq+1], fs, 'stop', useFiltFilt, 2);
filterHP10                      = @(sig) butter_filt_stabilized(sig, 10, fs, 'high', useFiltFilt, 6);
algoRPeak                       = @(sig, time) peak_detection(sig, fs, time);
algoTS                          = @(sig, rPeaks) template_subtraction(sig, rPeaks, min(length(rPeaks), 40));
algoATS                         = @(sig, rPeaks) adaptive_template_subtraction(sig, rPeaks, fs, min(length(rPeaks), 40));
algoPATS                        = @(signal, rpeaks) PATS(signal, rpeaks, fs, 0, [], [], powerLineFreq);
algoSWT                         = @(signal, rPeaks) swtden(signal, rPeaks, fs, 'h', 3, 'db2', 4.5);
algoEKF2                        = @(signal, rpeaks) kalman_filter_2(signal, rpeaks, fs);
algoEKF25                       = @(signal, rpeaks) kalman_filter_25(signal, rpeaks, fs);
algoEMD                         = @(signal) EMD(signal, 60, 1);

if(strcmp(algoName, 'ts'))
    selectedAlgo                = @(signal, rpeaks) algoTS(signal, rpeaks);
elseif(strcmp(algoName, 'ats'))
    selectedAlgo                = @(signal, rpeaks) algoATS(signal, rpeaks);
elseif(strcmp(algoName, 'pats'))
    selectedAlgo                = @(signal, rpeaks) algoPATS(signal, rpeaks);
elseif(strcmp(algoName, 'swt'))
    selectedAlgo                = @(signal, rpeaks) algoSWT(signal, rpeaks);
elseif(strcmp(algoName, 'ekf2'))
    selectedAlgo                = @(signal, rpeaks) algoEKF2(signal, rpeaks);
elseif(strcmp(algoName, 'ekf25'))
    selectedAlgo                = @(signal, rpeaks) algoEKF25(signal, rpeaks);
elseif(strcmp(algoName, 'emd'))
    selectedAlgo                = @(signal, rpeaks) algoEMD(signal);
else
    error('No such algorithm: %s', algoName);
end

for i=1:size(inputEMG.channelData, 2)

    signal                      = inputChannelData(:, i);
    tVect                       = (1:length(signal))./fs;

    plRemovedSignal             = filerPLRemoval(signal);
    hp10Signal                  = filterHP10(plRemovedSignal);

    rPeaks                      = algoRPeak(hp10Signal, tVect);

    cleanSignal                 = selectedAlgo(hp10Signal, rPeaks);

    outputChannelData(:, i)     = cleanSignal;
end

outputEMG                       = inputEMG;
outputEMG.channelData           = outputChannelData;
end

