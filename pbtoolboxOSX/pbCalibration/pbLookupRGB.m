function rgb = pbLookupRGB(bsindex,rgbMatrix,checkRange)
%
% function bsnumber = pbLookupRGB(bsindex,rgbMatrix,checkRange)
%
% Converts indices into RGB values using rgbMatrix.
% bsindex   :   vector of indices
% rgbMatrix :   n x 3 matrix of rgb values
% checkRange :  if 1, will check bsindex to ensure that all values are in
%               range. Set to zero if you want to skip this step. Default is 1
%

if nargin<3
    checkRange=1;
end;
if nargin<2
    error('insufficient inputs to function');
end;

if (size(bsindex,2)~=1)
	error('bsindex input must be a vector');
end;

% if isempty(pbBigRGBArray)
% 	tmp=pbBitStealingArray;
% else
% 	tmp=pbBigRGBArray;
% end;
if(checkRange==1)
    tmpMax=max(bsindex(:));
    tmpMin=min(bsindex(:));

    if tmpMin<1
        error('minimum index cannot be less than 1');
    end;
    if tmpMax>pbMaxBITStealingIndex
        error('maximum bit-stealing index is out of bounds');
    end;
end; % if

rgb = rgbMatrix(bsindex,:);

% n=length(bsindex);
% rgb=zeros(n,3);
% 
% for kk=1:n
% 	rgb(kk,:)=rgbMatrix(bsindex(kk),:);
% end;



