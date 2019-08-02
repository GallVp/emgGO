function [returnEMG, returnParams] = emgEventsDetectTool(EMG, options)
%emgEventsDetectTool A GUI tool for detecting events from continuous
% channels of emg data using 'detectionOptions'.
%
%   Inputs:
%       1. EMG: A structure with following fields:
%       a. channelData: A matrix with column wise emg channels.
%       b. fs: A scalar with sampling frequency.
%       c. channelNames (Optional): A cell array of channel names
%       2. options: A structure with following fields
%       a. xLabel           = {'Time (s)'};
%       b. yLabel           = 'Amplitude';
%       c. lineWidth        = 1;
%       d. markerLineWidth  = 1;
%       e. eventLineWidth   = 1;
%       f. eventMarkerSize  = 8;
%       g. showFinalResult  = 1;
%       h. detectionAlgo    = @extendedDTA
%       i. algoDefProvider  = @extendedDTADefs
%       j. subParams        : Substitute parameters.
%
%   Outputs:
%       1. EMG: The same input structure with following additional fileds
%       a. channelData: A matrix with channel wise emg data.
%       b. events.onSets: A matrix with channel wise onset indices
%       c. events.offSets: A matrix with channel wise offset indices
%       2. returnParams: A matrix of detection parameters with columns
%           corresponding to channels.
%
%
%   Copyright (c) <2019> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.

% Constants
vars.ONSETS_COLUMN_NUM        = 1;
vars.OFFSETS_COLUMN_NUM       = 2;
vars.ON_OFF_CELL              = {'off', 'on'};


% Assign vars from inputs
vars.fs                       = EMG.fs;
vars.numChannels              = size(EMG.channelData, 2);
vars.numSamples               = size(EMG.channelData, 1);


% Assign default options
vars.options.xLabel           = {'Time (s)'};
vars.options.yLabel           = 'Amplitude';
vars.options.lineWidth        = 1;
vars.options.markerLineWidth  = 1;
vars.options.eventLineWidth   = 1;
vars.options.eventMarkerSize  = 8;
vars.options.showFinalResult  = 1;
vars.options.showRectifiedEmg = 1;
vars.options.detectionAlgo    = @extendedDTA;
vars.options.detectionAlgoSteps= @extendedDTASteps;
vars.options.algoDefProvider  = @extendedDTADefs;

[ defParams, paramLowerBounds, paramUpperBounds, paramNames, paramIncrement, paramIsInt, paramPrimer ] = vars.options.algoDefProvider(vars.fs);

% Assign more default options
vars.options.subParams        = defParams;
vars.options.paramNames       = paramNames;
vars.options.paramUpperBounds = paramUpperBounds;
vars.options.paramLowerBounds = paramLowerBounds;
vars.options.paramIncrement   = paramIncrement;
vars.options.paramIsInt       = paramIsInt;
vars.options.totalParams      = length(defParams);
vars.options.paramPrimer      = paramPrimer;

switch(nargin)
    case 1
        vars.EMG                  = EMG;
    case 2
        vars.EMG                  = EMG;
        vars.options              = assignOptions(options, vars.options);
end

% Calculate abscissa from fs
vars.abscissa         = (1:vars.numSamples) ./ vars.fs;
vars.channelStream    = vars.EMG.channelData;


vars.eventAmplitude   = (max(vars.channelStream) - min(vars.channelStream)) / 4;

% Initial settings
vars.channelNum       = 1;
vars.paramNum         = 1;

% Compute detection parameters
if(isvector(vars.options.subParams))
    if(isrow(vars.options.subParams))
        vars.options.subParams = vars.options.subParams';
    end
    vars.detectionParams = repmat(vars.options.subParams, 1, vars.numChannels);
else
    if(size(vars.options.subParams, 2) == vars.numChannels)
        vars.detectionParams = vars.options.subParams;
    else
        error('Invalid detection parameters provided. Number of columns in detection parameter matrix should be equal to number of EMG channels.');
    end
end

% Create figure
H = figure(...
    'Visible',              'off',...
    'Units',                'pixels',...
    'ResizeFcn',            @handleResize,...
    'CloseRequestFcn',      @closeFigure,...
    'Name',                 'emgEventsDetectTool',...
    'numbertitle',          'off');

% Zoom handler
hZ = zoom(H);
set(hZ, 'ActionPostCallback', @handleZoom);

% Create space for controls
vars.enlargeFactor = 100;
hPos = get(H, 'Position');
hPos(4) = hPos(4) + vars.enlargeFactor;
set(H, 'Position', hPos);

