function H = plotEMG(EMG, options)
%PLOTEMG Creates a figure and axes showing EMG data structure.
%
%
%   Copyright (c) <2018> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.

% Available option constants
vars.DOMAIN_TIME      = 'TIME';
vars.DOMAIN_FREQUENCY = 'FREQUENCY';

% Assign default options
vars.options.xLabel           = {'Time (s)'};
vars.options.yLabel           = 'Amplitude';
vars.options.lineWidth        = 1;
vars.options.markerLineWidth  = 1;
vars.options.applyDetrend     = 0;
vars.options.showProcessed    = 1;
vars.options.showRectifiedEmg = 1;

switch(nargin)
    case 1
        vars.EMG      = EMG;
    case 2
        vars.EMG      = EMG;
        vars.options  = assignOptions(options, vars.options);
end

vars.numChannels  = size(vars.EMG.channelData, 2);
vars.numSamples   = size(vars.EMG.channelData, 1);
% Calculate abscissa from fs
vars.abscissa     = (1:vars.numSamples) ./ EMG.fs;

% Initial settings
vars.channelNum   = 1;
vars.domain       = vars.DOMAIN_TIME;
if(vars.options.showProcessed == 1 && isfield(vars.EMG, 'filteredChannelData'))
    vars.channelStream= vars.EMG.filteredChannelData;
else
    vars.channelStream= vars.EMG.channelData;
end
vars.fs           = vars.EMG.fs;
vars.eventAmplitude = (max(vars.channelStream) - min(vars.channelStream)) / 4;

% Create figure
H = figure(...
    'Visible',              'off',...
    'Units',                'pixels',...
    'ResizeFcn',            @handleResize,...
    'Name',                 'plotEMG',...
    'numbertitle',          'off');

% Create space for controls
vars.enlargeFactor = 50;
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
    'Position', [300 20 75 20],...
    'Callback', @next);

vars.btnPrevious = uicontrol('Style', 'pushbutton', 'String', 'Previous',...
    'Position', [200 20 75 20],...
    'Callback', @previous);

vars.btnSpectrum = uicontrol('Style', 'pushbutton', 'String', 'Spectrum',...
    'Position', [400 20 75 20],...
    'Callback', @spectrum);


% Add a text uicontrol.
vars.txtInfo = uicontrol('Style','text',...
    'Position',[75 17 120 20]);

% First view update
updateView

% Make figure visble after adding all components
set(H, 'Visible','on');

% Callback functions
    function next(~,~)
        vars.channelNum = vars.channelNum + 1;
        updateView
    end

    function previous(~,~)
        vars.channelNum = vars.channelNum - 1;
        updateView
    end

    function spectrum(~,~)
        if(strcmp(vars.domain, vars.DOMAIN_TIME))
            vars.domain = vars.DOMAIN_FREQUENCY;
            set(vars.btnSpectrum, 'String', 'Signal');
        else
            vars.domain = vars.DOMAIN_TIME;
            set(vars.btnSpectrum, 'String', 'Spectrum');
        end
        updateView
    end

    function handleResize(~,~)
        updateView
    end

    function updateView
        ax = subplot(1, 1, 1, 'Units', 'pixels');
        if(strcmp(vars.domain, vars.DOMAIN_TIME))
            if(vars.options.applyDetrend)
                dat = detrend(vars.channelStream(:, vars.channelNum));
            else
                dat = vars.channelStream(:, vars.channelNum);
            end
            absc = vars.abscissa;
            if(vars.options.showRectifiedEmg)
                dat = abs(dat);
            end
        else
            if(vars.options.applyDetrend)
                [dat, absc] = computePSD(detrend(vars.channelStream(:, vars.channelNum)), vars.fs, 1);
            else
                [dat, absc] = computePSD(vars.channelStream(:, vars.channelNum), vars.fs, 1);
            end
        end
        
        p1 = plot(absc, dat, 'LineWidth', vars.options.lineWidth);
        pos = get(ax, 'Position');
        pos(2) = pos(2) + vars.enlargeFactor / 2;
        pos(4) = pos(4) - vars.enlargeFactor / 3;
        set(ax, 'Position', pos);
        
        % Previous/Next button enable/disable
        if vars.channelNum == vars.numChannels
            set(vars.btnNext, 'Enable', 'Off');
        else
            set(vars.btnNext, 'Enable', 'On');
        end
        if vars.channelNum == 1
            set(vars.btnPrevious, 'Enable', 'Off');
        else
            set(vars.btnPrevious, 'Enable', 'On');
        end
        
        set(vars.txtInfo, 'String', sprintf('Channel No: %d/%d', vars.channelNum, vars.numChannels));
        if(isfield(vars.EMG, 'description'))
            title(vars.EMG.description);
        end
        
        ylabel(vars.options.yLabel);
        if(~strcmp(vars.domain, vars.DOMAIN_TIME))
            xlabel('Frequency (Hz)');
            ylabel('Power (dB)');
        else
            xlabel(vars.options.xLabel)
            ylabel(vars.options.yLabel);
        end
        
        % Create a legend entry
        if(isfield(vars.EMG, 'channelNames'))
            legendCell{1} = vars.EMG.channelNames{vars.channelNum};
            legendPlots(1) = p1;
        else
            legendCell = [];
            legendPlots = [];
        end
        
        % Plot cue events if present
        if(isfield(vars.EMG, 'events') && strcmp(vars.domain, vars.DOMAIN_TIME))
            if(~isempty(vars.EMG.events) && ~isempty(vars.EMG.events(vars.channelNum).onSets))
                hold on
                pOnSets = stem(absc(vars.EMG.events(vars.channelNum).onSets),...
                    vars.eventAmplitude(vars.channelNum)...
                    .* ones(size(absc(vars.EMG.events(vars.channelNum).onSets))),...
                    '-k', 'LineWidth', vars.options.eventLineWidth,...
                    'LineStyle', '--', 'Marker', '*',...
                    'MarkerSize', vars.options.eventMarkerSize);
                pOffSets = stem(absc(vars.EMG.events(vars.channelNum).offSets),...
                    vars.eventAmplitude(vars.channelNum)...
                    .* ones(size(absc(vars.EMG.events(vars.channelNum).offSets))),...
                    '-r', 'LineWidth', vars.options.eventLineWidth,...
                    'LineStyle', '--', 'Marker', '*',...
                    'MarkerSize', vars.options.eventMarkerSize);
                hold off;
                legendCell{end+1} = 'Onsets';
                legendPlots(end+1)  = pOnSets(1);
                legendCell{end+1} = 'Offsets';
                legendPlots(end+1)  = pOffSets(1);
            end
        end
        if(~isempty(legendCell))
            legend(legendPlots, legendCell);
        end
    end
end