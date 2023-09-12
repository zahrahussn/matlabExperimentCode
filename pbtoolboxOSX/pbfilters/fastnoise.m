clear all;nvar=16;	% this is the desired variancenrow=64;ncol=64;ntot=nrow*ncol;	% the spatial dimensions of the matricestic;% standard methodw=randn(nrow,ncol);	% create a 2d noiseov=std(reshape(w,1,ntot))^2; a=sqrt(nvar/ov); w=w*a; % set the variance to nvar% now you would fft the matrix, filter spectrum, & compute ifftft=fft2(w);w=real(ifft2(ft));toc;nv=std(reshape(w,1,ntot))^2;	% check to see that it is correct% new methodNo=nvar/ntot;	% No is the noise spectral densitytic;cospart=randn(nrow,ncol); % create the cosine spectrumov=std(reshape(cospart,1,ntot))^2;a=sqrt(No/ov); % set variance to No/2a=a*ntot;	% include ntot to rescale the spectrum for the FFT algorithmcospart=cospart*a;sinpart=randn(nrow,ncol); % create the sine spectrumov=std(reshape(sinpart,1,ntot))^2;a=sqrt(No/ov);a=a*ntot;	% include ntot to rescale the spectrum for the FFT algorithmsinpart=sinpart*a; % set variance to No/2% could filter the cosine and sine parts here...i=sqrt(-1);ft2=cospart+i*sinpart; % put 2 part together into a single complex matrixw2=real(ifft2(ft2));		% compute iffttocnv2=std(reshape(w2,1,ntot))^2;var=[nvar,nv,nv2]