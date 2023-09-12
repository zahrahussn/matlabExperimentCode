function thefilter=bpfilter1d(lowf,highf,dim);%% function thefilter=bpfilter1d(lowf,highf,dim);% Constructs a 1D ideal, bandpass FREQUENCY filter.% Only spatial frequencies between lowf and highf are passed by the filter.% See BPIMAGE for example of how thefilter can be used to filter an image.%if (nargin<3)	disp('ERROR IN bpfilter1d: 3 input parameters are required.');	thefilter=NaN;	return;end;if (dim<1)	disp('ERROR IN bpfilte1dr: dimension must be greater than zero.');	thefilter=NaN;	return;end;if (isempty(lowf)|isnan(lowf)|isempty(highf)|isnan(highf))	thefilter=ones(1,dim);	return;end;if (lowf>highf)	ftemp=lowf;	lowf=highf	highf=ftemp;end;dc=round(dim/2)+1;thefilter=zeros(1,dim);dx=1:dim;dx=dx-dc;d=sqrt(dx.*dx);val1=find((d > lowf)&(d < highf));thefilter(1,val1)=ones(1,length(val1));thefilter(1,dc)=1;return;