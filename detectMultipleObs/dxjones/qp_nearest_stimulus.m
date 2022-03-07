% qp_nearest_stimulus.m
%
% QuestPlus quantizes the stimulus domain,
% so arbitrary stimulus values are not supported.
%
% This function returns the QuestPlus stimulus 
% that is nearest to the desired stimulus
%
% This code assumes a simple, one dimensional stimulus domain
% such as a contrast threshold experiment.
%

function stimulus = qp_nearest_stimulus(desiredStimulus, questData)

    lo = find(questData.stimParamsDomain <= desiredStimulus, 1, 'last');
    hi = find(questData.stimParamsDomain >= desiredStimulus, 1, 'first');
    if (desiredStimulus - lo) < (hi - desiredStimulus)
        near = lo;
    else
        near = hi;
    end
    stimulus = questData.stimParamsDomain(near);
    
end
