function bsOut = pbBSclip(bsindex,clipRange)
%
% function bsOut = pbBSclip(bsindex,[clipRange])
%

	if nargin<2
		minValue = 1;
		maxValue = pbMaxBITStealingIndex;
	else
		minValue = min(clipRange(:));
		maxValue = max(clipRange(:));
	end;
    tmpMax=find(bsindex>maxValue);
    tmpMin=find(bsindex<minValue);

	if(length(tmpMax)>0)
		bsindex(tmpMax) = maxValue;
	end;
	if(length(tmpMin)>0)
		bsindex(tmpMin) = minValue;
	end;
	
	bsOut = bsindex;


