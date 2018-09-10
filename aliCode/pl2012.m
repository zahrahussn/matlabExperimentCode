% function pl2012
    % perceptualLearning2012
    % written by AH & JL, June 2012
    % based on ZH & PJB code

    clear all; % clear workspace

    starttime=GetSecs; 
    randn('state',sum(100*clock)); % initialize the random number generator

    %% trialsparamxOSX.m
    % Initializes the parameters used in the trial/learning experiment.
    warning('off','MATLAB:dispatcher:InexactMatch');
    % global WAITBLKTYPE OFFBLKTYPE STIMBLKTYPE;
    %oldEnableFlag=Screen('Preference', 'EmulateOldPTB', 1);

    %disable psychtoolbox test screen
    oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
    oldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1);

    defarg('exptname','learning_trials');	% the name of the experiment
    screenNumbers = Screen('Screens');
    defarg('mainscrs',max(screenNumbers)); % this is the screen upon which the image is to be displayed.
    %swidth=1024; sheight=768; pixelsize=8; hz=85;% should be the same as settings during calibration; should be stored with calibration file, but currently are not
    %res=NearestResolution(mainscrs,swidth,sheight,hz,pixelsize);
    swidth=1680; sheight=1050; pixelsize=8; hz=85;% should be the same as settings during calibration; should be stored with calibration file, but currently are not
    % scrinfo=screen('resolution',0,1680,1050,[],32); % changed Nov 30/09, compatible with OSX nott work computer, ZH
    %scrinfo=screen(mainscrs,'resolution',res);
    % displayrate=framerate(mainscrs); % frame-rate of the monitor in Hertz
    % %NOT WORKING so set displayratebelow:
    displayrate=Screen('FrameRate',mainscrs);

    % file & directory names names
    defarg('trialsTEXTfolder',['trialsTEXTfiles']);	% N.B. make sure this folder exists within the folder containing 'trialslab'!
    defarg('trialsMATfolder',['trialsMATfiles']);		% N.B. make sure this folder exists within the folder containing 'trialslab'!

    % set the paths
    disp('setting path names...');
%     mfilename='trialsparamsOSX'; mainfile = [mfilename,'.m'];
    mfilename='pl2012'; mainfile = [mfilename,'.m'];
    eval(['mainpath=which(',QuoteString(mainfile),');']);
    mainpath = mainpath(1:end-length(mainfile));
    textdatadir=[mainpath,trialsTEXTfolder];
    matdatadir=[mainpath,trialsMATfolder];
    cd(mainpath);
    disp(mainpath);

    % stimulus dimensions
    defarg('vd',88);			% (used to be 114) viewing distance in cm; not used in current program except as a reminder to the experimenter
    defarg('stimpix',256);		% size of stimulus in pixels

    % external noise variances
    nv=[0.001,0.01,0.1];				% external noise variances (low, medium, & high)
    numnz=length(nv);	% number of external noises

    % parameters for method of constant stimuli
    defarg('numvalues',7); % # of stimulus levels (i.e., contrast variance) used in each condition
    numContrast = numvalues;
    defarg('trialspervalue',[1,3,5,40]); % # of trials per contrast level
    defarg('stepsperlogunit',10);
    % defarg('thresholdguess',[0.00001,0.0015,0.003]);
    defarg('thresholdguess',3*nv/40); % these seem to be about right

    for kk=1:numnz
        tmp=thresholdguess(kk)/sqrt(10);
        values(kk,:)=logspace(log10(tmp),log10(10*tmp),numvalues); % set (n=numvalues) of log-spaced values centered on thresholdguess
        constimrec(kk)=constimInit(values(kk,:),trialspervalue(1)); % init the constantstimulus struct
        constimrec(kk).appspec=nv(kk);	% attached noise variance to app-specific field
    end;

    % stimulus timing parameters
    defarg('duration',0.2);	% stimulus duration in seconds
    defarg('fixpntstimoffset',0.2); % time between fixation point offset and stimulus onset in seconds
    defarg('intertrial',1);	% inter-trial interval in seconds; meaninful only when usespace=0 (see next line)
    defarg('usespace',0);	% when zero, trials are started automatically; when 1, trials started by clicking mouse near fixation point
    defarg('adaptseconds',60); % light adaptation time

    % put all of these things into a structure
    exptdesign.duration=duration; % stimulus duration (sec)
    exptdesign.fixpntstimoffset=fixpntstimoffset; % time between fixation point offset and stimulus onset in seconds
    exptdesign.intertrial=intertrial; % inter-trial duration (sec)
    exptdesign.usespace=usespace; % use space bar to start each trial?
    exptdesign.adaptseconds=adaptseconds; % light adaptation time (sec)
    % exptdesign.numfaces=numfaces;



    exptdesign.numnz=numnz;
    exptdesign.viewingdistcm=vd;

    % subject information
    defarg('distanceFromFixPnt',16);	% # of pixels from fixation point that the mouse must be clicked to start a trial; valid only when 'usespace' is 1
    defarg('groupID',-1);	% identifies group 1..4, -1=not set
    % cd(mainpath); load nextidnum; defarg('sidnum',num2str(nextidnum)); nextidnum=nextidnum+1; save ('nextidnum','nextidnum'); clear nextidnum;
    defarg('sgender',[]);
    defarg('sage',-1);
    defarg('scomment',[]);
    defarg('sstimset',-1);
    defarg('sorient',-1);
    defarg('sbinSize',21);
    defarg('autopilot',0);

    defarg('fullstimset',[1,2,3,4]);

    stimulusSet = {'Faces A','Faces B','Textures A','Textures B'};


    %% trialslab.m subject information

    sidnum = 0;

    startexperiment=0;
    while (startexperiment==0)
        disp(' ');
        disp('>>>>>>>>> ATTENTION <<<<<<<<<<');
        disp(['Make sure that the viewing distance is ',num2str(vd),' cm.']);
        disp(' ');
        disp('******** ?? CHANGE CURRENT SETTINGS ?? ********');
        disp(['1......ID       (',sidnum,')']);
        disp(['2......GENDER   (',sgender,')']);
        disp(['3......AGE      (',num2str(sage),')']);
        if (groupID>0)&(groupID<=length(trialspervalue))
            disp(['4......GROUP    (TRIALS = ',num2str(trialspervalue(groupID)),' per contrast level)']);
        else
            disp(['4......GROUP    (** NO GROUP SPECIFIED ***)']);
        end;
    % 	if (ed.usespace)
    % 		disp(['7......AUTO-TRIAL START IS OFF']);
    % 	else
    % 		disp(['7......AUTO-TRIAL START IS ON']);
    % 	end;
        if sstimset>0
            disp(['5......STIMULUS SET = (',char(stimulusSet(sstimset)),' selected)']);
        else
            disp(['5......STIMULUS SET = (** NOT YET SPECIFIED **)']);
        end
