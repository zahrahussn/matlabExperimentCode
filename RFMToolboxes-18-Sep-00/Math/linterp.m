function y = linterp( dataset, x )% LINTERP  Linear interpolation/extrapolation%% y = linterp( dataset, x )n=size(x(:),1);for i=1:n,	low=find(dataset(:,1)<=x(i));	high=find(dataset(:,1)>x(i));	if isempty(low),		y(i)=linfit(dataset(high([ 1 2 ]),:),x(i));	elseif isempty(high),		y(i)=linfit(dataset(low([ end-1 end ]),:),x(i));	else		y(i)=linfit(dataset([ low(end) high(1) ],:),x(i));	end%	fprintf(1,'%.1f %.1f\n',x(i),y(i));endy=reshape(y,size(x));returnfunction y = linfit( points, x )y = points(1,2) + (x-points(1,1))*((points(2,2)-points(1,2))/(points(2,1)-points(1,1)));return