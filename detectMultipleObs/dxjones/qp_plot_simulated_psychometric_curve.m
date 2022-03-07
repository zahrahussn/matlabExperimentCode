%% plot Simulated Psychometric Curve

function qp_plot_simulated_psychometric_curve(numChoices, questData, simulatedPsiParams)

    figure(1);

    if numChoices == 2
        threshold_correct = 0.817;
    elseif numChoices == 4
        threshold_correct = 0.750;
    else
        fprintf('qp_plot: numChoices %d not supported (should be 2 or 4)\n', numChoices);
    end
    
    simulated_threshold = simulatedPsiParams(1);
    stimDomain = questData.stimParamsDomain;
    N = numel(stimDomain);
    percentCorrect = zeros(N,1);
    for i = 1 : N
        p = qpPFWeibull(stimDomain(i), simulatedPsiParams);
        percentCorrect(i) = p(2);
    end
    semilogx(db2contrast(stimDomain), percentCorrect, 'b-', db2contrast(simulated_threshold), threshold_correct, 'ro', 'MarkerSize', 15, 'MarkerFaceColor', 'r');
    legend('4AFC Psychometric Curve', sprintf('%.1f%% Correct Threshold', 100*threshold_correct), 'Location', 'NorthWest');
    xlabel('Percent Contrast (log axis)');
    ylabel('Percent Correct Responses');
    title('Simulated Psychometric Function');
    drawnow

end