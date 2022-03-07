% qp_demo_2AFC_easy.m

fprintf('QuestPlus Demo, 2AFC\n');

clear
addpath(genpath('../toolboxes/mQUESTPlus'));

%% simulate constrast threshold experiment

nTrials = 60;

numChoices = 2;

% initialize 4AFC contrast threshold experiment
questData = qp_init_contrast_expt(numChoices);

% simulate an observer with 8% contrast threshold
simulatedThresholdContrast = 5.0;
simulatedThreshold = contrast2db( simulatedThresholdContrast );  % convert to log units

fprintf('\nSimulated Threshold = %.3f percent contrast, %.3f log units\n\n', db2contrast(simulatedThreshold),  simulatedThreshold);

simulatedPsiParams = qp_simulate_params(simulatedThresholdContrast, numChoices);


%% plot Simulated Psychometric Curve

qp_plot_simulated_psychometric_curve(numChoices, questData, simulatedPsiParams);


%% run simulated experiment

numEasyTrials = 8;
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
    simulatedPsiParams(1) ,simulatedPsiParams(2), simulatedPsiParams(3), simulatedPsiParams(4));

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