% View setup
heightRatio = 0.8;
widthRatio = 0.7;
set(0,'units','characters');

displayResolution = get(0,'screensize');

width = displayResolution(3) * widthRatio;
height = displayResolution(4) * heightRatio;
x_x = (displayResolution(3) - width) / 2;
y = (displayResolution(4) - height) / 2;
set(H,'units','characters');
windowPosition = [x_x y width height];
set(H, 'pos', windowPosition);

% Create push buttons
vars.btnNext = uicontrol('Style', 'pushbutton', 'String', 'Next',...
    'TooltipString', 'Next parameter',...
    'Position', [400 60 75 20],...
    'Callback', @nextParam);

vars.btnPrevious = uicontrol('Style', 'pushbutton', 'String', 'Previous',...
    'TooltipString', 'Previous parameter',...
    'Position', [300 60 75 20],...
    'Callback', @previousParam);

% Create channel push buttons
vars.btnNextChannel = uicontrol('Style', 'pushbutton', 'String', '>>',...
    'TooltipString', 'Next channel',...
    'Position', [500 60 25 20],...
    'Callback', @nextChannel);

vars.btnPreviousChannel = uicontrol('Style', 'pushbutton', 'String', '<<',...
    'TooltipString', 'Previous channel',...
    'Position', [250 60 25 20],...
    'Callback', @previousChannel);

% Create value push buttons
vars.btnIncrease = uicontrol('Style', 'pushbutton', 'String', '+',...
    'TooltipString', 'Increase parameter value',...
    'Position', [675 60 25 20],...
    'Callback', @increaseValue);

vars.btnDecrease = uicontrol('Style', 'pushbutton', 'String', '-',...
    'TooltipString', 'Decrease parameter value',...
    'Position', [550 60 25 20],...
    'Callback', @decreaseValue);

vars.editValue = uicontrol('style','edit',...
    'TooltipString', 'Edit value of parameter',...
    'units','pixels',...
    'position',[600 60 50 20],...
    'string','',...
    'callback',@validateValue);

vars.btnAuto = uicontrol('Style', 'pushbutton', 'String', 'Auto Find',...
    'Position', [725 60 75 20],...
    'TooltipString', 'Auto find onsets/offsets using nOptim',...
    'Callback', @autoFind);

vars.btnAutoTune = uicontrol('Style', 'pushbutton', 'String', 'Auto Tune',...
    'TooltipString', 'Tune parameters from labelled onsets/offsets',...
    'Position', [725 20 75 20],...
    'Callback', @autoTune,...
    'Enable', 'On');

vars.btnManual = uicontrol('Style', 'pushbutton', 'String', 'Manual Adjust',...
    'Position', [600 20 100 20],...
    'TooltipString', 'Manually adjust onsets/offsets',...
    'Callback', @manualAdjust);

vars.ckbShowFinal = uicontrol('Style','checkbox',...
    'String','Show final results',...
    'Value', vars.options.showFinalResult,...
    'TooltipString', 'Toggle step wise vs final results',...
    'Position',[250 20 150 20],...
    'Callback', @toggleShowFinal);

vars.btnLockParams = uicontrol('Style','pushbutton',...
    'String','Apply to all channels',...
    'TooltipString', 'Apply parameters to all channels',...
    'Position',[400 20 175 20],...
    'Callback', @applyParamsToAll,...
    'Enable', vars.ON_OFF_CELL{(vars.numChannels > 1) + 1});


% Add a text uicontrol.
vars.txtInfo = uicontrol('Style','text',...
    'Position',[75 40 150 60],...
    'HorizontalAlignment', 'Left');

% First detection update
runDetector(1);

% First view update
updateView;

% Make figure visble after adding all components
set(H, 'Visible','on');
uiwait(H);

