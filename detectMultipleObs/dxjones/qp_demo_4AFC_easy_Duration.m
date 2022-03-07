% qp_demo_4AFC_easy.m

fprintf('QuestPlus Demo, 4AFC\n');

clear
addpath(genpath('../toolboxes/mQUESTPlus'));

%% simulate AFOV experiment

  sc.beta = linspace(1,5,5);
        sc.gamma = 0.25;
        sc.delta = 0.01;
        sc.minFR = 1;
        sc.maxFR = round(0.5*85);
        sc.stepsize = 1;
        sc.steps = sc.maxFR / sc.stepsize;
        sc.stimrange = contrast2db(linspace(sc.minFR, sc.maxFR, sc.steps));
        %sc.stimrange = linspace(contrast2db(sc.minFR), contrast2db(sc.maxFR), sc.steps);
        % convert frames to ms
        % stimTime = sc.stimrange * scrinfo.ifi
        
        psiParamsDomain = { sc.stimrange, sc.beta, sc.gamma, sc.delta };
        
        params.sc = sc; % store sc params
        
        %nTrials = 30; % per staircase
        switch params.typeTask
            case 'C'
                nSc = 1; % just need 1 for central-only task
            case 'P'
                nSc = 4;
            case 'B'
                nSc = 5; % add one for central task
        end
        
        nTrials=32; % 32 trials per sc
        %loop through the conditions in which a new Quest will be setup. 
            screc{nn}.param = qpParams( ...
                'nOutcomes', 2, ...
                'stimParamsDomainList', { sc.stimrange }, ...
                'psiParamsDomainList', psiParamsDomain, ...
                'stopRule', 'nTrials', ...
                'verbose', true );
            screc{nn}.questData = qpInitialize(screc{nn}.param);
        end
        
        
        end

        
nTrials = 60;

numChoices = 4;

% initialize 4AFC contrast threshold experiment
questData = qp_init_contrast_expt(numChoices);

% simulate an observer with 8% contrast threshold
simulatedThresholdContrast = 8.0;
simulatedThreshold = contrast2db( simulatedThresholdContrast );  % convert to log units

fprintf('Simulated Threshold = %.3f percent contrast\n', db2contrast(simulatedThreshold));
fprintf('Simulated Threshold = %.3f log units\n', simulatedThreshold);

simulatedPsiParams = qp_simulate_params(simulatedThresholdContrast, numChoices);


%% plot Simulated Psychometric Curve

qp_plot_simulated_psychometric_curve(numChoices, questData, simulatedPsiParams);


%% run simulated experiment

numEasyTrials = 6;
for t = 1 : nTrials
    
    % ask for the recommended stimulus
 
    stimulus = qp_easy_stimulus(t, numEasyTrials, contrast2db(90), questData);
     
    % in a real experiment, ...
    
        % present stimulus and get response from subject
        %
        % QuestPlus expects ...
        %   response = 1;  % WRONG
        %   response = 2;  % CORRECT
    
    % simulated response is based on psychometric function
 
    response = qpSimulatedObserver(stimulus, @qpPFWeibull, simulatedPsiParams);

    p = qpPFWeibull(stimulus, simulatedPsiParams);

    fprintf('trial %2d, stimulus = %5.2f, (%5.2f percent contrast), p = [%.3f %.3f], response = %d\n', ...
        t, stimulus, db2contrast(stimulus), p(1), p(2), response);
    
    % update QuestPlus model with stimulus + response
    
    questData = qpUpdate(questData, stimulus, response);

end


%% summarize results

fprintf('\n');
fprintf('note: parameters are:                  threshold,  beta, gamma, delta\n\n');

fprintf('Simulated parameters:                     %0.3f, %0.3f, %0.3f, %0.3f\n', ...
    simulatedPsiParams(1), simulatedPsiParams(2), simulatedPsiParams(3), simulatedPsiParams(4));

fit = qp_fit_max_posterior(questData);
fprintf('Maximum posterior QuestPlus parameters:   %0.3f, %0.3f, %0.3f, %0.3f\n', fit(1), fit(2), fit(3), fit(4));

fit = qp_fit_max_likelihood(questData);  % use this fit for your results
fprintf('Maximum likelihood fit parameters:        %0.3f, %0.3f, %0.3f, %0.3f   <== use this for results\n', fit(1), fit(2), fit(3), fit(4));


%% express threshold as percent contrast

measuredThreshold = fit(1);
measuredThresholdContrast = db2contrast( measuredThreshold );

fprintf('\n');
fprintf('Simulated threshold = %.3f percent contrast (%.3f log units)\n', simulatedThresholdContrast, simulatedThreshold);
fprintf('Measured threshold  = %.3f percent contrast (%.3f log units)\n', measuredThresholdContrast, measuredThreshold);

