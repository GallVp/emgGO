function [returnEMG] = emgEventsManageTool(EMG, options)
% emgEventsManageTool
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
%
%   Outputs:
%       1. EMG: The same input structure with following additional fileds
%       a. channelData: A matrix with channel wise emg data.
%       b. events.onSets: A matrix with channel wise onset indices
%       c. events.offSets: A matrix with channel wise offset indices
%
%
%   Copyright (c) <2019> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.

% Constants
vars.EVENT_TYPE_OFFSET = 'EVENT_TYPE_OFFSET';
vars.EVENT_TYPE_ONSET = 'EVENT_TYPE_ONSET';

% Assign default options
vars.options.xLabel               = {'Time (s)'};
vars.options.yLabel               = 'Amplitude';
vars.options.lineWidth            = 0.5;
vars.options.dispWin              = [1 2];
vars.options.highlightMoveSpeed   = 1;
vars.options.eventLineWidth       = 2;
vars.options.yAxisZoom            = 1;
vars.options.xAxisZoom            = 1;
vars.options.showRectifiedEmg     = 1;
vars.options.scanOnsetsOffsets    = 0;      % 0 for onsets and 1 for offsets.

if nargin < 2
    options = [];
end

vars.options  = assignOptions(options, vars.options);
vars.EMG      = EMG;

if(~isfield(vars.EMG, 'events'))
    returnEMG = [];
    disp('Function can only be used with events');
    return;
end

% Data
vars.emgData      = vars.EMG.channelData;

vars.numChannels  = size(vars.EMG.channelData, 2);
vars.numSamples   = size(vars.EMG.channelData, 1);
% Calculate abscissa from fs
vars.abscissa     = (1:vars.numSamples) ./ EMG.fs;
vars.fs           = EMG.fs;
if(isfield(EMG, 'cueVector'))
    vars.cueVector= EMG.cueVector;
else
    vars.cueVector= [];
end



% Startup settings
vars.channelNum           = 1;
vars.eventMarkerY         = (max(vars.emgData) - min(vars.emgData)) / 4;
vars.events               = vars.EMG.events;
vars.onsetNum             = 1;
vars.offsetNum            = 1;
vars.highlightPoint       = [];
vars.hHighlight           = [];
vars.selectedEvent        = [];
vars.numOnsets            = length(vars.events(vars.channelNum).onSets);
vars.numOffsets           = length(vars.events(vars.channelNum).offSets);

% Creat a figure and set it up properly.
H = figure(...
    'Visible',          'off',...
    'Units',            'pixels',...
    'ResizeFcn',        @handleResize,...
    'CloseRequestFcn',  @closeFigure,...
    'Name',             'emgEventsManageTool',...
    'numbertitle',      'off',...
    'KeyPressFcn',      @keyPressHandler);

hZ = zoom(H);
set(hZ, 'ActionPostCallback', @handleZoom);
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
    'TooltipString', 'Next event',...
    'Position', [300 60 75 20],...
    'Callback', @next);

vars.btnPrevious = uicontrol('Style', 'pushbutton', 'String', 'Previous',...
    'TooltipString', 'Previous parameter',...
    'Position', [200 60 75 20],...
    'Callback', @previous);

% Create channel push buttons
vars.btnNextChannel = uicontrol('Style', 'pushbutton', 'String', '>>',...
    'TooltipString', 'Next channel',...
    'Position', [450 60 25 20],...
    'Callback', @nextChannel);

vars.btnPreviousChannel = uicontrol('Style', 'pushbutton', 'String', '<<',...
    'TooltipString', 'Previous channel',...
    'Position', [400 60 25 20],...
    'Callback', @previousChannel);

vars.btnReset = uicontrol('Style', 'pushbutton', 'String', 'Reset',...
    'TooltipString', 'Reset events',...
    'Position', [500 60 75 20],...
    'Callback', @reset);

vars.btnDelete = uicontrol('Style', 'pushbutton', 'String', 'Delete',...
    'TooltipString', 'Delete events',...
    'Position', [200 20 75 20],...
    'Callback', @delEvent);

vars.btnInsertOn = uicontrol('Style', 'pushbutton', 'String', 'Ins Onset',...
    'TooltipString', 'Insert onset',...
    'Position', [300 20 75 20],...
    'Callback', @instOnEvent);

vars.btnInsertOff = uicontrol('Style', 'pushbutton', 'String', 'Ins Offset',...
    'TooltipString', 'Insert offset',...
    'Position', [400 20 75 20],...
    'Callback', @instOffEvent);

