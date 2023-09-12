function bitsValues=pbLum2BITS(lumValues,L,B)

    if(nargin<3)
        error('must pass 3 variables to this function');
    end;
    if(size(L,2)~=1)
        L=reshape(L,prod(size(B)),1);
    end;
    if(size(B,2)~=1)
        B=reshape(B,prod(size(B)),1);
    end;
    if(length(L)~=length(B))
        error('L and B must have the same number of elements');
    end;
    [nr,nc]=size(lumValues);
    lv1=reshape(lumValues,nr*nc,1);
    bitsValues=interp1(L,B,lv1,'linear');
%     bitsValues=interp1q(L,B,lv1);
    bitsValues=reshape(bitsValues,nr,nc);
    
    
