function [ Unc ] = GetUnc( StimName )% GetUnc - choose an uncertainty vector%% [ Unc ] = GetUnc( StimName )%%     StimName - stimulus name%     Unc      - uncertainty vector for named stimulus%UncProb = [ StimName 'Prob' ]; % construct name of vector functionUncMax = feval(UncProb,-1);    % find range of vector% choose uncertainty vector in accordance with probability distributionwhile 1,	Unc = RndInt(ones(size(UncMax)),UncMax);	if rand<feval(UncProb,Unc),		break	endendreturn