vars.btnMoveEvent = uicontrol('Style', 'pushbutton', 'String', 'Move',...
    'TooltipString', 'Move event',...
    'Position', [500 20 75 20],...
    'Callback', @moveEvent);

vars.btnChannelView = uicontrol('Style', 'pushbutton', 'String', 'Channel View',...
    'TooltipString', 'Open channel viewer',...
    'Position', [600 60 75 20],...
    'Callback', @channelView);

vars.btnScanOnsetsOffsets = uicontrol('Style', 'pushbutton', 'String', 'Scan Offsets',...
    'TooltipString', 'Toggle event scan',...
    'Position', [600 20 75 20],...
    'Callback', @scanOnsetsOffsets);


% Add a text uicontrol.
vars.txtInfo = uicontrol('Style','text',...
    'Position',[75 30 120 50],...
    'HorizontalAlignment', 'left');

updateView

% Make figure visble after adding all components
set(H, 'Visible','on');
uiwait(H);

% Handle callbacks
    function next(hObject,~)
        % To put focus back to main GUI
        set(hObject, 'enable', 'off');
        drawnow;
        set(hObject, 'enable', 'on');
        
        if(vars.options.scanOnsetsOffsets)
            vars.offsetNum = vars.offsetNum + 1;
        else
            vars.onsetNum = vars.onsetNum + 1;
        end
        vars.highlightPoint = [];
        vars.selectedEvent = [];
        eventScroll;
    end

    function previous(hObject,~)
        % To put focus back to main GUI
        set(hObject, 'enable', 'off');
        drawnow;
        set(hObject, 'enable', 'on');
        
        if(vars.options.scanOnsetsOffsets)
            vars.offsetNum = vars.offsetNum - 1;
        else
            vars.onsetNum = vars.onsetNum - 1;
        end
        vars.highlightPoint = [];
        vars.selectedEvent = [];
        eventScroll;
    end

    function nextChannel(hObject,~)
        % To put focus back to main GUI
        set(hObject, 'enable', 'off');
        drawnow;
        set(hObject, 'enable', 'on');
        
        vars.channelNum = vars.channelNum + 1;
        vars.highlightPoint = [];
        vars.selectedEvent = [];
        vars.numOnsets = length(vars.events(vars.channelNum).onSets);
        if(vars.onsetNum > vars.numOnsets)
            vars.onsetNum = 1;
        end
        vars.numOffsets = length(vars.events(vars.channelNum).offSets);
        if(vars.offsetNum > vars.numOffsets)
            vars.offsetNum = 1;
        end
        updateView
    end

    function previousChannel(hObject,~)
        % To put focus back to main GUI
        set(hObject, 'enable', 'off');
        drawnow;
        set(hObject, 'enable', 'on');
        
        vars.channelNum = vars.channelNum - 1;
        vars.highlightPoint = [];
        vars.selectedEvent = [];
        vars.numOnsets = length(vars.events(vars.channelNum).onSets);
        if(vars.onsetNum > vars.numOnsets)
            vars.onsetNum = 1;
        end
        vars.numOffsets = length(vars.events(vars.channelNum).offSets);
        if(vars.offsetNum > vars.numOffsets)
            vars.offsetNum = 1;
        end
        updateView
    end

    function reset(hObject,~)
        % To put focus back to main GUI
        set(hObject, 'enable', 'off');
        drawnow;
        set(hObject, 'enable', 'on');
        
        vars.events(vars.channelNum).onSets = vars.EMG.events(vars.channelNum).onSets;
        vars.events(vars.channelNum).offSets = vars.EMG.events(vars.channelNum).offSets;
        vars.onsetNum = 1;
        vars.offsetNum = 1;
        vars.highlightPoint = [];
        vars.selectedEvent = [];
        vars.numOnsets = length(vars.events(vars.channelNum).onSets);
        vars.numOffsets = length(vars.events(vars.channelNum).offSets);
        updateView
    end


    function handleResize(~,~)
        updateView
    end

    function handleZoom(h, ~)
        hz = zoom(h);
        if(strcmp(hz.Direction, 'out'))
            updateView;
        end
    end

    function highlightEvent(~,callbackdata)
        vars.highlightPoint = callbackdata.IntersectionPoint;
        vars.highlightPoint(2) = vars.eventMarkerY(vars.channelNum);
        
        % Check to see if the highlighter is on an event. if yes, save it.
        indOnset = find(round(vars.highlightPoint(1) * vars.fs) == vars.events(vars.channelNum).onSets);
        indOffset = find(round(vars.highlightPoint(1) * vars.fs) ==  vars.events(vars.channelNum).offSets);
        if(~isempty(indOnset))
            vars.selectedEvent.location = vars.events(vars.channelNum).onSets(indOnset);
            vars.selectedEvent.type = vars.EVENT_TYPE_ONSET;
        elseif(~isempty(indOffset))
            vars.selectedEvent.location = vars.events(vars.channelNum).offSets(indOffset);
            vars.selectedEvent.type = vars.EVENT_TYPE_OFFSET;
        else
            vars.selectedEvent = [];
        end
        updateView(1);
    end

    function delEvent(hObject, ~)
        % To put focus back to main GUI
        set(hObject, 'enable', 'off');
        drawnow;
        set(hObject, 'enable', 'on');
        
        if(~isempty(vars.highlightPoint) && strcmp(vars.selectedEvent.type, vars.EVENT_TYPE_ONSET))
            vars.events(vars.channelNum).onSets(vars.selectedEvent.location...
                == vars.events(vars.channelNum).onSets) = [];
            
            vars.numOnsets = length(vars.events(vars.channelNum).onSets);
            if(vars.onsetNum > vars.numOnsets)
                vars.onsetNum = vars.numOnsets;
            end
            vars.highlightPoint = [];
            vars.selectedEvent = [];
            updateView;
        elseif(~isempty(vars.highlightPoint) && strcmp(vars.selectedEvent.type, vars.EVENT_TYPE_OFFSET))
            
            vars.events(vars.channelNum).offSets(vars.selectedEvent.location...
                == vars.events(vars.channelNum).offSets) = [];
            vars.numOffsets = length(vars.events(vars.channelNum).offSets);
            if(vars.offsetNum > vars.numOffsets)
                vars.offsetNum = vars.numOffsets;
            end
            vars.highlightPoint = [];
            vars.selectedEvent = [];
            updateView;
        end
    end

    function moveEvent(hObject, ~)
        % To put focus back to main GUI
        set(hObject, 'enable', 'off');
        drawnow;
        set(hObject, 'enable', 'on');
        
        if(~isempty(vars.highlightPoint) && strcmp(vars.selectedEvent.type, vars.EVENT_TYPE_ONSET))
            vars.events(vars.channelNum).onSets(vars.selectedEvent.location == vars.events(vars.channelNum).onSets) = [];
            vars.events(vars.channelNum).onSets = sort([vars.events(vars.channelNum).onSets;round(vars.highlightPoint(1) .* vars.fs)]);
            vars.numOnsets = length(vars.events(vars.channelNum).onSets);
            vars.highlightPoint = [];
            vars.selectedEvent = [];
            updateView;
        elseif(~isempty(vars.highlightPoint) && strcmp(vars.selectedEvent.type, vars.EVENT_TYPE_OFFSET))
            vars.events(vars.channelNum).offSets(vars.selectedEvent.location == vars.events(vars.channelNum).offSets) = [];
            vars.events(vars.channelNum).offSets = sort([vars.events(vars.channelNum).offSets;round(vars.highlightPoint(1) .* vars.fs)]);
            vars.numOffsets = length(vars.events(vars.channelNum).offSets);
            vars.highlightPoint = [];
            vars.selectedEvent = [];
            updateView;
        end
    end

    function axesWhiteSpaceClicked(~, ~)
        vars.highlightPoint = [];
        vars.selectedEvent = [];
        updateView(1);
    end

    function instOnEvent(hObject, ~)
        % To put focus back to main GUI
        set(hObject, 'enable', 'off');
        drawnow;
        set(hObject, 'enable', 'on');
        
        if(~isempty(vars.highlightPoint))
            vars.events(vars.channelNum).onSets = sort([vars.events(vars.channelNum).onSets;round(vars.highlightPoint(1) .* vars.fs)]);
            vars.numOnsets = length(vars.events(vars.channelNum).onSets);
            vars.highlightPoint = [];
            vars.selectedEvent = [];
            updateView;
        end
    end
    function instOffEvent(hObject, ~)
        % To put focus back to main GUI
        set(hObject, 'enable', 'off');
        drawnow;
        set(hObject, 'enable', 'on');
        
        if(~isempty(vars.highlightPoint))
            vars.events(vars.channelNum).offSets = sort([vars.events(vars.channelNum).offSets;round(vars.highlightPoint(1) .* vars.fs)]);
            vars.numOffsets = length(vars.events(vars.channelNum).offSets);
            vars.highlightPoint = [];
            vars.selectedEvent = [];
            updateView;
        end
    end

    function keyPressHandler(~, eventData)
        if ~isempty(eventData.Modifier)
            if(strcmp(eventData.Key, 'rightarrow') && strcmp(eventData.Modifier{1}, 'shift') && vars.channelNum < vars.numChannels)
                nextChannel([], []);
            end
            if(strcmp(eventData.Key, 'leftarrow') && strcmp(eventData.Modifier{1}, 'shift') && vars.channelNum > 1)
                previousChannel([], []);
            end
        else
            if(~isempty(vars.highlightPoint))
                axisLimits = axis;
                movSamples = round(vars.options.highlightMoveSpeed * abs(axisLimits(2) - axisLimits(1)));
                if(movSamples == 0)
                    movSamples = 1;
                end
                if(strcmp(eventData.Key, 'rightarrow'))
                    vars.highlightPoint(1) = vars.highlightPoint(1) + movSamples / vars.fs;
                    moveHighlighter;
                end
                if(strcmp(eventData.Key, 'leftarrow'))
                    vars.highlightPoint(1) = vars.highlightPoint(1) - movSamples / vars.fs;
                    moveHighlighter;
                end
                if(strcmp(eventData.Key, 'e') || strcmp(eventData.Key, 'E'))
                    vars.highlightPoint(1) = vars.highlightPoint(1) + (movSamples * 5) / vars.fs;
                    moveHighlighter;
                end
                if(strcmp(eventData.Key, 'q') || strcmp(eventData.Key, 'Q'))
                    vars.highlightPoint(1) = vars.highlightPoint(1) - (movSamples * 5) / vars.fs;
                    moveHighlighter;
                end
                if(strcmp(eventData.Key, 'uparrow'))
                    vars.eventMarkerY = vars.eventMarkerY / 1.25;
                    vars.options.yAxisZoom = vars.options.yAxisZoom / 1.25;
                    updateView;
                end
                if(strcmp(eventData.Key, 'downarrow'))
                    vars.eventMarkerY = vars.eventMarkerY * 1.25;
                    vars.options.yAxisZoom = vars.options.yAxisZoom * 1.25;
                    updateView;
                end
                if(strcmp(eventData.Key, 'slash'))
                    vars.options.xAxisZoom = vars.options.xAxisZoom / 1.25;
                    updateView;
                end
                if(strcmp(eventData.Key, 'period'))
                    vars.options.xAxisZoom = vars.options.xAxisZoom * 1.25;
                    updateView;
                end
                if(strcmp(eventData.Key, 'escape'))
                    axesWhiteSpaceClicked([], []);
                end
                if(strcmp(eventData.Key, 'space') && ~isempty(vars.selectedEvent))
                    moveEvent([], []);
                end
                if(strcmp(eventData.Key, 'd') || strcmp(eventData.Key, 'D') && ~isempty(vars.selectedEvent))
                    delEvent([], []);
                end
                if(strcmp(eventData.Key, 'i') || strcmp(eventData.Key, 'I'))
                    instOnEvent([], []);
                end
                if(strcmp(eventData.Key, 'o') || strcmp(eventData.Key, 'O'))
                    instOffEvent([], []);
                end
            else
                if(vars.options.scanOnsetsOffsets)
                    if(strcmp(eventData.Key, 'rightarrow') && vars.offsetNum < vars.numOffsets)
                        next([], []);
                    end
                    if(strcmp(eventData.Key, 'leftarrow') && vars.offsetNum > 1)
                        previous([], []);
                    end
                    if(strcmp(eventData.Key, 'space') && isempty(vars.selectedEvent))
                        callbackdata.IntersectionPoint = vars.events(vars.channelNum).offSets(vars.offsetNum) / vars.fs;
                        highlightEvent([], callbackdata);
                    end
                else
                    if(strcmp(eventData.Key, 'rightarrow') && vars.onsetNum < vars.numOnsets)
                        next([], []);
                    end
                    if(strcmp(eventData.Key, 'leftarrow') && vars.onsetNum > 1)
                        previous([], []);
                    end
                    if(strcmp(eventData.Key, 'space') && isempty(vars.selectedEvent))
                        callbackdata.IntersectionPoint = vars.events(vars.channelNum).onSets(vars.onsetNum) / vars.fs;
                        highlightEvent([], callbackdata);
                    end
                end
                if(strcmp(eventData.Key, 'uparrow'))
                    vars.eventMarkerY = vars.eventMarkerY / 1.25;
                    vars.options.yAxisZoom = vars.options.yAxisZoom / 1.25;
                    updateView;
                end
                if(strcmp(eventData.Key, 'downarrow'))
                    vars.eventMarkerY = vars.eventMarkerY * 1.25;
                    vars.options.yAxisZoom = vars.options.yAxisZoom * 1.25;
                    updateView;
                end
                if(strcmp(eventData.Key, 'slash'))
                    vars.options.xAxisZoom = vars.options.xAxisZoom / 1.25;
                    updateView;
                end
                if(strcmp(eventData.Key, 'period'))
                    vars.options.xAxisZoom = vars.options.xAxisZoom * 1.25;
                    updateView;
                end
            end
        end
    end

    function channelView(hObject, ~)
        % To put focus back to main GUI
        set(hObject, 'enable', 'off');
        drawnow;
        set(hObject, 'enable', 'on');
        
        tempEMG = vars.EMG;
        tempEMG.events = vars.events;
        plotEMG(tempEMG, vars.options);
    end

    function scanOnsetsOffsets(hObject, ~)
        % To put focus back to main GUI
        set(hObject, 'enable', 'off');
        drawnow;
        set(hObject, 'enable', 'on');
        
        if(vars.options.scanOnsetsOffsets)
            vars.options.scanOnsetsOffsets = 0;
            set(vars.btnScanOnsetsOffsets, 'String', 'Scan Offsets');
        else
            vars.options.scanOnsetsOffsets = 1;
            set(vars.btnScanOnsetsOffsets, 'String', 'Scan Onsets');
        end
        eventScroll;
    end

    function updateView(retainZoom)
        if nargin < 1
            retainZoom = 0;
        end
        if(retainZoom)
            axisInfo = axis;
        end
        
        ax = subplot(1, 1, 1, 'Units', 'pixels', 'buttonDownfcn', @axesWhiteSpaceClicked, 'NextPlot', 'add');
        if(vars.options.showRectifiedEmg)
            plot(vars.abscissa, abs(vars.emgData(:, vars.channelNum)), 'buttonDownfcn', @highlightEvent, 'LineWidth', vars.options.lineWidth);
        else
            plot(vars.abscissa, vars.emgData(:, vars.channelNum), 'buttonDownfcn', @highlightEvent, 'LineWidth', vars.options.lineWidth);
        end
        hold on;
        if ~isempty(vars.events(vars.channelNum).onSets)
            stem(vars.events(vars.channelNum).onSets ./ vars.fs, ones(length(vars.events(vars.channelNum).onSets), 1) .* vars.eventMarkerY(vars.channelNum),...
                '-k', 'LineWidth', vars.options.eventLineWidth, 'LineStyle', '--', 'Marker', '*',...
                'MarkerSize', 10, 'buttonDownfcn', @highlightEvent);
            stem(vars.events(vars.channelNum).offSets ./ vars.fs, ones(length(vars.events(vars.channelNum).offSets), 1) .* vars.eventMarkerY(vars.channelNum),...
                '-r', 'LineWidth', vars.options.eventLineWidth, 'LineStyle', '--', 'Marker', '*',...
                'MarkerSize', 10, 'buttonDownfcn', @highlightEvent);
        end
        % Plot cue if present
        if(~isempty(vars.cueVector))
            plot(vars.options.cueVector ./ vars.fs,...
                ones(length(vars.options.cueVector), 1) .* vars.options.eventMarkerY,...
                'gx', 'LineWidth', vars.options.eventLineWidth);
        end
        if(~isempty(vars.highlightPoint))
            vars.hHighlight = stem(vars.highlightPoint(1),...
                vars.eventMarkerY(vars.channelNum), '-m', 'LineWidth', vars.options.lineWidth);
            set(vars.btnInsertOn, 'Enable', 'On');
            set(vars.btnInsertOff, 'Enable', 'On');
        else
            set(vars.btnInsertOn, 'Enable', 'Off');
            set(vars.btnInsertOff, 'Enable', 'Off');
        end
        
        % Is event movabale
        if(~isempty(vars.selectedEvent))
            set(vars.btnMoveEvent, 'Enable', 'On');
            set(vars.btnDelete, 'Enable', 'On');
        else
            set(vars.btnMoveEvent, 'Enable', 'Off');
            set(vars.btnDelete, 'Enable', 'Off');
        end
        % Reset zoom level
        if(retainZoom)
            axis(axisInfo);
        elseif ~isempty(vars.events(vars.channelNum).onSets)
            axh = axis;
            dispWin = vars.options.dispWin .* vars.options.xAxisZoom;
            if(vars.options.scanOnsetsOffsets)
                displayWin = [vars.events(vars.channelNum).offSets(vars.offsetNum) / vars.fs - dispWin(1)+1/vars.fs ...
                    vars.events(vars.channelNum).offSets(vars.offsetNum) / vars.fs + dispWin(2)];
            else
                displayWin = [vars.events(vars.channelNum).onSets(vars.onsetNum) / vars.fs - dispWin(1)+1/vars.fs ...
                    vars.events(vars.channelNum).onSets(vars.onsetNum) / vars.fs + dispWin(2)];
            end
            axis([displayWin(1) displayWin(2) axh(3)*vars.options.yAxisZoom axh(4)*vars.options.yAxisZoom]);
        end
        hold off;
        % Readjust axes position
        pos = get(ax, 'Position');
        pos(2) = pos(2) + vars.enlargeFactor / 2;
        pos(4) = pos(4) - vars.enlargeFactor / 3;
        set(ax, 'Position', pos);
        
        if vars.onsetNum == vars.numOnsets
            set(vars.btnNext, 'Enable', 'Off');
        else
            set(vars.btnNext, 'Enable', 'On');
        end
        if vars.onsetNum == 1
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
        
        if(vars.options.scanOnsetsOffsets)
            set(vars.txtInfo, 'String', sprintf('Offset: %d/%d\nOnsets: %d\nChannel: %d/%d', vars.offsetNum, vars.numOffsets,...
                vars.numOnsets, vars.channelNum, vars.numChannels));
        else
            set(vars.txtInfo, 'String', sprintf('Onset: %d/%d\nOffsets: %d\nChannel: %d/%d', vars.onsetNum, vars.numOnsets,...
                vars.numOffsets, vars.channelNum, vars.numChannels));
        end
        if(isfield(vars.EMG, 'description'))
            title(vars.EMG.description);
        end
        xlabel(vars.options.xLabel);
        ylabel(vars.options.yLabel);
    end
    function eventScroll
        axh = axis;
        dispWin = vars.options.dispWin .* vars.options.xAxisZoom;
        if(vars.options.scanOnsetsOffsets)
            displayWin = [vars.events(vars.channelNum).offSets(vars.offsetNum) / vars.fs - dispWin(1)+1/vars.fs ...
                vars.events(vars.channelNum).offSets(vars.offsetNum) / vars.fs + dispWin(2)];
            set(vars.txtInfo, 'String', sprintf('Offset: %d/%d\nOnsets: %d\nChannel: %d/%d', vars.offsetNum, vars.numOffsets,...
                vars.numOnsets, vars.channelNum, vars.numChannels));
        else
            displayWin = [vars.events(vars.channelNum).onSets(vars.onsetNum) / vars.fs - dispWin(1)+1/vars.fs ...
                vars.events(vars.channelNum).onSets(vars.onsetNum) / vars.fs + dispWin(2)];
            set(vars.txtInfo, 'String', sprintf('Onset: %d/%d\nOffsets: %d\nChannel: %d/%d', vars.onsetNum, vars.numOnsets,...
                vars.numOffsets, vars.channelNum, vars.numChannels));
        end
        axis([displayWin(1) displayWin(2) axh(3) axh(4)]);
        
        if vars.onsetNum == vars.numOnsets
            set(vars.btnNext, 'Enable', 'Off');
        else
            set(vars.btnNext, 'Enable', 'On');
        end
        if vars.onsetNum == 1
            set(vars.btnPrevious, 'Enable', 'Off');
        else
            set(vars.btnPrevious, 'Enable', 'On');
        end
    end
    function moveHighlighter
        if(~isempty(vars.hHighlight))
            delete(vars.hHighlight);
        end
        hold on;
        vars.hHighlight = stem(vars.highlightPoint(1),...
            vars.eventMarkerY(vars.channelNum), '-m', 'LineWidth', vars.options.lineWidth);
        hold off;
    end
    function closeFigure(~,~)
        returnEMG = vars.EMG;
        returnEMG.events = vars.events;
        delete(gcf);
    end
end