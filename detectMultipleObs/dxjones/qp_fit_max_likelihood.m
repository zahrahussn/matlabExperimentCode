% qp_fit_max_likelihood.m
%
% maximum likelihood fit of the psychometric funtion parameters
%
% use this to record your results
%

function fit = qp_fit_maxlikelihood(questData)

    psiParamsIndex = qpListMaxArg(questData.posterior);
    psiParamsQuest = questData.psiParamsDomain(psiParamsIndex,:);
    fit = qpFit(questData.trialData, questData.qpPF, psiParamsQuest, questData.nOutcomes, ...
    'lowerBounds', [questData.psiParamsDomainList{1}(1) questData.psiParamsDomainList{2}(1) questData.psiParamsDomainList{3}(1) questData.psiParamsDomainList{4}(1)], ...
    'upperBounds', [questData.psiParamsDomainList{1}(end) questData.psiParamsDomainList{2}(end) questData.psiParamsDomainList{3}(end) questData.psiParamsDomainList{4}(end)]);

end
