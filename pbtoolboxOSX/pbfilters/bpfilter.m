function thefilter=bpfilter(lowf,highf,dim);%% function thefilter=bpfilter(lowf,highf,dim);% Constructs a 2D ideal, bandpass FREQUENCY filter.% Only spatial frequencies between lowf and highf are passed by the filter.% See BPIMAGE for example of how thefilter can be used to filter an image.%% 28-Mar-00 (PJB) Commented-out line that put a value of 1 at the DC point.if (nargin<3)	disp('ERROR IN bpfilter: 3 input parameters are required.');	thefilter=NaN;	return;end;if (dim<1)	disp('ERROR IN bpfilter: dimension must be greater than zero.');	thefilter=NaN;	return;end;if (isempty(lowf)|isnan(lowf)|isempty(highf)|isnan(highf))	thefilter=ones(dim,dim);	return;end;if (lowf>highf)	ftemp=lowf;	lowf=highf	highf=ftemp;end;dc=[round(dim/2)+1,round(dim/2)+1];thefilter=zeros(dim,dim);dx=1:dim;dx=dx-dc(1);for yk=1:dim	dy=dc(2)-yk;	d=sqrt(dx.*dx + dy*dy);	val1=find((d > lowf)&(d < highf));	thefilter(yk,val1)=ones(1,length(val1));end;% thefilter(dc(1),dc(2))=1;