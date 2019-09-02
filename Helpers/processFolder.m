function processFolder(inputFolder, outputFolder, processPipe, viewPipe, editPipe)
%processFolder Opens inputFolder and dsiplays a list of files in that
%   folder that can be processed with attached processPipe. Also shows a
%   list of processed files from the outputFolder that can be viewed
%   using viewPipe.
%
%
%   Copyright (c) <2019> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.

% Input constants
if nargin < 4
    viewPipe    = [];
    editPipe    = [];
elseif nargin < 5
    editPipe    = [];
end

% EXCLUDED FILES
EXCLUDED_FILES = {'.DS_Store'};

D = dialog(...
    'Units',            'pixels',...
    'Name',             func2str(processPipe),...
    'WindowStyle',      'normal');


% View setup
heightRatio = 0.6;
widthRatio = 0.5;
set(0,'units','characters');

displayResolution = get(0,'screensize');

width = displayResolution(3) * widthRatio;
height = displayResolution(4) * heightRatio;
x_x = (displayResolution(3) - width) / 2;
y = (displayResolution(4) - height) / 2;
set(D,'units','characters');
windowPosition = [x_x y width height];
set(D, 'pos', windowPosition);
set(D,'units','pixels');

% Calculate spacings
windowPosition = get(D, 'pos');
winWidth = windowPosition(3);
winHeight = windowPosition(4);
horizontalSpacing = winWidth / 10;
verticleSpacing = winHeight / 10;

% Calculate sizes
lstWidth = winWidth / 3;
lstHeight = winHeight / 1.5;
lstY = verticleSpacing * 2;

txtWidth = winWidth / 6;
txtHeight = winHeight / 25;

pbX = horizontalSpacing + lstWidth/2 - txtWidth/2;


% Initial values
vars.inputFolder        = inputFolder;
vars.outputFolder       = outputFolder;
vars.processPipe        = processPipe;
vars.viewPipe           = viewPipe;
vars.editPipe           = editPipe;
vars.selectedFileNum    = 1;


% Add controls
vars.lstInputList = uicontrol('Parent', D,...
    'Style','listbox',...
    'Position', [horizontalSpacing lstY lstWidth lstHeight]);

vars.lstOutputList = uicontrol('Parent', D,...
    'Style','listbox',...
    'Position', [winWidth - horizontalSpacing - lstWidth lstY lstWidth lstHeight]);


vars.txtInput = uicontrol('Parent',D,...
    'Style','text',...
    'Position',[horizontalSpacing lstY + lstHeight txtWidth txtHeight],...
    'String', 'Input files:',...
    'HorizontalAlignment', 'left',...
    'FontSize', 12);

vars.txtOutput = uicontrol('Parent',D,...
    'Style','text',...
    'Position',[winWidth - horizontalSpacing - lstWidth lstY + lstHeight txtWidth txtHeight],...
    'String', 'Processed files:',...
    'HorizontalAlignment', 'left',...
    'FontSize', 12);

vars.pbProcessPipe = uicontrol('Parent',D,...
    'Style','pushbutton',...
    'Position', [pbX verticleSpacing txtWidth txtHeight],...
    'String', 'Process',...
    'Callback', @procFunc);

vars.pbViewPipe = uicontrol('Parent',D,...
    'Style','pushbutton',...
    'Position', [winWidth - lstWidth - horizontalSpacing verticleSpacing txtWidth/2 txtHeight],...
    'String', 'View',...
    'Callback', @viewFunc);

vars.pbDelete = uicontrol('Parent',D,...
    'Style','pushbutton',...
    'Position', [winWidth - lstWidth + horizontalSpacing/4 verticleSpacing txtWidth/2 txtHeight],...
    'String', 'Delete',...
    'Callback', @delFunc);

vars.pbEditPipe = uicontrol('Parent',D,...
    'Style','pushbutton',...
    'Position', [winWidth - lstWidth + 1.5*horizontalSpacing verticleSpacing txtWidth/2 txtHeight],...
    'String', 'Edit',...
    'Callback', @editFunc);

