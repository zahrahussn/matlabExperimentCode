function bigimage = putcenter(bigimage,smallimage,type)% function newImage = putcenter(bigimage,smallimage,type)%% Puts SMALLIMAGE in the center of an BIGIMAGE. % If the size of SMALLIMAGE exceeds that of BIGIMAGE,% SMALLIMAGE is returned.%% Jan 13 2000  JMG U of T Vision Lab defarg('type','replace');if nargin>1		[cols,rows] = size(smallimage);	[oldRows,oldCols] = size(bigimage);	if cols<oldCols | rows<oldRows		center = floor([oldRows/2, oldCols/2]);		halfRows = floor(rows/2);		halfCols = floor(cols/2);		if rem(rows,2) == 0			if strcmp(type,'replace')				bigimage(center(1)-halfRows+1:center(1)+halfRows,center(2)-halfCols+1:center(2)+halfCols) = smallimage;			else				bigimage(center(1)-halfRows+1:center(1)+halfRows,center(2)-halfCols+1:center(2)+halfCols) = bigimage(center(1)-halfRows+1:center(1)+halfRows,center(2)-halfCols+1:center(2)+halfCols)+smallimage;			end						else			if strcmp(type,'replace')				bigimage(center(1)-halfRows+1:center(1)+halfRows+1,center(2)-halfCols+1:center(2)+halfCols+1) = smallimage;			else				bigimage(center(1)-halfRows+1:center(1)+halfRows+1,center(2)-halfCols+1:center(2)+halfCols+1) = bigimage(center(1)-halfRows+1:center(1)+halfRows+1,center(2)-halfCols+1:center(2)+halfCols+1) + smallimage;			end					end	else		bigimage = smallimage;	end	else		error('not enough parameters passed.');endreturn