%         if sorient==1
%             disp(['6......ORIENTATION = (UPRIGHT)']);
%         elseif sorient==2
%             disp(['6......ORIENTATION = (INVERTED)']);
%         else
%             disp(['6......ORIENTATION = (** NOT YET SPECIFIED **)']);
%         end
        disp(['6......POST-HOC BIN SIZE = (',num2str(sbinSize),')'])
        disp(['7......COMMENT  (',scomment,')']);
        disp(['8......LOAD PREVIOUS SETTINGS']);
        disp(['9......Autopilot? (default is NO) = (',num2str(autopilot),')']);
        if (groupID>0)&(groupID<=length(trialspervalue))&(sstimset>0)&(sstimset<=length(stimulusSet))
            disp(['b......Begin experiment']);
        else
            disp(['b......cannot begin experiment until the GROUP and STIMULUS SET are selected']);
        end;
        disp(['x......eXit experiment']);
        tmpselect=lower(input('ENTER YOUR SELECTION >> ','s'));
        switch tmpselect
        case '1'

            sidnum=[];
            disp('');
            while (isempty(sidnum))
                sidnum=input('Subject ID: ','s');
            end;

        case '2'

            sgender=[];
            disp('');
            while (isempty(sgender))
                sgender=input('Gender: ','s');
            end;

        case '3'

            sage=-1;
            disp(' ');
            while ((sage<1)|(sage>110))
                sage=input('Subject''s age (1-110): ');
            end;

        case '4'
            groupID=-1; tmp=-1;
            disp('Select Group:');
            while (groupID<0)
                for kk=1:length(trialspervalue)
                    disp([num2str(kk),'.....',num2str(trialspervalue(kk)),' trials per contrast level']);
                end; % for		
                tmp=input('Group >> ');
                if (tmp>0)&(tmp<=length(trialspervalue))
                    groupID=tmp;
                end; % if	
            end; % while

        case '5'
            sstimset=-1; reqstimset=-1;
            disp('Choose from one of the following:');
            while sstimset<0
                for kk=1:length(fullstimset)
                    disp(['Stimulus set ',num2str(kk),' = ',char(stimulusSet(kk))]);
                end
                reqstimset = input('Stimulus set >> ');
                if (reqstimset>0) & (reqstimset<=length(stimulusSet))
                    sstimset = reqstimset;
                end
            end

        case '6'
            sbinSize=-1; tmp=-1;
            while (sbinSize<0)
                tmp=input('How many trials per bin? ');
                if (tmp>0)
                    sbinSize=tmp;
                end; % if	
            end; % while

        case '7'
            scomment=[];
            disp('');
            while (isempty(scomment))
                scomment=input('Comment: ','s');
            end;

        case '8'
            load subjsettings;

        case '9'
            autopilot = input('Do you autopilot on? 0 = NO, 1 = YES >> ','s');
            autopilot = str2num(autopilot);

        case 'b'
                startexperiment=((groupID>0)&(groupID<=length(trialspervalue)));

        case 'x'
            disp(' ');
            yesno=input('Really exit (y/n)? ','s');
            if (length(yesno)<1)|(lower(yesno)~='n')
                return;
            end;
        end;
    end;
        
    
    save 'subjsettings' sidnum sgender sage groupID sstimset sorient scomment sbinSize; % save settings

    % do group-specific stuff here:
    for kk=1:exptdesign.numnz
        constimrec(kk).maxtrials=trialspervalue(groupID); % set number of trials per stimulus value
    end; % for

    %% trialsstimgen.m
    % load stimulus


    load (['theStimulus',num2str(sstimset)]); 

    stimNames={'stim1';'stim2';'stim3';'stim4';'stim5';'stim6';'stim7';'stim8';'stim9';'stim10'};
    [numStim,kk]=size(stimNames);
    for kk=1:numStim
        theStim(kk).stim=eval(['theStimulus',num2str(sstimset),'.',char(stimNames(kk))]);
    end;

    % normalize all faces to a variance of 1
    for kk=1:numStim
        theStim(kk).stim=theStim(kk).stim*sqrt(1/var(theStim(kk).stim(:)));
    end;

    % create thumbnail images for response window
    for kk=1:numStim
        thumbnail(kk).stim=imscale(imresize(theStim(kk).stim,0.5,'nearest'));
        thumbnail(kk).stim=thumbnail(kk).stim-mean(thumbnail(kk).stim(:));
        thumbnail(kk).stim=round(160*(1+0.5*thumbnail(kk).stim));
    end;

    % parameters for fitting weibulls and calculating threshold
    psygamma=1/numStim; % should be set to 1/N, where N is the number of stimulus alternatives (i.e., guessing rate)
    psydelta=0.01;
    psybeta=1.5;
    thresholdlevel=0.5;
    mintrialforthreshold=20; % min number of thresholds needed to make an attempt to fit a psychometric function to a data set; the data is still stored in a file

    exptdesign.numStim=numStim;


    %oldOn=fileshare(-3); % turn off filesharing
    starttime=GetSecs;
    %OS 9: [data,constimrec,quitflag]=trialsthreshdisplayOSX(cal,stimpix,displayrate,constimrec,mainscrs,thumbnail,facestim,exptdesign);
    % [data,constimrec,quitflag]=trialsthreshdisplayOSX(stimpix,displayrate,constimrec,mainscrs,thumbnail,theStim,exptdesign,autopilot,groupID);

    %% trialsthreshdisplayOSX
    % function [data,constimrec,quitflag]=trialsthreshdisplayOSX(stimpix,displayrate,constimrec,mainscrs,thumbnail,theStim,exptdesign,autopilot,groupID);

    warning('off','MATLAB:dispatcher:InexactMatch');
    MONTE_CARLO_SIM=0;

    % initialize the random number generator
    randn('state',sum(100*clock));

    % for playing sounds using 'snd'
    SND_RATE=8192;

    % data matrix
    data=zeros(1,10); % dm: col 1 is staircase ID(1-4); col 2 is target contrast; col 3 is nzvar; col 4 is response;

    % set up response keys
        kb = GetKeyboardIndices; % list of keyboard indices
        responseKeyboard=max(kb); % my guess of which one we'll be using

    escapeKey = KbName('escape');

    % convert stimulus duration from seconds to frames
    stimframes=round(displayrate*exptdesign.duration);
    fixpntoffsetframes=round(displayrate*exptdesign.fixpntstimoffset);
    if fixpntoffsetframes<1
        fixpntoffsetframes=1;
    end;

    % make sounds for feedback, etc.
    introsnd=makesnd(600,.2,.6);
    intervalsnd=makesnd(300,exptdesign.duration,.6);
    corrsnd=makesnd(800,.09,.6);
    wrongsnd=makesnd(200,.09,.7);


    % this is the screen upon which the image is to be displayed.
    screenNumbers = Screen('Screens'); % identify number of screens
    defarg('mainscrs',max(screenNumbers)); % define mainscrs as the highest screenNumber

    AssertOpenGL; % added Nov 30/09 for compatibility with OSX, ZH
    numBuffers=2;
    oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
    oldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1);

    % set screen resolution and store old settings
    screenWidth = 1280;
    screenHeight = 1024;
    screenFrequency = 85;
    screenPxSize = 32;
    oldResolution = Screen('Resolution', mainscrs, screenWidth, screenHeight, screenFrequency, screenPxSize);

    % calibrate monitor
    scrinfo.calfile     = 'pacemaker_1280x1024_85hz_Feb2013.mat';
    calfitrec           = pbReadCalibrationFile(scrinfo.calfile);
    % load calfitrec;
    avgLum = calfitrec.lmaxminave(3);
    cmin=calfitrec.lmaxminave(2);
    cmax=calfitrec.lmaxminave(1);
    L=calfitrec.caldata(:,5);
    B=calfitrec.caldata(:,4);
    rgbMat=calfitrec.caldata(:,1:3);

    [w wrect]=Screen('OpenWindow',mainscrs, 0,[],[],numBuffers);

    Screen('FillRect',w, [160 160 160]);
    Screen('Flip', w);
    center = [wrect(3) wrect(4)]/2;

    ifi=Screen('GetFlipInterval', w);
    waitframes = 1;
    waitduration = waitframes * ifi;

    % set text properties for our screen
    TxtSize=32;
    TxtSizeDiv2=round(TxtSize/2);
    Screen('TextFont',w, 'Helvetica');
    Screen('TextSize',w, TxtSize);
    Screen('TextStyle', w, 0);

    fixPntX = round( center(1));
    fixPntY = round( center(2));
    fixPntSize = 8;

    priorityLevel=MaxPriority(w);

    %Setting up the rects OS X
     fixpnt=[0 0 8 8]; fixpnt=CenterRect(fixpnt, wrect);
     stimRect=[0 0 256 256];
     destRect=CenterRect(stimRect, wrect);
     boxrect=[0 0 264 264];
     boxrect=CenterRect(boxrect,wrect);

    % make dest rects for thumbnail images on response window
    thumbsize=size(thumbnail(1).stim);
    %thumbrect=setrect(0,0,thumbsize(2),thumbsize(1)); %OS 9
    thumbrect=[0,0,thumbsize(2),thumbsize(1)];
    thumbdest=zeros(4,4);
    for kk=1:exptdesign.numStim
        thumbdest(kk,:)=CenterRect(thumbrect,wrect);
    end;

