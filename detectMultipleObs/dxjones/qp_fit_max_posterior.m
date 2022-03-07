% qp_fit_max_posterior.m
%
% max posterior estimate of the QuestPlus parameters
%

function fit = qp_fit_max_posterior(questData)

    psiParamsIndex = qpListMaxArg(questData.posterior);
    psiParamsQuest = questData.psiParamsDomain(psiParamsIndex,:);
    fit = psiParamsQuest;

end