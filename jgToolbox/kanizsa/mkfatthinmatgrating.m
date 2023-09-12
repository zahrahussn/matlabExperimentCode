function fmat = mkfatthinmatgrating( n, radiusP, supportk, alpha, ringp, bglum, indcst, noisestd, control, realcontour, fixpt, freq, sindeg, phz )% MKFATTHINMAT  Make matrix showing a fat/thin Kanisza figure%% fmat = mkfatthinmat( n, radiusP, supportk, alpha, ringp, bglum, indcst, noisestd, control, realcontour, fixpt )% 02-Jun-99 -- created (RFM)% 22-Sep-99 -- <realcontour> parameter added (RFM)% set default argumentsdefarg('n',256);defarg('radiusP',40);defarg('supportk',0.25);defarg('alpha',15);defarg('ringp',0);defarg('bglum',1.0);defarg('indcst',1.0);defarg('noisestd',0);defarg('control',0);defarg('realcontour',0);defarg('fixpt',0);defarg('freq',8);defarg('sindeg',45);defarg('phz',0);defarg('blur',1);blurfreq = n/10;octaves = 1.5;% determine offset of centre pixel of inducers from centre of imageindoff=round(0.5*radiusP/supportk);midn=floor(n/2);figRect=[ midn-(indoff-1) midn-(indoff-1) midn+indoff midn+indoff ]; % check sizeif figRect(1)-radiusP<=0,	error('Requested matrix size is too small to contain the image');end% get top-left inducer[kmat,kmatcirc]=kanindgrating(radiusP,alpha,ringp);indRect=radiusP*[ -1 -1 1 1 ];% initialize matrixfmat=zeros(n,n);circmat=ones(n,n);% place top-left inducerindOff=figRect([ 1 2 ]);dstRect=[ indOff indOff ]+indRect;fmat(dstRect(2):dstRect(4),dstRect(1):dstRect(3))=kmat;circmat(dstRect(2):dstRect(4),dstRect(1):dstRect(3))=kmatcirc;% place top-right inducerindOff=figRect([ 3 2 ]);dstRect=[ indOff indOff ]+indRect;if control,	fmat(dstRect(2):dstRect(4),dstRect(1):dstRect(3))=kmat;	circmat(dstRect(2):dstRect(4),dstRect(1):dstRect(3))=kmatcirc;else	fmat(dstRect(2):dstRect(4),dstRect(1):dstRect(3))=fliplr(kmat);	circmat(dstRect(2):dstRect(4),dstRect(1):dstRect(3))=fliplr(kmatcirc);end% place bottom-left inducerindOff=figRect([ 1 4 ]);dstRect=[ indOff indOff ]+indRect;if control,	fmat(dstRect(2):dstRect(4),dstRect(1):dstRect(3))=kmat;	circmat(dstRect(2):dstRect(4),dstRect(1):dstRect(3))=kmatcirc;else	fmat(dstRect(2):dstRect(4),dstRect(1):dstRect(3))=flipud(kmat);	circmat(dstRect(2):dstRect(4),dstRect(1):dstRect(3))=flipud(kmatcirc);end% place bottom-right inducerindOff=figRect([ 3 4 ]);dstRect=[ indOff indOff ]+indRect;if control,	fmat(dstRect(2):dstRect(4),dstRect(1):dstRect(3))=kmat;	circmat(dstRect(2):dstRect(4),dstRect(1):dstRect(3))=kmatcirc;else	fmat(dstRect(2):dstRect(4),dstRect(1):dstRect(3))=fliplr(flipud(kmat));	circmat(dstRect(2):dstRect(4),dstRect(1):dstRect(3))=fliplr(flipud(kmatcirc));end% locations to be filled by gratingsinimage = scalearb(dosine(freq,n,sindeg,phz),0,1);%sinimage = scale([sinimage+dosine(freq,n,-sindeg,0)]);% replace wedges with zerosreplocs=find(circmat~=0);fmat(replocs) = sinimage(replocs);% draw real contoursif realcontour,		R=radiusP;	L=indoff-0.5;		a=dtan(alpha)/(2*(R*dcos(alpha)-L));	b=L+R*dsin(alpha)-0.5*dtan(alpha)*(R*dcos(alpha)-L);		j=floor((midn+0.5)-L+R*dcos(alpha)):ceil((midn+0.5)+L-R*dcos(alpha));	di=-(a*(j-(midn+0.5)).^2+b)-1;	for k=1:size(j,2),		m=(midn+0.5)+di(k);		rm=round(m);		for d=-2:2,			fmat(rm+d,j(k))=max(fmat(rm+d,j(k)),trap((rm+d)-m));		end				m=(midn+0.5)-di(k);		rm=round(m);		for d=-2:2,			fmat(rm+d,j(k))=max(fmat(rm+d,j(k)),trap((rm+d)-m));		end			end		a=dtan(-alpha)/(2*(R*dcos(-alpha)-L));	b=L+R*dsin(-alpha)-0.5*dtan(-alpha)*(R*dcos(-alpha)-L);		j=floor((midn+0.5)-L+R*dcos(-alpha)):ceil((midn+0.5)+L-R*dcos(-alpha));	di=-(a*(j-(midn+0.5)).^2+b)-1;	for k=1:size(j,2),				m=(midn+0.5)+di(k);		rm=round(m);		for d=-2:2,			fmat(j(k),rm+d)=max(fmat(j(k),rm+d),trap((rm+d)-m));		end				m=(midn+0.5)-di(k);		rm=round(m);		for d=-2:2,			fmat(j(k),rm+d)=max(fmat(j(k),rm+d),trap((rm+d)-m));		end			endend% blur the imageif blur,	ftmat = fft2(fmat);	%filt=makeidealfilt(n,0,30,1);	filt=makeGaussfilt(n,blurfreq,octaves,'l',1);	fmat=real(ifft2(fftunshift(filt).*ftmat));end% draw fixation pointif fixpt,	fmat(midn:midn+1,midn:midn+1)=1;end% convert to luminancefmat=bglum*(1+indcst*fmat);% add noiseif noisestd>0,	fmat=fmat+random('norm',0,bglum*noisestd,size(fmat));endreturnfunction y=trap(x)x1=0.5;x2=1.5;y=min(max( 1-(abs(x)-x1)/(x2-x1) ,0),1);return