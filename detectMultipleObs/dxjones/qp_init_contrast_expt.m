% qp_init_contrast_expt.m
%
% Initialize QuestPlus for a typical contrast threshold experiment
%
% This function tries to provide a simpler way to use QuestPlus
% by filling in some of the required parameters with reasonable values.
%
% optional parameters:
%
%   numChoices = 2 or 4 (for 2AFC or 4AFC)
%              = default is 2
%
%   delta = proportion of trials when subjects blinks;
%         same as the proportion wrong responses on very easy trials
%         = default is 0.01
%

function questData = qp_init(numChoices, delta)

% default values
    if nargin < 1
        numChoices = 2;     % 2 AFC
    end
    
    if nargin < 2
        delta = 0.01;       % subjects blinks on 1% of trials
    end
    
% gamma is the percent correct when stimulus is invisible (random guessing)
    if numChoices == 2
        gamma = 0.50;       % 2AFC
    elseif numChoices == 4
        gamma = 0.25;       % 4AFC
    else
        fprintf('qp_init: numChoices %d not supported (should be 2 or 4)\n', numChoices);
        questData = [];
        return
    end
    
% slope of psychometric function, assuming contrast in dB (log units)
    beta = 3.5;

% ask QuestPlus to search between 0.1 and 100 percent contrast
% note: we convert to log(contrast) units for Quest

    stimMin = contrast2db(   0.1 );
    stimMax = contrast2db( 100.0 );

    stimDomain = linspace(stimMin, stimMax, 1000);

    psiParamsDomain = { stimDomain, beta, gamma, delta };

    param = qpParams( ...
        'nOutcomes', 2, ...
        'stimParamsDomainList', { stimDomain }, ...
        'psiParamsDomainList', psiParamsDomain, ...
        'stopRule', 'nTrials', ...
        'verbose', true );
    
    questData = qpInitialize(param);

end

