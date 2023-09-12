function clippedData = pbClipData(inData,theMin,theMax)

	if nargin<3
		error('must have 3 input arguments')
	end;
	
	tmpMin = find(inData<theMin);
	tmpMax = find(inData>theMax);
	
	if(length(tmpMin)>0)
		inData(tmpMin) = theMin;
	end;
	if(length(tmpMax>0)
		inData(tmpMax) = theMax;
	end;