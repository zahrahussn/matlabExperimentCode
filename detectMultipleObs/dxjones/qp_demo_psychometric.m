% qp_demo_psychometric.m

clear
addpath(genpath('../toolboxes/mQUESTPlus'));


%% initialize 2AFC contrast threshold experiment

numChoices = 2;

questData = qp_init_contrast_expt(numChoices);

% simulate an observer with 10% contrast threshold
simulatedThresholdContrast = 10.0;
simulatedThreshold = contrast2db( simulatedThresholdContrast );  % convert to log units
simulatedPsiParams = qp_simulate_params(simulatedThresholdContrast, numChoices);


%% plot Simulated Psychometric Curve

qp_plot_simulated_psychometric_curve(numChoices, questData, simulatedPsiParams);


