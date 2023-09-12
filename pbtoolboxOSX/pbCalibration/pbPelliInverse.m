function lutnumber=pbPelliInverse(x,lumValues,lutoffset)
%
% function lutnumber=pbPelliInverse(x,lumValues,lutoffset)
%

	if(exist('lutoffset')==0)
		lutoffset=1; % for accessing value in matlab array
	end;
	if (lutoffset ~= 0) & (lutoffset ~=1)
		exit('lutoffset should be zero (for accessing a LUT) or 1 (for accessing a matlab array)');
	end;
	% find the corresponding values in the calibration matrix. NB: CLUT(1,1;3) = Lave
	lutnumber=zeros(size(lumValues));
	if x(3)~=0
		Lum1locs=find(lumValues>=x(1));
		Lum2locs=find(lumValues<x(1));
		lutnumber(Lum1locs)=round((1.0/x(3)).*(exp(log(lumValues(Lum1locs)-x(1)).*(1.0./x(4)))-x(2)));
		lutnumber(Lum2locs)=round(-x(2)./x(3));
	end
	lutnumber = lutnumber+lutoffset;
	
end
