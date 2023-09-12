function [params] = normCDFfitfn( data, polarity, init )% function [params] = normCDFfitfn( data, polarity, init )% % Fits a 4-parameter cumulative normal to a data set.  DATA is a 3 column vector,% with x values in the first column, y values in the second, and errors% in the third. If there is no third column, a column of ones is put in% its place. The errors are used to weight the fit.% INIT are the initial values for the parameters x(1)-x(4), or delta,% gamma,alpha,beta. % DELTA should be set to the minimum of the y data. % GAMMA should be set to the difference between the max and min of the y data.% MU should be set to the mean of the y data.% SIGMA who knows, probably 2-3.% These are the defaults if INIT is not passed.% POLARITY is the direction of the fit. If it is 1, it is a typical function.% If it is -1, it is (1-normCDF). Default is 1.% If the data is really small, this scales it.%temp = max(data(:,2));%factor = log10(temp);%scaled = 0;%if factor < 0%	data(:,2) = data(:,2)*10^(abs(factor));%	scaled = 1;%end% Set the errors to 1 for all points if none are given, so no differential weighting.% If there are errors given, normalize them to a max of 1.sz = size(data);if sz(2) == 2	data = [data,ones(sz(1),1)];end% Default value for sigma.sigma = 3;if nargin < 3	init(1) = min(data(:,2));	init(2) = max(data(:,2))-min(data(:,2));	init(3) = mean(data(:,1));	init(4) = sigma;end	if exist('polarity') ~= 1	polarity == 1;endif polarity ~= -1	errfn = inline('sum( ( (x(1)+x(2)*normcdf(P1(:,1),x(3),x(4)) - P1(:,2) ).^2)./P1(:,3))',1);else	errfn = inline('sum( ( (x(1)+x(2)*(1-normcdf(P1(:,1),x(3),x(4))) - P1(:,2) ).^2)./P1(:,3))',1);endoptions=foptions;options(14)=10000;fit = fmins(errfn,init,options,[],data);delta=fit(1);gamma=fit(2);mu=fit(3);sigma=fit(4);% put into a matrix for output.params = [delta gamma mu sigma];%if scaled == 1%	delta = delta/(10^(abs(factor)));%	gamma = gamma/(10^(abs(factor)));%endreturn