%     thumbdest(1,:)=offsetrect(thumbdest(1,:),round(-3*thumbsize(1)),round(-1*thumbsize(1)));
%     thumbdest(2,:)=offsetrect(thumbdest(2,:),round(-1.5*thumbsize(1)),round(-1*thumbsize(1)));
%     thumbdest(3,:)=offsetrect(thumbdest(3,:),round(0*thumbsize(1)),round(-1*thumbsize(1)));
%     thumbdest(4,:)=offsetrect(thumbdest(4,:),round(1.5*thumbsize(1)),round(-1*thumbsize(1)));
%     thumbdest(5,:)=offsetrect(thumbdest(5,:),round(3*thumbsize(1)),round(-1*thumbsize(1)));
%     thumbdest(6,:)=offsetrect(thumbdest(6,:),round(-3*thumbsize(1)),round(1*thumbsize(1)));
%     thumbdest(7,:)=offsetrect(thumbdest(7,:),round(-1.5*thumbsize(1)),round(1*thumbsize(1)));
%     thumbdest(8,:)=offsetrect(thumbdest(8,:),round(0*thumbsize(1)),round(1*thumbsize(1)));
%     thumbdest(9,:)=offsetrect(thumbdest(9,:),round(1.5*thumbsize(1)),round(1*thumbsize(1)));
%     thumbdest(10,:)=offsetrect(thumbdest(10,:),round(3*thumbsize(1)),round(1*thumbsize(1)));

    thumbdest(1,:)=offsetrect(thumbdest(1,:),round(-4*thumbsize(1)),round(-2*thumbsize(1)));
    thumbdest(2,:)=offsetrect(thumbdest(2,:),round(-2*thumbsize(1)),round(-2*thumbsize(1)));
    thumbdest(3,:)=offsetrect(thumbdest(3,:),round(0*thumbsize(1)),round(-2*thumbsize(1)));
    thumbdest(4,:)=offsetrect(thumbdest(4,:),round(2*thumbsize(1)),round(-2*thumbsize(1)));
    thumbdest(5,:)=offsetrect(thumbdest(5,:),round(4*thumbsize(1)),round(-2*thumbsize(1)));
    thumbdest(6,:)=offsetrect(thumbdest(6,:),round(-4*thumbsize(1)),round(2*thumbsize(1)));
    thumbdest(7,:)=offsetrect(thumbdest(7,:),round(-2*thumbsize(1)),round(2*thumbsize(1)));
    thumbdest(8,:)=offsetrect(thumbdest(8,:),round(0*thumbsize(1)),round(2*thumbsize(1)));
    thumbdest(9,:)=offsetrect(thumbdest(9,:),round(2*thumbsize(1)),round(2*thumbsize(1)));
    thumbdest(10,:)=offsetrect(thumbdest(10,:),round(4*thumbsize(1)),round(2*thumbsize(1)));

    % thumbdests for Drawtextures, OS X
    thumbdests=zeros(4,10);
    for kk=1:10
        thumbdests(:,kk)=thumbdest(kk,:);
    end;


    % create the textures for thumbnail images OS X
    for kk=1:exptdesign.numStim
        thumbnailptr(kk)=Screen('MakeTexture', w, thumbnail(kk).stim);
    end;

    % vector of thumbnailptrs for DrawTexture, OS X
    thumbnailptrs=zeros(1,10);
    for kk=1:10
      thumbnailptrs(kk)=thumbnailptr(kk);
    end


    % start of the scan...
    HideCursor; % this hides the mouse cursor
    starttime=GetSecs;

    % light adapt OSX
    adaptTime = adaptseconds;
    adaptpause(w,wrect,adaptTime,0);

    err=snd('Open'); % open the sound buffer
    err=snd('Play',introsnd,SND_RATE); err=snd('Play',corrsnd,SND_RATE); err=snd('Play',wrongsnd,SND_RATE);

    FlushEvents;
    WaitSecs(1);

    Screen('DrawText',w,'Please press SPACE when ready to begin.',fixPntX/2,fixPntY);
    Screen('Flip',w);
    [secs, keyCode, deltaSecs] = KbWait;
    while keyCode(KbName('space'))~=1;
        [secs, keyCode, deltaSecs] = KbWait;
    end
    WaitSecs(1);

    % OSX Clear screen and show fixation point for 1 second
    vbl=GetSecs;
    vblendtime = vbl + 1;
    while (vbl < vblendtime)
        Screen('FillRect',w, [160 160 160]);
        Screen('glPoint',w,0,fixPntX,fixPntY,8);
        [vbl]=Screen('Flip', w); % flip the buffer to the screen
    end

    quitflag=0;
    alldone=0;
    curtrial=1;

    % input from initial dialogue indicating number of blocks
    % blockNum from experimenter input
    
