function val = sampledrv( invcdf, dim )% sampledrv - takes a matrix <invcdf> generated by 'mkdrv', and returns%             random values according to the distribution used to generate%             <invcdf>defarg('dim',1);unifsample = rand(dim);[ m n ] = size(unifsample);for i=1:m,	for j=1:n,		val(i,j)=invcdf(min(find(invcdf(:,1)>unifsample(i,j))),2);	endendreturn