	%detection contrasts	thresholdguess=[.00002];	tmp=thresholdguess;	highval=log10(tmp)+log10(sqrt(50)); %changed from sqrt(15) to sqrt(45) to obtain larger range for detection task; zh, 2009	lowval=log10(tmp)-log10(sqrt(15));	detectvalues=logspace(lowval,highval,7) % set (n=numvalues) of log-spaced values centered on thresholdguess			% identification contrasts	thresholdguess2=0.0008; % med noise	%thresholdguess2=0.0075; % high noise	tmp2=thresholdguess2;	highval=log10(tmp2)+log10(sqrt(15));	lowval=log10(tmp2)-log10(sqrt(15));	idvalues=logspace(lowval,highval,7) %		detectvalues./idvalues	sqrt(detectvalues)./sqrt(idvalues)	% 	for kk=1:3% 	thresholdguess=[3*0.0001, 0.0008, 0.0075];% 	tmp=thresholdguess(kk);% 	highval=log10(tmp)+log10(sqrt(15));% 	lowval=log10(tmp)-log10(sqrt(15));% 	values(kk,:)=logspace(lowval,highval,7);% end% values