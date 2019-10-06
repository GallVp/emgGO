% Modiefied from goplotpso.m by <Usman Rashid, 5-Oct-2019>

% goplotpso.m
% default plotting script used in PSO functions
%
% this script is not a function,
% it is a plugin for the main PSO routine (pso_Trelea_vectorized)
% so it shares all the same variables, be careful with variable names
% when making your own plugin

% Brian Birge
% Rev 2.0
% 3/1/06

% setup figure, change this for your own machine

global haltingState;

if ~exist('hMsg', 'var') && i == 1
    hMsg = infoDialog('Starting optimisation...');
    drawnow;
    haltingState = 0;
end

if haltingState ~=1
    set(hMsg.Children(2), 'String', sprintf('Running particleswarm\nIter no. %d\nCost: %0.3f', i, gbestval));
    drawnow;
else
    delete(hMsg);
end

function d = infoDialog(msg)

d = dialog('Position', [300 300 250 150],...
    'Name','Optimisation Status',...
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

function haltOperation(src, ~)
global haltingState;
haltingState = 1;
delete(src.Parent);
end

function haltAndCloseOperation(src, ~)
global haltingState;
haltingState = 1;
delete(src);
end