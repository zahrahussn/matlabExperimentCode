function [f] = logcenter(f1,f2)% function [f] = logcenter(f1,f2)%% returns the logarithmic center between F1 and F2% if f1 and f2 are scalars, the order does not matter% (i.e., F2 can be the lower value). % if f1 and f2 are vectors, f1 should be the lower% frequency in each corresponding pair % (i.e., f1(1) vs f2(1)).% derivation% f = 2^(log2(f2) - (log2(f2)-log2(f1))/2)%	= 2^(log2(f2) - log2(f2)/2 + log2(f1)/2)%	= 2^(log2(f2)/2 + log2(f1)/2)%	= 2^((log2(f2)+log2(f1))/2)if nargin == 2	if size(f1) == size(f2)		if max(size(f1)) == 1			f = 2.^((log2(max([f1,f2]))+log2(min([f1,f2])))./2);		else			f = 2.^((log2(f1)+log2([f2]))./2);		end	else		fprintf(1,'Inputs must be the same size.\n');		help logcenter;	endelse	fprintf(1,'Not enough arguments passed.\n');	help logcenter;endreturn;