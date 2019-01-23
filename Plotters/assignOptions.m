function [ assignedOptions ] = assignOptions( inputOptions, defaultOptions )
%ASSIGNOPTIONS Takes input options and assigns any missing options from
%   default options.
%
%
%   Copyright (c) <2019> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.
assignedOptions = inputOptions;
mustHaveFields = fieldnames(defaultOptions);
for i = 1:length(mustHaveFields)
    if(~isfield(inputOptions, mustHaveFields{i}))
        assignedOptions.(mustHaveFields{i}) = defaultOptions.(mustHaveFields{i});
    end
end
end