%     numvalues=7; exptdesign.numnz=1:3; nv=[0.0010; 0.0100; 0.1000]; exptdesign.numStim=10;
%  

nzconcomb = exptdesign.numnz*numvalues; % number of noise x contrast combinations (21)
% totalTrials = nzconcomb*exptdesign.numStim*groupID; % number of noise x contrast x stimulus x group combinations (210, 420, 840)
totalTrials = nzconcomb*trialspervalue(groupID);
stimList=zeros(totalTrials,4);
% for kkB=1:exptdesign.numStim*trialspervalue(groupID)

for kkB=1:trialspervalue(groupID)
    stimBlock = zeros(nzconcomb,4); % zeros(21,4)
    stimBlock(:,1) = randperm(nzconcomb); % randperm(21)
    stimBlock(1:(nzconcomb/3),2)=1:(nzconcomb/3); % contrast levels
    stimBlock((nzconcomb/3+1):(2*nzconcomb/3),2)=1:nzconcomb/3; % contrast levels
    stimBlock((2*nzconcomb/3+1):(nzconcomb),2)=1:7; % contrast levels
    stimBlock(1:(nzconcomb/3),3) = 1; % noise variance
    stimBlock((nzconcomb/3+1):(2*nzconcomb/3),3) = 2; % noise variance
    stimBlock((2*nzconcomb/3+1):(nzconcomb),3) = 3; % noise variance
    stimBlock = sortrows(stimBlock,1);
%     if groupID < 4
        stimBlock(1:nzconcomb,4) = [randperm(10),randperm(10),randi(10)]; % randomize faces to avoid repeat within 10 trials
        stimList(((kkB-1)*21+1):((kkB-1)*21+21),1:4)=stimBlock(:,1:4);
%     elseif groupID == 4
%         stimList(((kkB-1)*21+1):((kkB-1)*21+21),1:3)=stimBlock(:,1:3);
%     end
end

if groupID==3
    for kk = 1:totalTrials
        stimList(kk,4) = randi(10);
        for mm=1:kk-1
            stimUsed=stimList(mm,2:4);
            if stimList(kk,2:4)==stimUsed;
                kk=kk-1;
            end
        end
    end
end

