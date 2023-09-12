function theValues=pbLookupScalar(xi,Y,X)
%
% function theValues=pbLookupScalar(xi,Y,X)
% 
% This function is a wrapper to MATLAB's interp1q.
% Essentially, it creates a table [X,Y], looks up the elements
% xi in X, and returns an interpolated value of Y.
% N.B. This function assumes that Y consists of SCALAR values,
% but it does not assume that xi, X, and Y are 1D.
%

    if (nargin<3)
        error('This function requires 3 input parameters.');
    end;


    if(size(Y,2)~=1)
        Y=reshape(Y,prod(size(Y)),1);
    end;
    
    if(size(X,2)~=1)
        X=reshape(X,prod(size(X)),1);
    end;

    if(length(Y)~=length(X))
        error('Y and X must have the same number of elements.');
    end;
    
    if(length(Y)<2)
        error('Y must contain at least 2 elements.');
    end;
    
    [nr,nc]=size(xi);
    bv1=reshape(xi,nr*nc,1);
    minB=min(X);
    maxB=max(X);
    tmp=find(bv1<minB); bv1(tmp)=minB;
    tmp=find(bv1>maxB); bv1(tmp)=maxB;
%         theValues=interp1(X,Y,bv1,'linear');
    theValues=interp1q(X,Y,bv1);
    theValues=reshape(theValues,nr,nc);

