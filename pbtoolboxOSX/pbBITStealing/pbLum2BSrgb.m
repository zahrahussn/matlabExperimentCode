function rgb=pbLum2BSrgb(lumValues,L,rgbMat)

    if(nargin<3)
        error('must pass 3 variables to this function');
    end;
    if(size(L,2)~=1)
        L=reshape(L,prod(size(L)),1);
    end;
    
    nL = length(L);
    nRGB = size(rgbMat,1);
    if(nL~=nRGB)
        error('L and B must have the same number of rows');
    end;
    [nr,nc]=size(lumValues);
    
    lv1=reshape(lumValues,nr*nc,1);
    bitsValues=interp1(L,B,lv1,'linear');
%     bitsValues=interp1q(L,B,lv1);
    bitsValues=reshape(bitsValues,nr,nc);
    
    
