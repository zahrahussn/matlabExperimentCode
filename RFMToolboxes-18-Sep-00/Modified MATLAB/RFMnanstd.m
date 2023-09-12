%function y = nanstd(x,dim)function y = nanstd(x)%NANSTD Standard deviation ignoring NaNs.%   NANSTD(X,dim) returns the same standard deviation treating NaNs %   as missing values.%%   For vectors, NANSTD(X) is the standard deviation of the%   non-NaN elements in X.  For matrices, NANSTD(X) is a row%   vector containing the standard deviation of each column,%   ignoring NaNs.%%   See also NANMEAN, NANMEDIAN, NANMIN, NANMAX, NANSUM.%%   MODIFIED TO ACCEPT <dim> ARGUMENT, LIKE STD.M (RFM)%   Copyright (c) 1993-97 by The MathWorks, Inc.%   $Revision: 2.6 $  $Date: 1997/04/08 15:07:51 $%   29-Apr-99 -- 'dim' argument added (RFM)%   30-Apr-2013-- 'dim' argument removed (ZH)nans = isnan(x);i = find(nans);if nargin==1,   dim = min(find(size(x)~=1));  if isempty(dim), dim = 1; endend% Find meanavg = nanmean(x,dim);% if min(size(x))==1,%    count = length(x)-sum(nans);%    x = x - avg;% else%    count = size(x,1)-sum(nans);%    x = x - avg(ones(size(x,1),1),:);% endcount = size(x,dim)-sum(nans,dim);% kludgen=size(x,dim);bigavg=[];for j=1:n,	bigavg=cat(dim,bigavg,avg);endx = x - bigavg;% Replace NaNs with zeros.x(i) = zeros(size(i));% Protect against a column of all NaNsi = find(count==0);count(i) = ones(size(i));y = sqrt(sum(x.*x,dim)./max(count-1,1));y(i) = i + NaN;