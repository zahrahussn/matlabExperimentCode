% orientationparams.m% Initializes the parameters used in the orientation/learning experiment. It is called by orientationlab.m%% global WAITBLKTYPE OFFBLKTYPE STIMBLKTYPE;exptname='orientation';	% the name of the experimentmainscrs=0; % this is the screen upon which the image is to be displayed.swidth=1024; sheight=768; pixelsize=8; hz=85; % should be the same as settings during calibration; should be stored with calibration file, but currently are notres=nearestresolution(mainscrs,swidth,sheight,hz,pixelsize);scrinfo=screen(mainscrs,'resolution',res);displayrate=framerate(mainscrs); % frame-rate of the monitor in Hertzcalfile='Cobain1024x768_256col.DDF';	% the name of the calibration file% file & directory names namesdefarg('orientTEXTfolder',['orientTEXTfiles']);	% N.B. make sure this folder exists within the folder containing 'orientationlab'!defarg('orientMATfolder',['orientMATfiles']);		% N.B. make sure this folder exists within the folder containing 'orientationlab'!% set the pathsdisp('setting path names...');mfilename='orientationparams'; mainfile = [mfilename,'.m'];eval(['mainpath=which(',quotestring(mainfile),');']);mainpath = mainpath(1:end-length(mainfile));textdatadir=[mainpath,orientTEXTfolder,':'];matdatadir=[mainpath,orientMATfolder,':'];cd(mainpath);% stimulus dimensionsvd=57;		% viewing distance in cm; not used in current program except as a reminder to the experimenterstimpix=64;	% size of stimulus in pixelslowf=3; % lowest frequency (cy/image) in the stimulihighf=6; % highest frequency (cy/image) in the stimuliotarget=[-10,10]; % prior to rotation, stimulus contains orientations from -10 to 10 deg (0 deg is horizontal)	odelta=[0, 12, -12]; % rotations in deg; the first element in array is the targetload nzstim;	% load set of amplitude and phase spectra of noise image (should be same dimensions as stimpix)amp=nzstim.amp; phz=nzstim.phz;basepatternfft=amp.*exp(i*phz); % combine amp & phase spectrabasepattern=real(ifft2(basepatternfft));	% calculate the inverse FFT;fq=bpfilter((lowf-1),(highf+1),stimpix); of=ofilter(otarget(1),otarget(2),stimpix); filt=fq.*of; % construct 2D Fourier filterbasepattern=bpimage(basepattern,filt,0);basepattern=bpimage(basepattern,filt,0);if (odelta(1)~=0)	target=imrotate(basepattern,odelta(1),'bilinear','crop');else	target=basepattern;end;distractorA=imrotate(target,odelta(2),'bilinear','crop');distractorB=imrotate(target,odelta(3),'bilinear','crop');spot=pbspot(round(stimpix/2),stimpix); % create circular windownzpattern.target=target.*spot; % vignette patterns with circular windownzpattern.distractorA=distractorA.*spot; % vignette patterns with circular windownzpattern.distractorB=distractorB.*spot; % vignette patterns with circular windowclear amp phz nzstim targetfft fq of filt spot target distractorA distractorA; % clean up the mess% parameters for fitting weibulls and calculating threshold psygamma=0.5; % should be set to 1/N, where N is the number of stimulus alternatives (i.e., guessing rate) psydelta=0.01; psybeta=1.5; thresholdlevel=0.5; mintrialforthreshold=20; % min number of thresholds needed to make an attempt to fit a psychometric function to a data set; the data is still stored in a file% external noise variancesnv=[0,0.002,0.02,0.1];	% external noise variances (low, medium, & high)numnz=length(nv);		% number of external noises% set up locations for stimulicuedsetsize=1;stimeccentricity=[128,128,128,128];	% stimulus eccentricity, in pixels, from fixation pnt to center of patterntarglocsdeg=[30,120,210,300];	% target directions;numlocs=length(targlocsdeg);% parameters for method of constant stimulinumvalues=7; % # of stimulus levels (i.e., contrast variance) used in each conditiontrialspervalue=[20]; % # of trials per contrast levelstepsperlogunit=10;%defarg('thresholdguess',[0.0001,0.0005,0.003]);defarg('thresholdguess',nv/40); % these seem to be about right%for jj=1:numlocsfor kk=1:numnz	tmp=thresholdguess(kk)/sqrt(10);	values(kk,:)=logspace(log10(tmp),log10(10*tmp),numvalues); % set (n=numvalues) of log-spaced values centered on thresholdguess	constimrec(kk)=constimInit(values(kk,:),trialspervalue(1)); % init the constantstimulus struct	constimrec(kk).appspec=nv(kk);	% attached noise variance to app-specific fieldend;%end;% set up staircases%maxtrials=100; maxreversals=10; % staircase ends after maxtrials OR maxreversals is reached%minreversals=8; % won't compute average of reversals (for threshold) unless the staircase has at least this number of reversals%minvariance=0.00001;%maxvariance=0.1;%stepsperlogunit=20;%downcount=2;	% 2-down/1-up staircases% thresholdguess=[0.0001,0.0025,0.005];%thresholdguess=0.05*nv;%thresholdguess(1) = thresholdguess(2);%takebreaktrial=601; % software will allow subject to take a break at the beginning of trial 601%variancerange=log10(maxvariance/minvariance);%stimvariance=logspace(log10(minvariance),log10(maxvariance),round(stepsperlogunit*variancerange)); % positive contrast; covers a 4 log unit range; 0.05 log units (12%) per step%firststep=4; % initial staircase step size: move 4 places in the stimvariance array%steparray=[2,1]; % subsequent step sizes%§switchafterRevnum=[2,6]; % change step size after reversals 2 and 4%for jj=1:numlocs%	for kk=1:numnz%		screc(jj,kk)=scInit(downcount,stimvariance,thresholdguess(kk),maxtrials,maxreversals); % 2-down/1-up staircase; low noise condition%		screc(jj,kk)=scInitStepSize(screc(jj,kk),firststep,steparray,switchafterRevnum); % set up multiple step sizes%		screc(jj,kk).appspec=nv(kk); % store noise variances with the staircase data structures%	end;%end;	% stimulus timing parameterscueduration=0.25; % duration of location cue in secondscueoffset=0.5; % duration between cue offset and stimulus onset in secondsduration=0.1;	% stimulus duration in secondsisi=0.5;	% stimulus duration in secondsintertrial=1.25;	% inter-trial interval in seconds; meaninful only when usespace=0 (see next line)usespace=0;	% when zero, trials are started automatically; when 1, trials started by clicking mouse near fixation pointadaptseconds=60; % light adaptation time% put all of these things into a structureexptdesign.cueduration=cueduration;exptdesign.cueoffset=cueoffset;exptdesign.duration=duration; % stimulus duration (sec)exptdesign.isi=isi; % isi (sec)exptdesign.intertrial=intertrial; % inter-trial duration (sec)exptdesign.usespace=usespace; % use space bar to start each trial?exptdesign.adaptseconds=adaptseconds; % light adaptation time (sec)exptdesign.numnz=numnz;exptdesign.numlocs=numlocs;exptdesign.cuedsetsize=cuedsetsize;exptdesign.stimeccentricity=stimeccentricity;exptdesign.targlocsdeg=targlocsdeg;exptdesign.viewingdistcm=vd;exptdesign.takebreaktrial=takebreaktrial;exptdesign.minreversals=minreversals;exptdesign.distanceFromFixPnt=16;	% # of pixels from fixation point that the mouse must be clicked to start a trial; valid only when 'usespace' is 1% subject informationgroupID=1;	% identifies group 1..4, -1=not setcd(mainpath); load nextidnum; defarg('sidnum',num2str(nextidnum)); nextidnum=nextidnum+1; save ('nextidnum','nextidnum'); clear nextidnum;sgender=[];sage=[];scomment=[];