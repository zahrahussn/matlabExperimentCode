% trialsparams.m% Initializes the parameters used in the trial/learning experiment. It is called by trialslab.m%% global WAITBLKTYPE OFFBLKTYPE STIMBLKTYPE;defarg('exptname','learning_trials');	% the name of the experimentmainscrs=0; % this is the screen upon which the image is to be displayed.swidth=1024; sheight=768; pixelsize=8; hz=85;% should be the same as settings during calibration; should be stored with calibration file, but currently are notres=nearestresolution(mainscrs,swidth,sheight,hz,pixelsize);scrinfo=screen(mainscrs,'resolution',res);displayrate=framerate(mainscrs); % frame-rate of the monitor in Hertzdefarg('calfile','Billie1024x768_256col.DDF');	% the name of the calibration file% file & directory names namesdefarg('trialsTEXTfolder',['trialsTEXTfiles']);	% N.B. make sure this folder exists within the folder containing 'trialslab'!defarg('trialsMATfolder',['trialsMATfiles']);		% N.B. make sure this folder exists within the folder containing 'trialslab'!% set the pathsdisp('setting path names...');mfilename='trialsparams'; mainfile = [mfilename,'.m'];eval(['mainpath=which(',quotestring(mainfile),');']);mainpath = mainpath(1:end-length(mainfile));textdatadir=[mainpath,trialsTEXTfolder,':'];matdatadir=[mainpath,trialsMATfolder,':'];cd(mainpath);% stimulus dimensionsdefarg('vd',114);			% viewing distance in cm; not used in current program except as a reminder to the experimenterdefarg('stimpix',256);		% size of stimulus in pixels load images;				% load set of 10 images into memory% 	fieldnames(images)% 	ans = % 	    'andrea'% 	    'dave'% 	    'esther'% 	    'nicole'% 	    'paul'% 	    'richard'% 	    'rob'% 	    'sharon'% 	    'steve'% 	    'tracy'facenames={'esther';'dave';'sharon';'paul';'andrea';'richard';'tracy';'steve';'nicole';'rob'};[numfaces,kk]=size(facenames);for kk=1:numfaces	facestim(kk).face=eval(['images.',char(facenames(kk))]);end;% facestim.face=images.esther;% facestim(2).face=images.dave;% facestim(3).face=images.sharon;% facestim(4).face=images.paul;% facestim(5).face=images.andrea;% facestim(6).face=images.richard;% facestim(7).face=images.tracy;% facestim(8).face=images.steve;% facestim(9).face=images.nicole;% facestim(10).face=images.rob;% normalize all faces to a variance of 1for kk=1:numfaces	facestim(kk).face=facestim(kk).face*sqrt(1/var(facestim(kk).face(:)));end;% create thumbnail images for response windowfor kk=1:numfaces	thumbnail(kk).face=imscale(imresize(facestim(kk).face,0.36,'nearest'));	thumbnail(kk).face=thumbnail(kk).face-mean(thumbnail(kk).face(:));	thumbnail(kk).face=round(160*(1+0.5*thumbnail(kk).face));end;% parameters for fitting weibulls and calculating thresholdpsygamma=1/numfaces; % should be set to 1/N, where N is the number of stimulus alternatives (i.e., guessing rate)psydelta=0.01;psybeta=1.5;thresholdlevel=0.5;mintrialforthreshold=20; % min number of thresholds needed to make an attempt to fit a psychometric function to a data set; the data is still stored in a file% external noise variancesnv=[0.001,0.01,0.1];				% external noise variances (low, medium, & high)numnz=length(nv);	% number of external noises% parameters for method of constant stimulidefarg('numvalues',1); % # of stimulus levels (i.e., contrast variance) used in each conditiondefarg('trialspervalue',[1]); % # of trials per contrast leveldefarg('stepsperlogunit',10);% defarg('thresholdguess',[0.00001,0.0015,0.003]);defarg('thresholdguess',3*nv/40); % these seem to be about rightfor kk=1:numnz	tmp=thresholdguess(kk)/sqrt(10);	values(kk,:)=logspace(log10(tmp),log10(10*tmp),numvalues); % set (n=numvalues) of log-spaced values centered on thresholdguess	constimrec(kk)=constimInit(values(kk,:),trialspervalue(1)); % init the constantstimulus struct	constimrec(kk).appspec=nv(kk);	% attached noise variance to app-specific fieldend;% stimulus timing parametersdefarg('duration',0.2);	% stimulus duration in secondsdefarg('fixpntstimoffset',0.2); % time between fixation point offset and stimulus onset in secondsdefarg('intertrial',1);	% inter-trial interval in seconds; meaninful only when usespace=0 (see next line)defarg('usespace',0);	% when zero, trials are started automatically; when 1, trials started by clicking mouse near fixation pointdefarg('adaptseconds',60); % light adaptation time% put all of these things into a structureexptdesign.duration=duration; % stimulus duration (sec)exptdesign.fixpntstimoffset=fixpntstimoffset; % time between fixation point offset and stimulus onset in secondsexptdesign.intertrial=intertrial; % inter-trial duration (sec)exptdesign.usespace=usespace; % use space bar to start each trial?exptdesign.adaptseconds=adaptseconds; % light adaptation time (sec)exptdesign.numfaces=numfaces;exptdesign.numnz=numnz;exptdesign.viewingdistcm=vd;% subject informationdefarg('distanceFromFixPnt',16);	% # of pixels from fixation point that the mouse must be clicked to start a trial; valid only when 'usespace' is 1defarg('groupID',-1);	% identifies group 1..4, -1=not setcd(mainpath); load nextidnum; defarg('sidnum',num2str(nextidnum)); nextidnum=nextidnum+1; save ('nextidnum','nextidnum'); clear nextidnum;defarg('sgender',[]);defarg('sage',-1);defarg('scomment',[]);