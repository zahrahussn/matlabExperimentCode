% qp_simulate_params.m

function simulatedPsiParams = qp_simulate_params(contrastThreshold, numChoices, delta)

    if nargin < 1
        contrastThreshold = 10;
    end
  
    if nargin < 2
        numChoices = 2;
    end
    
    if nargin < 3
        delta = 0.01;
    end
    
% gamma is percent correct when stimulus is invisible (random guessing)
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

    simulatedThreshold = contrast2db( contrastThreshold );

    simulatedPsiParams = [ simulatedThreshold, beta, gamma, delta ];

end

