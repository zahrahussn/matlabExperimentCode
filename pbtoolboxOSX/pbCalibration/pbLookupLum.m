function lumValues=pbLookupLum(lutValues,LumVector,lutVector)
%
% function lumValues=pbLookupLum(lutValues,LumVector,lutVector)
% 
% Returns the luminance values contained in LumVector(lutValues),
% interpolating if necessary.
%
    if (nargin<3)
        error('This function requires 3 input parameters.');
    end;


    if(size(LumVector,2)~=1)
        LumVector=reshape(LumVector,prod(size(LumVector)),1);
    end;
    
    if(size(lutVector,2)~=1)
        lutVector=reshape(lutVector,prod(size(lutVector)),1);
    end;

    if(length(LumVector)~=length(lutVector))
        error('LumVector and lutVector must have the same number of elements.');
    end;
    
    if(length(LumVector)<2)
        error('LumVector must contain at least 2 elements.');
    end;
    
    [nr,nc]=size(lutValues);
    bv1=reshape(lutValues,nr*nc,1);
    minB=min(lutVector);
    maxB=max(lutVector);
    tmp=find(bv1<minB); bv1(tmp)=minB;
    tmp=find(bv1>maxB); bv1(tmp)=maxB;
%         lumValues=interp1(lutVector,LumVector,bv1,'linear');
    lumValues=interp1q(lutVector,LumVector,bv1);
    lumValues=reshape(lumValues,nr,nc);

