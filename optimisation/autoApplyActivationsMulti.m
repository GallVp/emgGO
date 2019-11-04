function activationMatrix =  autoApplyActivationsMulti(multiChannel, fs, activationKernel, randomInit, initialTau,...
    lowerBound, upperBound)
%autoApplyActivations Minimises baseline energy for a given
%   activationKernel on multi-channel of emg data.
%
%
%   Copyright (c) <2019> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.


if nargin < 4
    randomInit      = 1;
    initialTau      = 0;
    lowerBound      = -1;   % In seconds
    upperBound      = 1;    % In seconds
elseif nargin < 5
    initialTau      = 0;
    lowerBound      = -1;   % In seconds
    upperBound      = 1;    % In seconds
elseif nargin < 6
    lowerBound      = -1;   % In seconds
    upperBound      = 1;    % In seconds
elseif nargin < 7
    upperBound      = 1;    % In seconds
end


haltingState        = 0;

activationMatrix    = NaN.*ones(size(activationKernel, 1), size(activationKernel, 2), size(multiChannel, 2));


% Run particle swarm optimiser, first pass
hMsg = infoDialog('Applying activations to all channels...');
drawnow;

for i=1:size(multiChannel, 2)
    set(hMsg.Children(2), 'String', sprintf('Working on channel: %d', i));
    drawnow;
    if haltingState == 1
        break;
    end
    tau =  autoApplyActivations(multiChannel(:, i), fs, activationKernel, randomInit, initialTau,...
        lowerBound, upperBound);
    
    onsets                      = activationKernel(:, 1)+tau;
    offsets                     = activationKernel(:, 2)+tau;
    onsets(onsets<=1)           = 1;
    offsets(offsets<=1)         = 1;
    lChannel                    = length(multiChannel(:, i));
    onsets(onsets>=lChannel)    = lChannel;
    offsets(offsets>=lChannel)  = lChannel;
    activationMatrix(:, :, i)   = [onsets offsets];
end


%% Status Dialog Box
    function d = infoDialog(msg)
        
        d = dialog('Position', [300 300 250 150],...
            'Name','Apply to all channels',...
            'WindowStyle', 'modal',...
            'CloseRequestFcn', @haltAndCloseOperation);
        
        txtInfo = uicontrol('Parent',d,...
            'Style','text',...
            'Position',[20 80 210 40],...
            'String', msg);
        
        btnCtrl = uicontrol('Parent',d,...
            'Position',[85 20 70 25],...
            'String','Halt!',...
            'Callback', @haltOperation);
    end

    function haltOperation(~, ~)
        haltingState = 1;
    end

    function haltAndCloseOperation(src, ~)
        haltingState = 1;
        delete(src);
    end

if ~isempty(hMsg)
    delete(hMsg);
end
end