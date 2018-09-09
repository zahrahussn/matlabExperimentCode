function [rgb]=Lum2RGB(lum,calmatrix,params)

% function [rgb]=Lum2RGB(lum,calmatrix,params)


a=params(1);
b=params(2);
k=params(3);
g=params(4);

sL=size(lum);
nrows=sL(1)*sL(2);
rgb=zeros(nrows,3);
% calIndices=zeros(nrows,1);

lum1D=reshape(lum,nrows,1);
% clip image
minLum=calmatrix(1,4);
maxLum=calmatrix(end,4);
tmp=find(lum1D>maxLum); lum1D(tmp)=maxLum;
tmp=find(lum1D<minLum); lum1D(tmp)=minLum;

lumlocs1=find(lum1D>=a);
lumlocs2=find(lum1D<a);


% calIndices(lumlocs1)=round((1.0/k)*(exp(log(lum(lumlocs1)-a)*(1.0/g))-b))
% calIndices(lumlocs2)=round(-b/k)
if (~isempty(lumlocs1))
    rgb(lumlocs1,:)=calmatrix(round((1.0/k)*(exp(log(lum1D(lumlocs1)-a)*(1.0/g))-b)), 1:3);
end;

if (~isempty(lumlocs2))
    rgb(lumlocs2,:)=calmatrix(round(-b/k),1:3);
end;

rgb=reshape(rgb,sL(1),sL(2),3);
return;
