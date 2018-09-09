load images;defarg('stimpix',256);		% size of stimulus in pixelsfacenames={'esther';'dave';'sharon';'paul';'andrea';'richard';'tracy';'steve';'nicole';'rob'};[numfaces,kk]=size(facenames);for kk=1:numfaces	facestim(kk).face=eval(['images.',char(facenames(kk))]);end;% normalize all faces to a variance of 1for kk=1:numfaces	facestim(kk).face=facestim(kk).face*sqrt(1/var(facestim(kk).face(:)));end;% external noise variancesnv=[0.001,0.01,0.1];				% external noise variances (low, medium, & high)numnz=length(nv);	% number of external noisesdefarg('numvalues',7); % # of stimulus levels (i.e., contrast variance) used in each conditiondefarg('thresholdguess',3*nv/40); % these seem to be about rightfor kk=1:numnz	tmp=thresholdguess(kk)/sqrt(10);	values(kk,:)=logspace(log10(tmp),log10(10*tmp),numvalues); % set (n=numvalues) of log-spaced values centered on thresholdguess	constimrec(kk)=constimInit(values(kk,:),1); % init the constantstimulus struct	constimrec(kk).appspec=nv(kk);	% attached noise variance to app-specific fieldend;for kk=1:numfaces	for nn=1:numnz		%for vv=1:numvalues	nzvar=constimrec(nn).appspec;	% noise variance	[stim,nzseed]=noise2d(stimpix,nzvar,-1,1,0);	curStimVariance=constimGetValue(constimrec(nn)); % get the stimulus variance for the current method-of-constant-stimuli record	tmpface=facestim(kk).face*sqrt(curStimVariance); % this formula works because the faces have a variance of 1%	stim=stim+tmpface;%	figure%	imshow(imscale(stim));%	hold on;%	tilefigsend;end;