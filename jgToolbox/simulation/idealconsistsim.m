function idealconsistsim(stimtype,maxtrials,numits,extnoiselevel,intnoiselevel,approxthresh,numstimlevels,logrange)% function idealconsistsim(stimtype,maxtrials,numits,extnoiselevel,intnoiselevel,approxthresh,numstimlevels,logrange)%% finds thresholds in the noise masking experiment% uses method of constant stimuli% 'name' is the name the subject, in intials% 'stimtype' is the type of stimulus to be shown% ('f'=faces; 'l'=letters; 'g' = gratings) % default screen is 1. default number of trials is 40.%% Sept 18 1998  JMG  U of Toronto Vision Lab% the name of the file containing the initial thresholdif nargin > 1	% change directories to the main folder	cf;	jg feature;			% defaults	defarg('maxtrials',35);	defarg('numsessions',2);	defarg('numstimlevels',10);	defarg('logrange',2);	defarg('numits',1000);		% internal noise default is extnoiselevel	defarg('intnoiselevel',extnoiselevel);	loglin = inline('k*(log10(x./100)) + 100','k','x');		% constants	fileshareoff = 1;	% parameters for grating identification	vd = 100;	screensz = [23.5 17.5];	res = [640  480];	hdisdeg = 2.3;	vdisdeg = 1.54;	hdiscm = vd*tan(deg2rad(hdisdeg));	vdiscm = vd*tan(deg2rad(vdisdeg));	hdis = round(cm2pix(hdiscm,screensz,res));	vdis = round(cm2pix(vdiscm,screensz,res));	cpd = 2.3;	gaborszdeg = 1.54;	gaborszcm = vd*tan(deg2rad(gaborszdeg));		gaborsz = round(cm2pix(gaborszcm,screensz,res));	freq = cpd2cpi(cpd,gaborszcm,vd);	phz = 0;	deg1 = 12;	deg2 = -12;	cpw = 3;	% get the fitting data for the ie-slope relationship.	% header:	% *dblexp = inline('k0 + k1*exp(-k2*ie) + k3*exp(-k4*ie)','k0','k1','k2','k3','k4','ie');	% *ie2mparams = [93.625 123.676 0.782677 352.647 6.48979];	% *m2ieparams = [0.114477 4.07001 0.013366 75.9068 0.0358296];	% *ie = 1; m = 2; mSE = 3;	idealdata = readdata('idealieslope.dat');		% tags for consistency	trialtag = 1;	sequence = 2; 	response = 3; 	correcttag = 4; 	stimlevel = 5; 	extnoise = 6;	condition = 7; 	% load the stimulus file. stimuli are stored in the structure 'images'.	if lower(stimtype) == 'l2'		load('LetterStruct2');	elseif lower(stimtype) == 'l'		load('LetterStruct');	elseif lower(stimtype) == 'p'		load('LetterStruct3');	elseif lower(stimtype) == 'f'		load('FaceStruct');	elseif lower(stimtype) == 'h'		load('HebrewStruct');	elseif lower(stimtype) == 't'		load('TPStruct');	elseif lower(stimtype) == 'n'		load('NoiseStruct');	else		images.g1 = dogabor(freq,cpw,gaborsz,deg1,phz);		images.g2 = dogabor(freq,cpw,gaborsz,deg2,phz);		names = {'g1','g2'};	end	names = fieldnames(images);	numstim = length(names);	eval(['imagesz = size(images.',names{1},');']);	nzsz = imagesz;	% low-pass letter condition	if lower(stimtype) == 'p'		filt = fftunshift(makeidealfilt(imagesz(1),0,2,0));		basevar = .1;		for i = 1:numstim			eval(['images.',names{i},' = real(ifft2(fft2(images.',names{i},').*filt));']);			eval(['images.',names{i},' = images.',names{i},'*sqrt(basevar/stdm(images.',names{i},')^2);']);					end	end		% the variance of all images is the same	eval(['basevar = std(images.',names{1},'(:))^2;']);		% make file names	found = 0;	loc = 1;	while ~found		filename = ['ideal',num2str(loc),'consim',upper(stimtype),num2str(numstim),'.dat'];		if ~(exist(filename)==2)			found = 1;		else			loc = loc+1;		end	end		% the stimulus levels to test	stimlevels = logspace(log10(approxthresh./10^(logrange/2)),log10(approxthresh.*10^(logrange/2)),numstimlevels)';		% open the data file and write the header	if exist(filename) ~= 2		fwid = fopen(filename,'a+');					savecomment(fwid,['Data File Name: ',filename]);		savecomment(fwid,'consistency simulation');		savecomment(fwid,['image names: ',strcat(names{1:end})]);		if strcmp(lower(stimtype),'g')			savecommand(fwid,['orientations = [',num2str([deg1 deg2]),'];']);			savecommand(fwid,['cpi = ',num2str(freq),'; cpw = ',num2str(cpw),'; phase = ',num2str(phz),';']);		end		savecommand(fwid,['gam = ',num2str(1/numstim),'; extnoiselevel = [',num2str(extnoiselevel),']; intnoiselevel = [',num2str(intnoiselevel),'];']);		savecommand(fwid,['stimtype = 'quotestring(stimtype),';maxtrials = ',num2str(maxtrials),'; numits = ',num2str(numits),';']);		savecommand(fwid,'slope = 1; ie = 2;');		savedatetime(fwid);	else		fwid = fopen(filename,'a+');					savedatetime(fwid);	end	% turn off filesharing	if fileshareoff		status=fs('Off');	end	% to hold the slope estimates	slopes = zeros(size(numits,1));	ies = zeros(size(numits,1));	for it = 1:numits		% initialize		sequence = rands([1:numstim],[1,maxtrials*numstimlevels]);		conlevel = zeros(size(sequence));			% for the responses		responses = zeros([length(sequence),numsessions]);		correct = responses;		totaltrials = maxtrials*numstimlevels*numsessions;		data1 = [];		data2 = [];		for session = 1:numsessions					% to store the random number seeds and make the trial source			if session == 1				seeds = {};				trialsrc = mkconstim(stimlevels,inf,1);			end					% main loop			for trial = 1:totaltrials/numsessions  						if session == 1					% get the next stimulus level					[trialsrc,conlevel(trial)] = gettrial(trialsrc);				end							% make the image				if session == 1					seeds{trial} = randn('state');				else					randn('state',seeds{trial});				end										% if the flag sacelwithstim is set (1), include the stimulus variance				% with the variance of the noise. otherwise, just set the noise variance				% alone.				nz=randn(nzsz);				nzvar = extnoiselevel + conlevel(trial);						nz=nz*sqrt(nzvar/std(nz(:))^2);								% internal noise				randn('state',sum(100*clock));				intnz = randn(nzsz);				intnz = intnz*sqrt(intnoiselevel/std(intnz(:))^2);				eval(['currimage = images.',names{sequence(trial)},'.*sqrt(conlevel(trial)/basevar)+nz+intnz;']);							% ideal rule is cross correlation				for i = 1:numstim					eval(['tempresp(i) = sum(sum(currimage.*images.',names{i},'));']);				end					% accuracy				[themax,responses(trial,session)] = max(tempresp);				correct(trial,session)=sequence(trial)==responses(trial,session);				printstr(['trial # ',num2str(trial),'; Variance: ',num2str(conlevel(trial)),'; Correct: ',num2str(correct(trial,session))]); 								% save the data				if session == 1					data1=[data1;[trial,sequence(trial),responses(trial,session),correct(trial,session),conlevel(trial),extnoiselevel,intnoiselevel,(seeds{trial})']];					% update trial source					trialsrc = telltrial(trialsrc,conlevel(trial),correct(trial,session));				else					data2=[data2;[trial,sequence(trial),responses(trial,session),correct(trial,session),conlevel(trial),extnoiselevel,intnoiselevel,(seeds{trial})']];				end			end										end				% consistency			data = [data1;data2];			% separate data		pccorrect = [];		pcagree = [];			pccorrectSE = [];						% e=sqrt(p*(1-p)/n);  standard error		pcagreeSE = [];			% compute percentage agreements		levels = unique(data1(:,stimlevel));		for currlevel = 1:length(levels)			levellocs = find(data1(:,stimlevel)==levels(currlevel));			leveldata1 = data1(levellocs,:);			leveldata2 = data2(levellocs,:);			pccorrect(currlevel) = [((sum(leveldata1(:,correcttag))+sum(leveldata2(:,correcttag)))/(size(leveldata1,1)*2))*100];			pccorrectSE(currlevel) = sqrt(pccorrect(currlevel)*(100-pccorrect(currlevel))/(size(leveldata1,1)*2));			pcagree(currlevel) = [(sum(leveldata1(:,response)==leveldata2(:,response))/size(leveldata1,1))*100];			pcagreeSE(currlevel) = sqrt(pcagree(currlevel)*(100-pcagree(currlevel))/size(leveldata1,1));		end			% fit data		data = [pcagree',pccorrect',pccorrectSE'];				% outliers		for i = 1:length(levels)			if data(i,3) == 0				data(i,3) = mean(data(:,3));			end			if data(i,1) < 1				data(i,1) = 1;			end				end		slopes(it) = loglinfitfn(data,100,'ss');		ies(it) = dblexp(m2ieparams(1),m2ieparams(2),m2ieparams(3),m2ieparams(4),m2ieparams(5),slopes(it));		printstr(['slope (#',num2str(it),') = ',num2str(slopes(it)),'; i/e = ',num2str(ies(it))]);		fprintf(fwid,'%g\t',[slopes(it),ies(it)]); 		fprintf(fwid,'\n');		pccorrectfit = loglin(slopes(it),data(:,1));				% plot psychophysical function		if ishold			handle = semilogx(data(:,1),data(:,2),'r*',data(:,1),pccorrectfit,'b-');		else			handle = semilogx(data(:,1),data(:,2),'r*',data(:,1),pccorrectfit,'b-');			xlabel('Percent Agreement');			ylabel('Percent Correct');			title('PCAgree Plot');			hold on;		end		drawnow;						end	% save slope and standard deviation estimates	savecommand(fwid,['minslope = ',num2str(min(slopes)),';']);	savecommand(fwid,['maxslope = ',num2str(max(slopes)),';']);	savecommand(fwid,['meanslope = ',num2str(mean(slopes)),';']);	savecommand(fwid,['stdslope = ',num2str(std(slopes)),';']);	savecommand(fwid,['minie = ',num2str(min(ies)),';']);	savecommand(fwid,['maxie  = ',num2str(max(ies)),';']);	savecommand(fwid,['meanie  = ',num2str(mean(ies)),';']);	savecommand(fwid,['stdie  = ',num2str(std(ies)),';']);	% close the file	fclose(fwid);		else		printstr('Not enough input arguments.')endreturn