updateLists;


    function updateLists
        [ouputFolderFiles, ~, outputFolderFilesWithExt] = processDataFolder(vars.outputFolder);
        [inputFolderFiles, ~, inputFolderFilesWithExt] = processDataFolder(vars.inputFolder);
        if(isempty(ouputFolderFiles))
            set(vars.pbDelete, 'Enable', 'Off');
            set(vars.pbViewPipe, 'Enable', 'Off');
        else
            set(vars.pbDelete, 'Enable', 'On');
            if(isempty(vars.viewPipe))
                set(vars.pbViewPipe, 'Enable', 'Off');
            else
                set(vars.pbViewPipe, 'Enable', 'On');
            end
            if(isempty(vars.editPipe))
                set(vars.pbEditPipe, 'Enable', 'Off');
            else
                set(vars.pbEditPipe, 'Enable', 'On');
            end
        end
        if(isempty(inputFolderFiles))
            return;
        end
        
        [~, rI] = setdiff(inputFolderFiles, ouputFolderFiles);
        inputFolderFilesWithExt = inputFolderFilesWithExt(rI);
        set(vars.lstInputList, 'String', inputFolderFilesWithExt);
        if(vars.selectedFileNum ~= 0)
            set(vars.lstInputList, 'Value', vars.selectedFileNum);
        end
        set(vars.lstOutputList, 'String', outputFolderFilesWithExt);
    end
    function [fileNames, fileExts, fileNamesWithExt] = processDataFolder(folderPath)
        fileNames = dir(folderPath);
        fileNames = fileNames(~[fileNames(:).isdir]);
        fileNames = {fileNames.name};
        excludedFiles = strcmpMSC(fileNames, EXCLUDED_FILES);
        fileNames = fileNames(~excludedFiles);
        fileNamesWithExt = fileNames;
        
        [fileNames, fileExts] = cellfun(@cellFilePart, fileNames, 'UniformOutput', 0);
        
        function [fNameWithoutExt, fileExts] = cellFilePart(fName)
            [~, fNameWithoutExt, fileExts] = fileparts(fName);
        end
    end

    function procFunc(~, ~)
        filesList = get(vars.lstInputList, 'String');
        selectedFileNum = get(vars.lstInputList, 'Value');
        if(isempty(filesList))
            return;
        end
        try
            processedFileData = vars.processPipe(fullfile(vars.inputFolder, filesList{selectedFileNum}));
        catch me
            errordlg(me.message, 'Error in processing pipeline', 'modal');
            processedFileData = [];
        end
        if(isempty(processedFileData))
            return;
        end
        % Construct a questdlg with two options
        choice = questdlg('Would you like to save the results?', ...
            'Save Result', ...
            'Yes', 'No', 'Yes');
        % Handle response
        switch choice
            case 'Yes'
                if ~exist(vars.outputFolder, 'dir')
                    mkdir(vars.outputFolder);
                end
                [~, saveFileName, ~] = fileparts(filesList{selectedFileNum});
                save(fullfile(vars.outputFolder, saveFileName), '-struct', 'processedFileData');
                if(vars.selectedFileNum >= length(filesList) - 1)
                    vars.selectedFileNum = selectedFileNum - 1;
                end
                updateLists;
            case 'No'
                return;
        end
    end
    function editFunc(~, ~)
        filesList = get(vars.lstOutputList, 'String');
        selectedFileNum = get(vars.lstOutputList, 'Value');
        if(isempty(filesList))
            return;
        end
        try
            processedFileData = vars.editPipe(fullfile(vars.outputFolder, filesList{selectedFileNum}));
        catch me
            errordlg(me.message, 'Error in edit pipeline', 'modal');
            processedFileData = [];
        end
        if(isempty(processedFileData))
            return;
        end
        % Construct a questdlg with two options
        choice = questdlg('Would you like to save the results?', ...
            'Save Result', ...
            'Yes', 'No', 'Yes');
        % Handle response
        switch choice
            case 'Yes'
                if ~exist(vars.outputFolder, 'dir')
                    mkdir(vars.outputFolder);
                end
                [~, saveFileName, ~] = fileparts(filesList{selectedFileNum});
                save(fullfile(vars.outputFolder, saveFileName), '-struct', 'processedFileData');
                updateLists;
            case 'No'
                return;
        end
    end

    function viewFunc(~, ~)
        filesList = get(vars.lstOutputList, 'String');
        selectedFileNum = get(vars.lstOutputList, 'Value');
        if(isempty(filesList))
            return;
        end
        viewFilePath = fullfile(vars.outputFolder, filesList{selectedFileNum});
        vars.viewPipe(viewFilePath);
    end
    function delFunc(~, ~)
        filesList = get(vars.lstOutputList, 'String');
        selectedFileNum = get(vars.lstOutputList, 'Value');
        if(isempty(filesList))
            return;
        end
        delFilePath = fullfile(vars.outputFolder, filesList{selectedFileNum});
        delete(delFilePath);
        set(vars.lstOutputList, 'Value', 1);
        updateLists;
    end
end