% stimList(trial in block (1-21), contrast level (1-7), noise variance (1-3), stimulus number (1-10))
            

%% original presentation
while ((alldone==0)&(quitflag==0))
	stime=GetSecs; % get the start time for this trial; we'll use this later
% 	curStim=randomcondition(exptdesign.numStim); % randomly select the faceID for this trial
    for tt = 1:length(stimList)
        if totalTrials>420 && tt==round(totalTrials/2);
            Screen('DrawText',w,'Please take a short break and press SPACE when ready to resume.',fixPntX/3,fixPntY);
            Screen('Flip',w);
            [secs, keyCode, deltaSecs] = KbWait;
            while keyCode(KbName('space'))~=1;
                [secs, keyCode, deltaSecs] = KbWait;
            end
            WaitSecs(1);
        end
            
                
        curStim = stimList(tt,4);
        condID = stimList(tt,3);
        contrastID = stimList(tt,2);
	
%     gotone=0;
% 	while (gotone==0)
% 		condID=ran(exptdesign.numnz);
% 		if (~psyfuncfinished(constimrec(condID))) gotone=1; end;
% 	end;
	
	nzvar=constimrec(condID).appspec;	% noise variance
	[stim,nzseed]=noise2d(stimpix,nzvar,-1,1,0);
    curStimVariance = constimrec(condID).values(contrastID);
% 	curStimVariance=constimGetValue(constimrec(condID)); % get the stimulus variance for the current method-of-constant-stimuli record
	tmpStim=theStim(curStim).stim*sqrt(curStimVariance); % this formula works because the faces have a variance of 1
	finalStim=stim+tmpStim; % add noise to face
    
    
    tmpStimLum=avgLum*(1+finalStim); % convert image from contrast to luminance values
    tmpStimBS=pbLum2BS(tmpStimLum,L,B);  % bits-stealing 
    tmpStimFinal=pbBitstealing2RGB(tmpStimBS, rgbMat,0); % bit-stealing to RGB
    dstRect=[0 0 256 256]; % destination rect
    dstRect=CenterRect(dstRect, wrect); % dest rect centered
    srcRect=[0 0 256 256]; % source rect, whatever that is
    Stim=Screen('MakeTexture', w, tmpStimFinal); % pre- DrawTexture preparation
    
    trialStartTime=GetSecs;
    gotime=stime+exptdesign.intertrial; % wait here
	
	while (GetSecs<gotime) end;
    
  
    vbl=GetSecs;
    vblendtime = vbl + 0.1; % vbl + 1
    while (vbl < vblendtime)
    Screen('FillRect',w, [160 160 160]);
    [vbl]=Screen('Flip', w); 
    end;
    
    time0=GetSecs;
    timeStim=time0+.2;
    while(time0<timeStim)
    Screen('DrawTexture', w, Stim, srcRect, dstRect);  % actually putting the image on the screen
    Screen('FrameRect', w, 10, boxrect, 1); % putting the frame around the stim on the screen
    [time0]= Screen('Flip', w); % making it appear
    end
    stimofftime=GetSecs;
    
    intTime=GetSecs;
    intTime2=intTime+0.100;
    while intTime<intTime2
        Screen('FillRect',w,[160 160 160])
        intTime=Screen('Flip',w);
    end;
      
    %OS 9 method of converting image to CLUT values; replaced with OSX
    %version above (lines after stim=stim+tmpface).
    % this is the routine that makes a pixel image and a CLUT for display.
	% the first index in the clut is always reserved for average luminance.
	% remember that the routine expects the image in terms of *contrast*.
	
    %[currimage,currCLUT]=makeimage(stim,cal,0);  OS9 method of converting
	%image, now using pbBitstealing for OSX
	%screen(offscrptrs(1),'PutImage',currimage); % store in offscreen pixel map
	
        
 %   trialStartTime=GetSecs;
 %   gotime=stime+exptdesign.intertrial; % wait here
	
%	while (GetSecs<gotime) end;
    
% 	screen(screens(1),'WaitBlanking'); % wait 1 frame
% 	screen(screens(1),'FillOval',0,fixpnt); % erase fixation point
% 	screen(screens(1),'WaitBlanking',fixpntoffsetframes-1); % wait for the correct number of frames
% 	screen(screens(1),'SetClut',currCLUT,0); % write to clut and return 1 frame later
% 	screen(screens(1),'FrameRect',1,boxrect); % draw the stimulus box
%   screen('CopyWindow',offscrptrs(1),screens(1),stimrect,destrect);
% 	screen(screens(1),'WaitBlanking',stimframes); % wait for the correct number of frames
% 	screen(screens(1),'FillRect',0,destrect); % fill destrect with avg lum
% 	screen(screens(1),'FrameRect',0,boxrect); % erase the stimulus box
% 	stimofftime=getsecs;
% 	screen(screens(1),'WaitBlanking'); % wait 1 frame
% 	screen(screens(1),'SetClut',defaultCLUT,0);
% 	screen(screens(1),'FillOval',1,fixpnt); % draw fixation point


%     vbl=GetSecs;
%     vblendtime = vbl + 0.1; % vbl + 1
%     while (vbl < vblendtime)
%     Screen('FillRect',w, [160 160 160]);
% %     Screen('glPoint',w,0,fixPntX,fixPntY,8);
%     [vbl]=Screen('Flip', w); 
%     end;
        
     
    %draw thumbnail images OS X
    time1=GetSecs;
    timeThumb=time1+.1;
    while(time1<timeThumb)
        Screen('DrawTextures', w, thumbnailptrs, thumbrect, thumbdests);
        Screen('glPoint',w,0,fixPntX,fixPntY,8);
        [time1]=Screen('Flip', w);
    end;

    FlushEvents('keyDown');
    FlushEvents('mouseDown');
    FlushEvents('mouseUp');
    % center the mouse on the fixation point
    theX=fixpnt(rectleft)+round(rectwidth(fixpnt)/2);
    theY=fixpnt(recttop)+round(rectheight(fixpnt)/2);
    if mainscrs==1
        theX = fixPntX+1024; % if dual screen, ensures mouse is on the 2nd screen
    end
    SetMouse(theX,theY);
