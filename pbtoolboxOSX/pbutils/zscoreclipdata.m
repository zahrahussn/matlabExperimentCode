function [dout,numNaN]=zscoreclipdata(data,criterion)%% function [dout,numNaN]=zscoreclipdata(data,criterion)%%	<data>		- data VECTOR (not a matrix)%	<criterion>	- proportion of data that is KEPT; if criterion is 0.95, then the lowest 2.5% and highest 2.5% are thrown out %if nargin<2	disp('Error in CLIPDATA! Must include data & criterion as input arguments.');	dout=NaN;	numNaN=NaN;	return;end;tmp=size(data);if (min(tmp)>1)	disp('Error in CLIPDATA! The data must be a vector, not a matrix.');	dout=NaN;	numNaN=NaN;	return;end;if (criterion<=0)	disp('Error in CLIPDATA! The criterion must be a scalar greater than zero.');	dout=NaN;	numNaN=NaN;	return;end;% first remove all NaN from the datalocnan=find(isnan(data)==1); numNaN=length(locnan);tmp=find(isnan(data)==0);databuffer=zeros(1,length(tmp));databuffer=data(tmp);% next, convert to z scoressd=sqrt(var(databuffer(:)));m=mean(databuffer(:));zscores=(databuffer-m)/sd;locs=find(abs(zscores)<=criterion);dout=databuffer(locs);return;