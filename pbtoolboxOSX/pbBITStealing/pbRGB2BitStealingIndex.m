function bsnumber = pbRGB2BitStealingIndex(RGB,rgbMatrix)
%
% function bsnumber = pbRGB2BitStealingIndex(RGB,rgbMatrix)
% Converts an rgb value two an index into a Bit-stealing array
%

if nargin<2
    error('insufficient inputs to function');
end;
if (size(RGB,2)~=3)
	error('RGB input must have 3 columns');
end;

n=size(RGB,1);
bsnumber=zeros(n,1); % assumes RGB is a 3 colum matrix
for kk=1:n
	rgbtmp=RGB(kk,:);
	bsnumber(kk)=find(rgbMatrix(:,1)==rgbtmp(1)&rgbMatrix(:,2)==rgbtmp(2)&rgbMatrix(:,3)==rgbtmp(3));
end;
return;




