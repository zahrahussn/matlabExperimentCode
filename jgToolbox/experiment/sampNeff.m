function sampNeff(name,stimtype,numstim,mainscrs,maxtrials,samplevels,approxthresh)% function sampNeff(name,stimtype,numstim,mainscrs,maxtrials,samplevels,approxthresh)%% finds thresholds in the sub-sample experiment% uses method of constant stimuli% 'name' is the name the subject, in intials% 'stimtype' is the type of stimulus to be shown% ('f'=faces; 'l'=letters; 'g' = gratings) % default screen is 1. default number of trials is 40.%% Sept 18 1998  JMG  U of Toronto Vision Lab% the name of the file containing the initial thresholdif nargin > 2	% change directories to the main folder	cf;	jg feature;			% defaults	defarg('mainscrs',1);	defarg('maxtrials',40);	defarg('samprange',[.001 1]);		% estimate of lowest threshold	if strcmp(lower(stimtype(1)),'f')		defarg('approxthresh',7.5e-4);	else		defarg('approxthresh',2.5e-4);	end		logrange = 2;	% error checking	if length(approxthresh) < numsamplevels		printstr('number of sample levels and threshold estimates do not match.');		break;	end	% constants	fileshareoff = 1;	calfile = 'AppleA.DDF';	duration = .5;	nzcn = .25;	nzvar = nzcn^2;	darktime = 120;	vd = 100;	% parameters for grating identification	gaborsz = 256;	iscompound = 0;	freq1 = 2;	freq2 = 3*freq1;	phz1 = 0;	phz2 = 0;	deg1 = 0;	deg2 = 0;			% make sounds	introsnd=makesnd(140,.2,.5);	corrsnd=makesnd(400,.09,.5);	wrongsnd=makesnd(200,.09,.5);	% open the screens	tempCLUT=ones(256,3)*160;	tempCLUT(2,:)=[1 1 1];	[screens,rects] = openscreens(mainscrs,tempCLUT);	[oldfont,oldsz,oldstyle] = settext(screens(1),'Times',26,1);	% load the stimuli & calibration files	[newx,newy] = centertext(screens(1),rects(1,:),'Pause For Adaptation'); tic;	% get the calibration data	[cal1] = getddf(calfile);	% hide the cursor;	hidecursor;	% load the stimulus file. stimuli are stored in the structure 'images'.	% the ideal template is stored as 'template' and the names are stored in	% the cell array 'names'	if lower(stimtype(1)) == 'l'		load('LetterStruct');		load(['Letterideal',num2str(numstim)]);	elseif lower(stimtype(1)) == 'f'		load('FaceStruct');		load(['Faceideal',num2str(numstim)]);	else		if iscompound			names = {'g1','g2'};			images.g1 = dosinimage(freq1,gaborsz)+dosinimage(freq2,gaborsz,deg1,phz1);			images.g2 = dosinimage(freq1,gaborsz)+dosinimage(freq2,gaborsz,deg2,phz2);		else			images.g1 = dosinimage(freq1,gaborsz,deg1,phz1);			images.g2 = dosinimage(freq2,gaborsz,deg2,phz2);			names = {'g1','g2'};		end		template = images.g1-images.g2;			end	numstim = length(names);	eval(['imagesz = size(images.',names{1},');']);	nzsz = imagesz;	% the variance of all images is the same	eval(['basevar = std(images.',names{1},'(:))^2;']);	% make file names	filename = [name,'sampNeff',upper(stimtype(1)),num2str(numstim),'.dat'];	% stimulus and sample levels	numstimlevels = 6;	if ~exist('samplevels','var')		numsamplevels = 7;	else		numsamplevels = length(samplevels);	end	% the stimulus levels to test (% of informative pixels)	if ~exist('samplevels','var')		samplevels = logspace(log10(samprange(1)),log10(samprange(2)),numsamplevels);		end	% the stimulus levels to test	for i=1:numsamplevels		stimlevels(:,i) = logspace(log10(approxthresh(i)./10^(logrange/2)),log10(approxthresh(i).*10^(logrange/2)),numstimlevels)';	end		% the ideal image templates	samplestruct = struct('template1',1);	for i =1:length(samplevels)		eval(['samplestruct.template',num2str(i),' = threshimage(template,',num2str(samplevels(i)),');']);	end	% make the selection window 	coords = getcoords(100,numstim,rects,20);	select = mkselectwin(coords,100/imagesz(1),rects,images,names);	[select,selectclut] = makeimage(select,cal1);		% open the data file and write the header	if exist(filename) ~= 2		fwid = fopen(filename,'a+');					savecomment(fwid,['Data File Name: ',filename]);		savecomment(fwid,'sampleNeff experiment');		savecomment(fwid,['calibration file: ',calfile]);		savecomment(fwid,['image names: ',strcat(names{1:end})]);		savecommand(fwid,['viewingdistance = ',num2str(vd),'; resolution = [',num2str(rects(1,3)),',',num2str(rects(4)),']; gam = ',num2str(1/numstim),';']);		savecommand(fwid,['stimtype = 'quotestring(stimtype),'; duration = ',num2str(duration),'; darktime = ',num2str(darktime),'; noisevar = ',num2str(nzvar),';trials = ',num2str(maxtrials),';']);		savecommand(fwid,'trial = 1; sequence = 2; response = 3; correct = 4; stimlevel = 5; condition = 6; randnstate1 = 7; randnstate2 = 8;');		savedatetime(fwid);	else		fwid = fopen(filename,'a+');					savedatetime(fwid);	end	% turn off filesharing	if fileshareoff		status=fs('Off');	end		% continue dark adptation	hidecursor;	done=toc;	togo=darktime-done;	passed=0;	start=GetSecs;	hit='9';	while getsecs-start < togo & abs(hit)~=48  	% zero key skips adaptation		if CharAvail			hit=getchar;		end	end		% keypress to continue	screen(screens(1),'FillRect',0);	flushevents('mouseUp','mouseDown');	sound(introsnd);	screen(screens(1),'SetClut',selectclut,0);	screen(screens(1),'PutImage',select);	[newx,newy] = centertext(screens(1),rects(1,:),'Click Mouse To Start');	[clicks,x,y] = getclicks;	screen(screens(1),'FillRect',0);	% initialize	sequence = rands([1:numstim],[1,maxtrials*numstimlevels*numsamplevels]);	responses = zeros(size(sequence));	trialstring = '';	for i = 1:numsamplevels		eval(['trialsrc',num2str(i),' = mkconstim(stimlevels(:,',num2str(i),'),inf,',num2str(i),');']);		trialstring = [trialstring,'trialsrc',num2str(i),','];	end	eval(['trialsrc = mktslist(',trialstring(1:end-1),');']);		% main loop	totaltrials = maxtrials*numstimlevels*numsamplevels;	pausetrials = round(totaltrials/4);	for trial = 1:totaltrials  				% get the next stimulus level		[trialsrc,conlevel,id] = gettrial(trialsrc);		% if criterion sd has been met break the loop				if isnan(conlevel)			break;		end		% make the image		% the contrast variance of the unsampled image is set, then		% the image is sampled.		randnstate = randn('state');		nz=cliprandn(nzsz,2);		nz=nz*sqrt(nzvar/std(nz(:))^2);		eval(['currimage = images.',names{sequence(trial)},'.*sqrt(conlevel/basevar);']);		eval(['currimage = currimage.*samplestruct.template',num2str(id),';']);						% add noise and make the final image		currimage = currimage+nz;		[currimage,CLUT]=makeimage(currimage,cal1);				% wait for mouse click		[clicks,x,y] = getclicks(screens(1));				% if the user double clicked, show the # of remaining trials		% wait for another click to proceed with next trial		if clicks > 1			screen(screens(1),'SetClut',selectclut,0);			[newx,newy] = centertext(screens(1),rects(1,:),num2str(totaltrials-trial),[],210);			[clicks,x,y] = getclicks(screens(1));			screen(screens(1),'FillRect',0);			waitsecs(.5);		end				% present the image		screen(screens(1),'SetClut',CLUT,0);		screen(screens(1),'PutImage',currimage);		waitsecs(duration);		screen(screens(1),'FillRect',0);				% present the selection window		screen(screens(1),'SetClut',selectclut,0);		screen(screens(1),'PutImage',select);				% get the response		responses(trial) = selectimage(coords,[0,0,10,10],screens(1));		screen(screens(1),'FillRect',0);		% quit?		if responses(trial) < 1			break;		end				% accuracy		correct=sequence(trial)==responses(trial);		if correct			sound(corrsnd);		else			sound(wrongsnd);		end				% save the data		data=[trialsrc.trial,sequence(trial),responses(trial),correct,conlevel,samplevels(id),randnstate(1),randnstate(2)];		fprintf(fwid,'%g\t',data); 		fprintf(fwid,'\n');		% update trial source		trialsrc = telltrial(trialsrc,conlevel,correct);		% pause for a break		if rem(trial,pausetrials) == 0 & trial<totaltrials			[newx,newy] = centertext(screens(1),rects(1,:),['Take a break. ',num2str(totaltrials-trial),' trials remaining.'],round(rects(1,4)*.4),210);			[newx,newy] = centertext(screens(1),rects(1,:),['Click the Mouse to Continue.'],round(rects(1,4)*.6),210);			[clicks,x,y] = getclicks(screens(1));			screen(screens(1),'FillRect',0);		end				end	% close the screen.	sound(introsnd);	screen CloseAll;	% close the file	fclose(fwid);		% turn on filesharing	if fileshareoff		status=fs('On');	end	else		printstr('Not enough input arguments.')endreturn