% 		while 1
% 			SetMouse(theX,theY);
% 			[checkX,checkY] = GetMouse;
% 			if (checkX==theX) & (checkY==theY)
% 				break;
% 			end
% 		end
    showcursor(0); gotresponse=0; response=0;
    while (gotresponse==0)
        [x,y,buttons]=GetMouse(w);
        if autopilot==1
            gotresponse=1; response=randi(10);
        else
            for kk=1:exptdesign.numStim
                if (isinrect(x,y,thumbdest(kk,:))) && sum(buttons(:))==1;
                    gotresponse=1; response=kk;
                elseif x<0;
                    SetMouse(1025,y);
                end; % if
            end; % for
        end


        [keyIsDown, secs, keyCode] = KbCheck;
        if keyIsDown==1 && keyCode(escapeKey)==1
            gotresponse=1;
            quitflag=1;
        end

    end; % while

    hidecursor; % this hides the mouse cursor

    if quitflag==1 break; end;

    rlatency=getsecs-stimofftime;

    % auditory feedback
	if (response > 0)
		correct=(response==curStim);
		constimrec(condID)=psyfuncUpdate(constimrec(condID),correct); % update the constant stimuli data structure
		if correct
			% sound(corrsnd);
			err=snd('Play',corrsnd,SND_RATE);
		else
			% sound(wrongsnd);
			err=snd('Play',wrongsnd,SND_RATE);
		end;
	end; % if (response > 0) & (condID>0)
    
    %erase thumbnail images OSX
    Screen('FillRect',w, [160 160 160]);
    timeInterval=GetSecs;
    timeInterval2=GetSecs+1; % 0.500
    while timeInterval<timeInterval2
        Screen('FillRect',w,[160 160 160]);
        Screen('glPoint',w,0,fixPntX,fixPntY,8); %%%%%%%%%%%%%%%%%
        timeInterval=Screen('Flip',w);
    end;
	
	if (response>0)
		data(curtrial,:)=[curtrial,condID,nzvar,curStimVariance,curStim,response,correct,rlatency,nzseed']; % update data matrix
		curtrial=curtrial+1; % increment trial counter
	end; % if (response > 0)
		
% END OF TRIAL...
	tmpdone=1;
	for kk=1:exptdesign.numnz
		if ~psyfuncfinished(constimrec(kk))
			tmpdone=0;
			break;
		end;
    end;
	alldone=tmpdone;
    end;
end; % while ((alldone==0)&(quitflag==0))


    
    
%     blockNum = groupID;
% 
%     while alldone==0 && quitflag==0
%         stime = GetSecs; % get start time for this trial; will use this later
%     %     tmpNumStim = exptdesign.numnz * exptdesign.numStim;
%         tmpNumStim = exptdesign.numnz * numContrast;
%         if alldone==0 && quitflag==0;
%             for kk = 1:blockNum
%                 stimBlock(:,1) = randperm(21);
%                 stimBlock = sortrows(stimBlock,1);
% %             stimOrder = randperm(tmpNumStim);
%             if alldone==0 && quitflag==0;
%                 for ii = 1:length(stimBlock);
%                     condID = stimBlock(3,ii);
%                     curStim=randomcondition(exptdesign.numStim);
%                     nzvar=constimrec(condID).appspec;	% noise variance
%                     [stim,nzseed]=noise2d(stimpix,nzvar,-1,1,0);
%                     curStimVariance=constimGetValue(constimrec(condID)); % get the stimulus variance for the current method-of-constant-stimuli record
%                     tmpStim=theStim(curStim).stim*sqrt(curStimVariance); % this formula works because the faces have a variance of 1
%                     finalStim=stim+tmpStim; % add noise to face
%                     tmpStimLum=avgLum*(1+finalStim); % convert image from contrast to luminance values
%                     tmpStimBS=pbLum2BS(tmpStimLum,L,B);  % bits-stealing 
%                     tmpStimFinal=pbBitstealing2RGB(tmpStimBS, rgbMat,0); % bit-stealing to RGB
%                     dstRect=[0 0 256 256]; % destination rect
%                     dstRect=CenterRect(dstRect, wrect); % dest rect centered
%                     srcRect=[0 0 256 256]; % source rect, whatever that is
%                     Stim=Screen('MakeTexture', w, tmpStimFinal); % pre- DrawTexture preparation
% 
%                     trialStartTime=GetSecs;
%                     gotime=stime+exptdesign.intertrial; % wait here
% 
%                     while (GetSecs<gotime) end;
% 
%                     time0=GetSecs;
%                     timeStim=time0+.2;
%                     while(time0<timeStim)
%                     Screen('DrawTexture', w, Stim, srcRect, dstRect);  % actually putting the image on the screen
%                     Screen('FrameRect', w, 10, boxrect, 1); % putting the frame around the stim on the screen
%                     [time0]= Screen('Flip', w); % making it appear
%                     end
%                     stimofftime=GetSecs;
% 
%                     intTime=GetSecs;
%                     intTime2=intTime+.100;
%                     while intTime<intTime2
%                         Screen('FillRect',w,[160 160 160])
%                         intTime=Screen('Flip',w);
%                     end;
% 
%                     vbl=GetSecs;
%                     vblendtime = vbl + 1;
%                     while (vbl < vblendtime)
%                     Screen('FillRect',w, [160 160 160]);
%                     Screen('glPoint',w,0,fixPntX,fixPntY,8);
%                     [vbl]=Screen('Flip', w); 
%                     end;
% 
% 
%                     %draw thumbnail images OS X
%                     time1=GetSecs;
%                     timeThumb=time1+.1;
%                     while(time1<timeThumb)
%                         Screen('DrawTextures', w, thumbnailptrs, thumbrect, thumbdests);
%                         Screen('glPoint',w,0,fixPntX,fixPntY,8);
%                         [time1]=Screen('Flip', w);
%                     end;
% 
%                     FlushEvents('keyDown');
%                     FlushEvents('mouseDown');
%                     FlushEvents('mouseUp');
%                     % center the mouse on the fixation point
%                     theX=fixpnt(rectleft)+round(rectwidth(fixpnt)/2);
%                     theY=fixpnt(recttop)+round(rectheight(fixpnt)/2);
%                     if mainscrs==1
%                         theX = fixPntX+1024; % if dual screen, ensures mouse is on the 2nd screen
%                     end
%                     SetMouse(theX,theY);
%                     showcursor(0); gotresponse=0; response=0;
%                     while (gotresponse==0)
%                         [x,y,buttons]=GetMouse(w);
%                         if autopilot==1
%                             gotresponse=1; response=randi(10);
%                         else
%                             for kk=1:exptdesign.numStim
%                                 if (isinrect(x,y,thumbdest(kk,:))) && sum(buttons(:))==1;
%                                     gotresponse=1; response=kk;
%                                 end; % if
%                             end; % for
%                         end
% 
%                         [keyIsDown, secs, keyCode] = KbCheck;
%                         if keyIsDown==1 && keyCode(escapeKey)==1
%                             gotresponse=1;
%                             quitflag=1;
%                         end
% 
%                     end; % while
% 
%                     hidecursor; % this hides the mouse cursor
% 
%                     if quitflag==1 break; end;
% 
%                     rlatency=getsecs-stimofftime;
% 
%                     %erase thumbnail images OSX
%                     Screen('FillRect',w, [160 160 160]);
%                     timeInterval=GetSecs;
%                     timeInterval2=GetSecs+.500;
%                     while timeInterval<timeInterval2
%                         Screen('FillRect',w,[160 160 160]);
%                         timeInterval=Screen('Flip',w);
%                     end;
% 
%                     if (response > 0)
%                         correct=(response==curStim);
%                         constimrec(condID)=psyfuncUpdate(constimrec(condID),correct); % update the constant stimuli data structure
%                         if correct
%                             % sound(corrsnd);
%                             err=snd('Play',corrsnd,SND_RATE);
%                         else
%                             % sound(wrongsnd);
%                             err=snd('Play',wrongsnd,SND_RATE);
%                         end;
%                     end; % if (response > 0) & (condID>0)
% 
%                     if (response>0)
%                         data(curtrial,:)=[curtrial,condID,nzvar,curStimVariance,curStim,response,correct,rlatency,nzseed']; % update data matrix
%                         curtrial=curtrial+1; % increment trial counter
%                     end; % if (response > 0)
% 
%                 % END OF TRIAL...
%                     tmpdone=1;
%                     for kk=1:exptdesign.numnz
%                         if ~psyfuncfinished(constimrec(kk))
%                             tmpdone=0;
%                             break;
%                         end;
%                     end;
%                     alldone=tmpdone;
%                 end; % for stimOrder
%                end; % if ((alldone==0)&(quitflag==0))
%             end; % for blockNum
%         end; % if ((alldone==0)&(quitflag==0))
%     end; % while ((alldone==0)&(quitflag==0))


    %%
    err=snd('Close'); % close the sound buffer here
    sca;

    showcursor(0);
    close all;	% close the screen and data file. this is a wrapper around brainard that closes 
    % all of the active windows and any text data file that may have been
    % opened but not closed during the routine.
    % sound(introsnd);

    %% restore original resolution
    exptResolution = Screen('Resolution', mainscrs, oldResolution.width, oldResolution.height, oldResolution.hz, oldResolution.pixelSize);


    %%
    endtime=GetSecs;
    % oldOn=fileshare(oldOn); % re-set filesharing
    disp(['Elapsed time = ',num2str((endtime-starttime)/60),' minutes']);
    if (quitflag) disp('The experiment was aborted by the subject.'); end;

    % close the screen and data file. this is a wrapper around brainard that closes 
    % all of the active windows and any text data file that may have been
    % opened but not closed during the routine.
    close all;	

%     % fit psychometric functions to the data from each external-noise condition
%     alpha=zeros(1,numnz); beta=zeros(1,numnz); threshold=zeros(1,numnz); goodestimate=zeros(1,numnz);
%     for kk=1:numnz
%         if (sum(constimrec(kk).trialcount)>=mintrialforthreshold)
%             tmpdata=constimrec(kk).trialdata;
%             [alpha(kk),beta(kk)]=fitpsymet(tmpdata,'weibull',[thresholdguess(kk),psybeta],psygamma,psydelta);
%             threshold(kk)=getthresh(thresholdlevel,'weibull',[alpha(kk),beta(kk)],psygamma,psydelta);
%             disp(['condition ',num2str(kk),'; alpha = ',num2str(alpha(kk)),'; beta = ',num2str(beta(kk)),'; ',num2str(thresholdlevel*100),'% correct threshold = ',num2str(threshold(kk))]);
%             goodestimate(kk)=1;	
%         else
%             disp(['condition ',num2str(kk),': not enough trials to compute threshold']);
%         end;
%     end;


    %% trialswritefile;
    % write data files to disk
    dt=dir; tmp=size(dt); kk=tmp(1);
    found=1;
    k=1;
    while found
        matfname=['grp',num2str(trialspervalue(groupID)),'_ID',sidnum,strcat(stimulusSet{sstimset})];
        testname=[matfname,'.mat'];
        tmp=0;
        for n=1:kk
            tmp(n)=strcmp(lower(testname),lower(dt(n).name));
        end;
        found=max(tmp);
        k=k+1;
    end;
    thedate=date;
    clear images facestim thumbnail; % we don't need these any more, so delete 'em
    cd(matdatadir);
    save(matfname); % save everything else to a mat file
    cd(mainpath);
    disp(['workspace stored in file ',testname]);
%     cd(mainpath);

    cd(textdatadir);
%     csvwrite(['pcorrect_',num2str(sidnum),'_',num2str(trialspervalue(groupID)),'trials_',strcat(stimulusSet{sstimset}),'.csv'],pcorrect)

    textfname=['grp',num2str(trialspervalue(groupID)),'_ID',sidnum,'_trials',strcat(stimulusSet{sstimset})];
    testname=[textfname,'.txt'];
    datafilename=testname;



    fid=fopen(datafilename,'a');
    count=fprintf(fid,'%s\n',['Date: ',thedate]);
    count=fprintf(fid,'%s\n',['File: ',datafilename]);
    count=fprintf(fid,'%s\n',['Experiment: ',exptname]);
    count=fprintf(fid,'%s\n',['Subject ID: ',sidnum]);
    count=fprintf(fid,'%s\n',['Gender: ',sgender]);
    count=fprintf(fid,'%s\n',['Age: ',num2str(sage)]);
    count=fprintf(fid,'%s\n',['Group ',num2str(groupID),':',num2str(trialspervalue(groupID)),' trials per contrast level']);

    count=fprintf(fid,'%s\n',['Comment: ',scomment]);
    count=fprintf(fid,'%s\n',['Calibration File: ',scrinfo.calfile]);
    count=fprintf(fid,'%s\n',['Avg Luminance: ',num2str(calfitrec.lmaxminave(3))]);
    count=fprintf(fid,'%s\n',['Display Frame Rate (Hz): ',num2str(exptResolution.hz)]);
    count=fprintf(fid,'%s \t %s \t %s\n','Display Size (pixels): ',['Width: ',num2str(calfitrec.displaycm(1))],['Height: ',num2str(calfitrec.displaycm(2))]);
    count=fprintf(fid,'%s\n',['Display set to ',num2str(exptResolution.pixelSize),' bits per pixel']);
    count=fprintf(fid,'%s\n',['Stimulus duration (sec): ',num2str(exptdesign.duration)]);
    count=fprintf(fid,'%s\n',['Time between fixation point offset and stimulus onset (sec): ',num2str(exptdesign.fixpntstimoffset)]);
    count=fprintf(fid,'%s\n',['Inter-trial interval (sec):',num2str(exptdesign.intertrial)]);
    count=fprintf(fid,'%s\n',['Light Adaptation Duration (sec):',num2str(exptdesign.adaptseconds)]);
    count=fprintf(fid,'%s\n',['Viewing distance (cm):',num2str(exptdesign.viewingdistcm)]);


    count=fprintf(fid,'%s\n\n',['Matlab workspace stored in file: ',matfname]);
    count=fprintf(fid,'%s\n',['Data were fit with a weibull function: Gamma = ',num2str(psygamma),'; Delta = ',num2str(psydelta)]);
    count=fprintf(fid,'%s\n',['Identification threshold was defined as the ',num2str(thresholdlevel*100),'% correct point on the psychometric function.']);
    count=fprintf(fid,'%s \t %s \t %s \t %s \n','Ext. Noise Var.','Stim. Threshold Var.','Alpha','Beta');
    % for kk=1:exptdesign.numnz
    % 	if (goodestimate(kk))
    % 		count=fprintf(fid,'%8.6f\t %8.6f\t %8.6f\t %8.6f\n',constimrec(kk).appspec,threshold(kk),alpha(kk),beta(kk));
    % 	else
    % 		count=fprintf(fid,'%8.6f\t %s\n',constimrec(kk).appspec,'insufficient trials to determine threshold');
    % 	end;
    % end;


    count=fprintf(fid,'%s \t %s \n','Face ID: ','Name');
    for kk=1:exptdesign.numStim
        count=fprintf(fid,'%s\t %s\n',num2str(kk),char(stimNames(kk)));
    end;
    count=fprintf(fid,'\n%s\n',['DATA']);
    count=fprintf(fid,'%s \t %s \t %s \t %s \t %s \t %s \t %s \t %s \n','trial #','conditionID','nz var','face var','stim ID','response','correct','RT(sec)');

    [numtrials,tmp0]=size(data);

    for kk=1:numtrials fprintf(fid,'%i \t %i \t %8.6f \t %8.6f \t %i \t %i \t %6.2f \t %i\n',data(kk,1:8)); end
    fclose(fid);

    cd(mainpath);
    disp(['data stored in text file ',datafilename]);
    
    totalTrial = data(end,1);
    
    binSize = sbinSize;
    
    if totalTrial < sbinSize
        binSize = 1;
        fprintf('\nNot enough trials for desired bin. **Resorting to 1 trial per bin**\n')
    else
        binSize = sbinSize;
        fprintf(['\nBin Size set to ',num2str(binSize),' trials per bin.\n']);
    end
    
%     binSize defined from experimenter input
    binNum = totalTrial / binSize;
    pcorrect = zeros(binNum,2);
    for ii = 1:binNum
        pcorrect(ii,1) = ii;
        pcorrect(ii,2) = mean(data((ii-1)*binSize+1:((ii-1)*binSize)+binSize,7));
    end

    if totalTrial >= binSize
         learningcurve = plot(pcorrect(:,2));
    end
    
    cd(matdatadir);
    csvwrite(['pcorrect_',num2str(sidnum),'_',num2str(trialspervalue(groupID)),'trials_',strcat(stimulusSet{sstimset}),'.csv'],pcorrect)

    cd(mainpath); % restore original path

% end % function