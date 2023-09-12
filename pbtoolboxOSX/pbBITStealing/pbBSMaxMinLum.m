function [Lmin,Lmax]=pbBSMaxMinLum(L)
    if(size(L,2)~=1)
        L=reshape(L,prod(size(L)),1);
    end;
    Lmin=L(1);
    Lmax=L(end);
    
    