% Callback functions
    function nextParam(~,~)
        vars.paramNum = vars.paramNum + 1;
        updateView(1);
    end

    function previousParam(~,~)
        vars.paramNum = vars.paramNum - 1;
        updateView(1);
    end

    function nextChannel(~,~)
        vars.channelNum = vars.channelNum + 1;
        updateView;
    end

    function previousChannel(~,~)
        vars.channelNum = vars.channelNum - 1;
        updateView;
    end

    function increaseValue(~, ~)
        currentVal = vars.detectionParams(vars.paramNum, vars.channelNum);
        incrementSize = vars.options.paramIncrement(vars.paramNum);
        currentVal = currentVal + incrementSize;
        set(vars.editValue, 'String', num2str(currentVal, 4));
        validateValue([], []);
    end
    function decreaseValue(~, ~)
        currentVal = vars.detectionParams(vars.paramNum, vars.channelNum);
        incrementSize = vars.options.paramIncrement(vars.paramNum);
        currentVal = currentVal - incrementSize;
        set(vars.editValue, 'String', num2str(currentVal, 4));
        validateValue([], []);
    end
    function validateValue(~, ~)
        currentVal = str2double(get(vars.editValue, 'String'));
        lowerBound = vars.options.paramLowerBounds(vars.paramNum);
        upperBound = vars.options.paramUpperBounds(vars.paramNum);
        isInt = vars.options.paramIsInt(vars.paramNum);
        if(currentVal > upperBound)
            currentVal = upperBound;
        elseif(currentVal < lowerBound)
            currentVal = lowerBound;
        end
        if(isInt)
            currentVal = round(currentVal);
        end
        set(vars.editValue, 'String', num2str(currentVal, 4));
        vars.detectionParams(vars.paramNum, vars.channelNum) = currentVal;
        runDetector
        updateView(1);
    end

    function autoFind(~, ~)
        dlgOpts.Interpreter='tex';
        x = inputdlg({'No. of onset/offset pairs to find:', 'Randomise parameters [Y:1, N:0]'},...
            'nOptim', [1 50], {'50', '1'}, dlgOpts);
        if(isempty(x))
            return;
        end
        answer = x;
        numActivations = round(str2double(answer{1}));
        isRandomParams = str2double(answer{2});
        paramsVector = autoFindActivations(vars.channelStream(:, vars.channelNum), vars.fs,...
            isRandomParams, vars.detectionParams(:, vars.channelNum),...
            vars.options.paramLowerBounds, vars.options.paramUpperBounds,...
            numActivations, vars.options.detectionAlgo);
        vars.detectionParams(:, vars.channelNum) = vars.options.paramPrimer(paramsVector);
        runDetector
        updateView(1);
    end

    function autoTune(~, ~)
        paramsVector = tuneDetectionParams(vars.channelStream(:, vars.channelNum), vars.fs,...
            vars.detectionParams(:, vars.channelNum),...
            vars.options.paramLowerBounds, vars.options.paramUpperBounds,...
            vars.detectionCellarray{vars.channelNum}{end, vars.ONSETS_COLUMN_NUM}, vars.detectionCellarray{vars.channelNum}{end, vars.OFFSETS_COLUMN_NUM},...
            vars.options.detectionAlgo);
        vars.detectionParams(:, vars.channelNum) = vars.options.paramPrimer(paramsVector);
        runDetector
        updateView(1);
    end

    function toggleShowFinal(hObject, ~)
        value = get(hObject,'Value');
        vars.options.showFinalResult = value;
        updateView(1);
    end

    function handleResize(~,~)
        updateView
    end

    function applyParamsToAll(~,~)
        vars.detectionParams = repmat(vars.detectionParams(:, vars.channelNum), 1, vars.numChannels);
        runDetector(1);
    end

    function handleZoom(h, ~)
        hz = zoom(h);
        if(strcmp(hz.Direction, 'out'))
            updateView;
        end
    end

    function manualAdjust(~, ~)
        tempEMG = vars.EMG;
        if(isfield(tempEMG, 'channelNames'))
            tempEMG.channelNames = {tempEMG.channelNames{vars.channelNum}};
        end
        tempEMG.channelData = tempEMG.channelData(:, vars.channelNum);
        tempEMG.events.onSets  = vars.detectionCellarray{vars.channelNum}{end, vars.ONSETS_COLUMN_NUM};
        tempEMG.events.offSets = vars.detectionCellarray{vars.channelNum}{end, vars.OFFSETS_COLUMN_NUM};
        if(isempty(tempEMG.events.offSets))
            errordlg('No onsets and offsets to adjust', 'Manual Adjust Error', 'modal');
            return;
        end
        adjustedEMG = emgEventsManageTool(tempEMG, vars.options);
        vars.uOnSets      = setdiff(adjustedEMG.events.onSets, vars.detectionCellarray{vars.channelNum}{end, vars.ONSETS_COLUMN_NUM});
        vars.uOffSets    = setdiff(adjustedEMG.events.offSets, vars.detectionCellarray{vars.channelNum}{end, vars.OFFSETS_COLUMN_NUM});
        vars.detectionCellarray{vars.channelNum}{end, vars.ONSETS_COLUMN_NUM} = adjustedEMG.events.onSets;
        vars.detectionCellarray{vars.channelNum}{end, vars.OFFSETS_COLUMN_NUM} = adjustedEMG.events.offSets;
        updateView(1);
    end

    function updateView(retainZoom)
        if nargin < 1
            retainZoom = 0;
        end
        if(retainZoom)
            axisInfo = axis;
        end
        ax = subplot(1, 1, 1, 'Units', 'pixels');
        
        dat = vars.channelStream(:, vars.channelNum);
        
        absc = vars.abscissa;
        
        if(vars.options.showRectifiedEmg)
            plot(absc, abs(dat), 'LineWidth', vars.options.lineWidth);
        else
            plot(absc, abs(dat), 'LineWidth', vars.options.lineWidth);
        end
        
        % Reset zoom level
        if(retainZoom)
            axis(axisInfo);
        end
        
        pos = get(ax, 'Position');
        pos(2) = pos(2) + vars.enlargeFactor / 2;
        pos(4) = pos(4) - vars.enlargeFactor / 3;
        set(ax, 'Position', pos);
        
        % Previous/Next button enable/disable
        if vars.paramNum == vars.options.totalParams
            set(vars.btnNext, 'Enable', 'Off');
        else
            set(vars.btnNext, 'Enable', 'On');
        end
        if vars.paramNum == 1
            set(vars.btnPrevious, 'Enable', 'Off');
        else
            set(vars.btnPrevious, 'Enable', 'On');
        end
        
        % Enable disable channel buttons
        if vars.channelNum == vars.numChannels
            set(vars.btnNextChannel, 'Enable', 'Off');
        else
            set(vars.btnNextChannel, 'Enable', 'On');
        end
        
        if vars.channelNum == 1
            set(vars.btnPreviousChannel, 'Enable', 'Off');
        else
            set(vars.btnPreviousChannel, 'Enable', 'On');
        end
        
        if vars.options.showFinalResult
            paramForPlot = vars.options.totalParams;
        else
            paramForPlot = vars.paramNum;
        end
        
        set(vars.txtInfo, 'String', sprintf('Channel No: %d/%d\nParam: %s\nNo. of events: %d', vars.channelNum,...
            vars.numChannels, vars.options.paramNames{vars.paramNum},...
            length(vars.detectionCellarray{vars.channelNum}{paramForPlot, vars.ONSETS_COLUMN_NUM})));
        if(isfield(vars.EMG, 'description'))
            title(vars.EMG.description);
        end
        
        ylabel(vars.options.yLabel);
        xlabel(vars.options.xLabel);
        
        % Set edit value
        currentVal = vars.detectionParams(vars.paramNum, vars.channelNum);
        set(vars.editValue, 'String', num2str(currentVal, 4));
        
        
        % Plot events if present
        hold on
        stem(absc(vars.detectionCellarray{vars.channelNum}{paramForPlot, vars.ONSETS_COLUMN_NUM}),...
            ones(size(absc(vars.detectionCellarray{vars.channelNum}{paramForPlot, vars.ONSETS_COLUMN_NUM})))...
            .*vars.eventAmplitude(vars.channelNum),...
            '-k', 'LineWidth', vars.options.eventLineWidth,...
            'LineStyle', '--', 'Marker', '*',...
            'MarkerSize', vars.options.eventMarkerSize);
        stem(absc(vars.detectionCellarray{vars.channelNum}{paramForPlot, vars.OFFSETS_COLUMN_NUM}),...
            ones(size(absc(vars.detectionCellarray{vars.channelNum}{paramForPlot, vars.OFFSETS_COLUMN_NUM})))...
            .*vars.eventAmplitude(vars.channelNum),...
            '-r', 'LineWidth', vars.options.eventLineWidth,...
            'LineStyle', '--', 'Marker', '*',...
            'MarkerSize', vars.options.eventMarkerSize);
        hold off;
    end
    function runDetector(runForAll)
        if nargin < 1
            runForAll = 0;
        end
        if runForAll == 1
            for i = 1:vars.numChannels
                vars.detectionCellarray{i} = vars.options.detectionAlgoSteps(vars.channelStream(:, i),...
                    vars.fs, vars.detectionParams(:, i));
            end
        else
            vars.detectionCellarray{vars.channelNum} = vars.options.detectionAlgoSteps(vars.channelStream(:, vars.channelNum),...
                vars.fs, vars.detectionParams(:, vars.channelNum));
        end
    end
    function closeFigure(~,~)
        returnEMG = vars.EMG;
        for i=1:vars.numChannels
            returnEMG.events(i).onSets  = vars.detectionCellarray{i}{end, vars.ONSETS_COLUMN_NUM};
            returnEMG.events(i).offSets = vars.detectionCellarray{i}{end, vars.OFFSETS_COLUMN_NUM};
        end
        returnParams = vars.detectionParams;
        delete(gcf);
    end
end