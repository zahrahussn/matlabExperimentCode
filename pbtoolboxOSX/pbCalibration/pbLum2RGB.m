function [rgb,rgblum,lutnumbers]=pbLum2RGB(lum,calmatrix,params)
%
% function [rgb,rgblum,lutnumbers]=pbLum2RGB(lum,calmatrix,params)
%

	lumsize=size(lum);
	cmsize=size(calmatrix);
	lum=reshape(lum,lumsize(1)*lumsize(2),1);
	lutnumbers=pbPelliInverse(params,lum,1);
	tmp0=find(lutnumbers<1);
	if (length(tmp0)>0)
		lutnumbers(tmp0)=1;
	end;
	tmp1=find(lutnumbers>cmsize(1));
	if (length(tmp1)>0)
		lutnumbers(tmp1)=cmsize(1);
	end;
	rgb=calmatrix(lutnumbers,1:3);
	rgb=reshape(rgb,lumsize(1),lumsize(2),3);
	rgblum=calmatrix(lutnumbers,4);
	
	
end