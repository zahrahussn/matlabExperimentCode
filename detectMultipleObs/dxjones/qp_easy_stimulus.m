% qp_easy_stimulus.m
%
% QuestPlus searches aggressively for the threshold.
% Therefore, the task will be close to threshold very quickly,
% and some subjects may find this challenging.
%
% This function gives enables an easier stimulus for the
% first several trials and gradually hands off to QuestPlus.
%
% example:
%
%   easy_stimulus(3, 5, contrast2db(90.0), questData);
%
% This asks for a stimulus for trial number 3.
% The number of easier trials is 5.
% The "easy" stimulus is 90 percent contrast (converted to log units).
%
% The function returns a weighted average, combining the
% easy stimulus and the hard stimulus recommended by QuestPlus.
%
% The weight for the easy stimulus decreases linearly with each trial.
% After the specified number of easy trials, the remaing trials are
% exactly what QuestPlust recommends.
%

function stimulus = qp_easy_stimulus(trial, numEasyTrials, easyStimulus, questData)

% ask Quest+ which stimulus is recommended
    questStimulus = qpQuery(questData);
    
    if trial > numEasyTrials
    % if we are past the "easy" trials, just do what Quest+ recommends

        stimulus = questStimulus;

    else
    % easy weight declines linearly from 1.0 for trial 1,
    % to (1/numEasyTrials) for the last "easy" trial

        weight = linspace(1, 0, 1 + numEasyTrials);
        w = weight(trial);
        desiredStimulus = w * easyStimulus + (1-w) * questStimulus;
        stimulus = qp_nearest_stimulus(desiredStimulus, questData);

%         fprintf('t: %d, quest: %.3f, easy: %.3f, actual: %.3f, w: %.3f\n', ...
%             trial, questStimulus, desiredStimulus, stimulus, w);
    end
    
end
