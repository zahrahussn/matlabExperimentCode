function prep = idealprep( templates )% IDEALPREP  Preprocess templates for ideal observer simulations%% prep = idealprep( templates )% 07-Sep-98 -- created (RFM)prep.T=prod(size(templates));     % number of templatesprep.N=size(templates{1},1);      % size of templates (assumed square)prep.template=templates;          % templatesclear templates;% get Fourier transforms of templatesfor t=1:prep.T,	prep.templateft{t}=fftshift(fft2(prep.template{t}));end% calculate signal means and template productsfor i=1:prep.T,	for j=i:prep.T,		% mean		prep.sigmean(i,j)=sum(sum( prep.template{i}.*prep.template{j} ));		prep.sigmean(j,i)=prep.sigmean(i,j);		% scaled product		prep.templateprod{i,j}=real(prep.templateft{i}.*conj(prep.templateft{j}))/(prep.N^2);	endendreturn