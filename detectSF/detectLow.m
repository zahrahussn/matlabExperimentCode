% function pl2012
    % perceptualLearning2012
    % written by AH & JL, June 2012
    % based on ZH & PJB code

    clear all; % clear workspace
    
    debug=false;
     if debug
        rect0=[0,0,800,600];
    else
        rect0=[];
     end
    
     % other method = bitStealing; zh april 22, 2018, with help from jb
    calibrationMethod='psychophysical';
%    calibrationMethod='bitStealing';
    

    starttime=GetSecs; 
    %randn('state',sum(100*clock)); % initialize the random number generator
    RandStream.create('mt19937ar','seed',sum(100*clock));
    warning('off','MATLAB:dispatcher:InexactMatch');
    %disable psychtoolbox test screen
    oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
    oldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1);

    defarg('exptname','texture_detection');	% the name of the experiment
    screenNumbers = Screen('Screens');
    defarg('mainscrs',max(screenNumbers)); % this is the screen upon which the image is to be displayed.
    %swidth=1920; sheight=1080; pixelsize=32; hz=60;% should be the same as settings during calibration; should be stored with calibration file, but currently are not
    %swidth=1280; sheight=1024; pixelsize=8; hz=85;% should be the same as settings during calibration; should be stored with calibration file, but currently are not
    displayrate=Screen('FrameRate',mainscrs);

    % file & directory names names
    defarg('detectTEXTfolder','detectLowTEXTfiles');	% N.B. make sure this folder exists within the folder containing 'trialslab'!
    defarg('detectMATfolder','detectLowMATfiles');		% N.B. make sure this folder exists within the folder containing 'trialslab'!

    % set the paths
    disp('setting path names...');
    mfilename='detectLow'; mainfile = [mfilename,'.m'];
    eval(['mainpath=which(',QuoteString(mainfile),');']);
    mainpath=strrep(mainpath,'experimentCode', 'data'); % modified sept 10, 2018 for github rearrangement
    mainpath = mainpath(1:end-length(mainfile));
    textdatadir=[mainpath,detectTEXTfolder];
    matdatadir=[mainpath,detectMATfolder];
    cd(mainpath);
    disp(mainpath);

    % stimulus dimensions
    defarg('vd',114);			
    defarg('stimpix',256);		% size of stimulus in pixels
    
    % external noise variances
    nv = [0.01, 0.1];				% external noise variances (low, medium, & high)
    numnz=length(nv);	% number of external noises

    % parameters for method of constant stimuli  
    defarg('numvalues',7); % # of stimulus levels (i.e., contrast variance) used in each condition
    numContrast = numvalues;
    defarg('trialspervalue',[1,6,12,20]); % # of trials per contrast level
    defarg('stepsperlogunit',10);
    % defarg('thresholdguess',[0.00001,0.0015,0.003]);
    % defarg('thresholdguess',3*nv/40); % these seem to be about right
    %thresholdguess=[0.00002, 0.00012]; %  high noise guess 0.0002 for subject fm, lowered for andy
    %thresholdguess=[0.000009, 0.00012]; %Value changed on July 10th 2018
    thresholdguess=[0.00003, 0.00012]; %Sept 26, 2018; low noise guess raised
    
    
    for kk=1:numnz
%         tmp=thresholdguess(kk)/sqrt(10);
%         values(kk,:)=logspace(log10(tmp),log10(10*tmp),numvalues); % set (n=numvalues) of log-spaced values centered on thresholdguess
%         constimrec(kk)=constimInit(values(kk,:),trialspervalue(1)); % init the constantstimulus struct
%         constimrec(kk).appspec=nv(kk);	% attached noise variance to app-specific field
        tmp=thresholdguess(kk);
        highval=log10(tmp)+log10(sqrt(8)); % default 50 
        lowval=log10(tmp)-log10(sqrt(2)); % lowval raised from sqrt(15) to sqrt(5), oct 23, 2013 zh; sqrt2 nov 11, 2013
        val(kk,:)=logspace(lowval,highval,numvalues); % set (n=numvalues) of log-spaced values centered on thresholdguess
        values(kk,:)=[0,0,0,0,0,0,0,val(kk,:)]; %added 0-contrast values for the yes/no task.
        constimrec(kk)=constimInit(values(kk,:),trialspervalue(1)); % init the constantstimulus struct
        constimrec(kk).appspec=nv(kk);	% attached 
        
        
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

    defarg('fullstimset',[1,2,3,4,5,6]);

    stimulusSet = {'facesA', 'facesB','Textures_LowA','Textures_LowB', 'Textures_Med', 'Textures_High'};


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
        if (groupID>0)&&(groupID<=length(trialspervalue))
            disp(['4......GROUP    (TRIALS = ',num2str(trialspervalue(groupID)),' per contrast level)']);
        else
            disp('4......GROUP    (** NO GROUP SPECIFIED ***)');
        end;
   
        if sstimset>0
            disp(['5......STIMULUS SET = (',char(stimulusSet(sstimset)),' selected)']);
        else
            disp('5......STIMULUS SET = (** NOT YET SPECIFIED **)');
        end
        disp(['6......POST-HOC BIN SIZE = (',num2str(sbinSize),')'])
        disp(['7......COMMENT  (',scomment,')']);
        disp('8......LOAD PREVIOUS SETTINGS');
        disp(['9......Autopilot? (default is NO) = (',num2str(autopilot),')']);
        if (groupID>0)&&(groupID<=length(trialspervalue))&&(sstimset>0)&&(sstimset<=length(stimulusSet))
            disp('b......Begin experiment');
        else
            disp('b......cannot begin experiment until the GROUP and STIMULUS SET are selected');
        end;
        disp('x......eXit experiment');
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
            while ((sage<1)||(sage>110))
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
                if (tmp>0)&&(tmp<=length(trialspervalue))
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
                if (reqstimset>0) && (reqstimset<=length(stimulusSet))
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
            if (length(yesno)<1)||(lower(yesno)~='n')
                return;
            end;
        end;
    end;
        
    
    save 'subjsettings' sidnum sgender sage groupID sstimset sorient scomment sbinSize; % save settings

    % do group-specific stuff here:
    for kk=1:exptdesign.numnz
        constimrec(kk).maxtrials=trialspervalue(groupID); % set number of trials per stimulus value
    end; % for

%    load (['theStimulus',num2str(sstimset)]); # option removed sept 2018
    load theStimulus3; % set to low textures to avoid stimulus error; zh sept 2018


    stimNames={'stim1';'stim2';'stim3';'stim4';'stim5';'stim6';'stim7';'stim8';'stim9';'stim10'};
   % stimNames=fieldnames(eval(['theStimulus', num2str(stimset)]));
    [numStim,kk]=size(stimNames);
    for kk=1:numStim
       % theStim(kk).stim=eval(['theStimulus',num2str(sstimset),'.',char(stimNames(kk))]);
        theStim(kk).stim=eval(['theStimulus3.',char(stimNames(kk))]); % modified sept 2018 to fix stimulus to low textures
    end;

    % normalize all stim to a variance of 1
    for kk=1:numStim
        theStim(kk).stim=theStim(kk).stim*sqrt(1/var(theStim(kk).stim(:)));
    end;
    theStim=theStim(1:5); % use only first 5 textures
    numStim=5;
    

    % parameters for fitting weibulls and calculating threshold
    psygamma=1/numStim; % should be set to 1/N, where N is the number of stimulus alternatives (i.e., guessing rate)
    psydelta=0.01;
    psybeta=1.5;
    thresholdlevel=0.5;
    mintrialforthreshold=20; % min number of thresholds needed to make an attempt to fit a psychometric function to a data set; the data is still stored in a file
    exptdesign.numStim=numStim;
    starttime=GetSecs;

    warning('off','MATLAB:dispatcher:InexactMatch');
    MONTE_CARLO_SIM=0;

    % initialize the random number generator
    randn('state',sum(100*clock));

    % for playing sounds using 'snd'
    SND_RATE=[];% 8192;

    % data matrix
    data=zeros(1,10); % dm: col 1 is staircase ID(1-4); col 2 is target contrast; col 3 is nzvar; col 4 is response;

    % set up response keys
        kb = GetKeyboardIndices; % list of keyboard indices
        responseKeyboard=max(kb); % my guess of which one we'll be using

    escapeKey = KbName('escape');
    if ismac
       presentKey = KbName('q');
       absentKey = KbName('p');
    else
        presentKey = KbName('KP_End'); % Make sure to use this line for Fisk
        absentKey = KbName('KP_Down'); % Make sure to use this line for Fisk
    end
    

    % convert stimulus duration from seconds to frames
    stimframes=round(displayrate*exptdesign.duration);
    fixpntoffsetframes=round(displayrate*exptdesign.fixpntstimoffset);
    if fixpntoffsetframes<1
        fixpntoffsetframes=1;
    end;

    % make sounds for feedback, etc.
    introsnd=makesnd(600,.2,.6);
    intervalsnd=makesnd(300,exptdesign.duration,.6);
    corrsnd=makesnd(400,.09,.6);
    wrongsnd=makesnd(200,.09,.7);


    % this is the screen upon which the image is to be displayed.
    screenNumbers = Screen('Screens'); % identify number of screens
    defarg('mainscrs',max(screenNumbers)); % define mainscrs as the highest screenNumber

    AssertOpenGL; % added Nov 30/09 for compatibility with OSX, ZH
    numBuffers=2;
    oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
    oldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1);

    % set screen resolution and store old settings
    screenWidth = 1920; % 1024; % 1280
    screenHeight = 1080; % 768; % 1024
    screenFrequency = 120; % 60;% 85
    screenPxSize = 32; %32
    %oldResolution = Screen('Resolution', mainscrs, screenWidth, screenHeight, screenFrequency, screenPxSize);

%     % calibrate monitor # adapted april 22, 2018 to run without
%     bit-stealing and using tim's calibration.

    switch(calibrationMethod)
        case 'bitStealing'
            scrinfo.calfile     = 'curCalRecTmpFileADJUSTED.mat';
            calfitrec           = pbReadCalibrationFile(scrinfo.calfile);
            avgLum = calfitrec.lmaxminave(3);
            cmin=(calfitrec.lmaxminave(2)-calfitrec.lmaxminave(3))/calfitrec.lmaxminave(3);
            cmax=(calfitrec.lmaxminave(1)-calfitrec.lmaxminave(3))/calfitrec.lmaxminave(3);
            L=calfitrec.caldata(:,5);
            B=calfitrec.caldata(:,4);
            rgbMat=calfitrec.caldata(:,1:3);
            
        case 'psychophysical'
            gamma=1.447;
            cmin=(0-160)/(160);
            cmax=(255-160)/(160);
            
    end

    [w wrect]=Screen('OpenWindow',mainscrs, 0,rect0,[],numBuffers);


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
     fixpnt = [0 0 8 8]; fixpnt=CenterRect(fixpnt, wrect);
     stimRect = [0 0 256 256];
     destRect = CenterRect(stimRect, wrect);
     boxrect = [0 0 264 264];
     boxrect = CenterRect(boxrect,wrect);
     
     respRect(1,:) = [0,0,256,256]; respRect(1,:) = CenterRect(respRect(1,:), wrect);
     respRect(2,:) = [0,0,256,256]; respRect(2,:) = CenterRect(respRect(2,:), wrect);
     respRect(1,:) = OffsetRect(respRect(1,:), -200, 0);
     respRect(2,:) = OffsetRect(respRect(2,:), 200, 0);
     
     numresp = 2;
 
    % start of the scan...
    HideCursor; % this hides the mouse cursor
    starttime=GetSecs;

    % light adapt OSX
     adaptTime = adaptseconds;
     adaptpause(w,wrect,adaptTime,0);

     err=Snd('Open'); % open the sound buffer
     err=Snd('Play',introsnd,SND_RATE); err=Snd('Play',corrsnd,SND_RATE); err=Snd('Play',wrongsnd,SND_RATE);
    %sound(introsnd); 
    
    FlushEvents;
    WaitSecs(1);
    
    Screen('DrawText',w,'Please press SPACE when ready to begin.',fixPntX/2,fixPntY);
    Screen('DrawText',w,'1 = present, 2 = absent.',fixPntX/2,fixPntY+60);
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
    
   % for z = 1:2
    
    z=randomcondition(2);
    condcount=0;
   
    while ((alldone==0)&(quitflag==0))
	stime=GetSecs; % get the start time for this trial; we'll use this later
	curStim=randomcondition(exptdesign.numStim); % randomly select the faceID for this trial
	%gotone=0;
	%while (gotone==0)
	%	condID=randomcondition(exptdesign.numnz);
        condID=z;
		%if (~psyfuncfinished(constimrec(condID))) gotone=1; end;
	%end;

 	nzvar=constimrec(condID).appspec;	% noise variance
 	[stim,nzseed]=noise2d(stimpix,nzvar,cmin,cmax,0);
    curStimVariance=constimGetValue(constimrec(condID));
    if curStimVariance==0
		corresp = 1;
	else
		corresp = 2;
    end
    
   tmpStim=theStim(curStim).stim*sqrt(curStimVariance); % this formula works because the faces have a variance of 1
   finalStim=stim+tmpStim; % add noise to face
    
    switch(calibrationMethod)
        case 'bitStealing'
            tmpStimLum=avgLum*(1+finalStim); % convert image from contrast to luminance values
            tmpStimBS=pbLum2BS(tmpStimLum,L,B);  % bits-stealing 
            tmpStimFinal=pbBitStealing2RGB(tmpStimBS, rgbMat,0); % bit-stealing to RGB            
        case 'psychophysical'
            avgind=(160/255)^(gamma)*255;
            tmpStimLum=avgind*(1+finalStim); % convert image from contrast to luminance values
            tmpStimFinal=(tmpStimLum/255).^(1/gamma)*255;
    end
            
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
    
     
    %draw thumbnail images OS X
    time1=GetSecs;
    timeThumb=time1+.1;
    while(time1<timeThumb)
        Screen('glPoint',w,0,fixPntX,fixPntY,8);
        [time1]=Screen('Flip', w);
    end;
     ListenChar(2);
     FlushEvents('keyDown');
     
        gotresponse=0; response=0;
    while (gotresponse==0)
        [keyIsDown,secs,keyCode] = KbCheck;
                if keyIsDown==1
                    if keyCode(presentKey)==1
                        gotresponse=1; response = 2;
                    elseif  keyCode(absentKey)==1;
                        gotresponse=1; response = 1;
                    elseif  keyCode(escapeKey)==1
                        gotresponse=1;
                        Screen('CloseAll');
                        quitflag=1
                    end
                end
                
    end
        
    HideCursor; % this hides the mouse cursor
    ListenChar(0);

    if quitflag==1 break;  end;
    

    rlatency=GetSecs-stimofftime;

    % auditory feedback
	if (response > 0)
		correct=(response==corresp);
		constimrec(condID)=psyfuncUpdate(constimrec(condID),correct); % update the constant stimuli data structure
		if correct
			%sound(corrsnd); 
 			err=Snd('Play',corrsnd,SND_RATE);
		else
			%sound(wrongsnd);
 			err=Snd('Play',wrongsnd,SND_RATE);
            
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
   % end
   
   %%%  FOR BLOCKED NOISE (ZH nov 2013)
   if constimrec(z).alldone==1
       condcount=condcount+1;
       
       if condcount==1
       
        Screen('DrawText',w,'Condition 2; Press SPACE when ready.',fixPntX/2,fixPntY);
        Screen('DrawText',w,'1 = present, 2 = absent.',fixPntX/2,fixPntY+60);
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
       end
       
       
       if z == 1 z=2; elseif z==2 z = 1; end
   
   end
		
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
 %   end;
    %end; % while ((alldone==0)&(quitflag==0))

    %% trialswritefile;
    % write data files to disk
    cd(matdatadir);
    dt=dir; tmp=size(dt); kk=tmp(1);
    found=1;
    k=1;
    while found
        matfname=['grp',num2str(trialspervalue(groupID)),'_ID',sidnum,'_',strcat(stimulusSet{sstimset}), '_N',num2str(k)];
        testname=[matfname,'.mat'];
        tmp=0;
        for n=1:kk
            tmp(n)=strcmp(lower(testname),lower(dt(n).name));
        end;
        found=max(tmp);
        k=k+1;
    end;
    
    thedate=date;
    clear images facestim thumbnail tmpStim tmpStimBS tmpStimFinal tmpStimLum stim rgbMat finalStim B L theStim theStimulus3; % we don't need these any more, so delete 'em
    save(matfname); % save everything else to a mat file
    
    cd(mainpath);
    disp(['workspace stored in file ',testname]);
%     cd(mainpath);

    cd(textdatadir);
%     csvwrite(['pcorrect_',num2str(sidnum),'_',num2str(trialspervalue(groupID)),'trials_',strcat(stimulusSet{sstimset}),'.csv'],pcorrect)

    textfname=['grp',num2str(trialspervalue(groupID)),'_ID',sidnum,strcat(stimulusSet{sstimset})];
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
    %count=fprintf(fid,'%s\n',['Calibration File: ',scrinfo.calfile]);
    %count=fprintf(fid,'%s\n',['Avg Luminance: ',num2str(calfitrec.lmaxminave(3))]);
    %count=fprintf(fid,'%s\n',['Display Frame Rate (Hz): ',num2str(exptResolution.hz)]);
    %count=fprintf(fid,'%s \t %s \t %s\n','Display Size (pixels): ',['Width: ',num2str(calfitrec.displaycm(1))],['Height: ',num2str(calfitrec.displaycm(2))]);
    %count=fprintf(fid,'%s\n',['Display set to ',num2str(exptResolution.pixelSize),' bits per pixel']);
    count=fprintf(fid,'%s\n',['Stimulus duration (sec): ',num2str(exptdesign.duration)]);
    count=fprintf(fid,'%s\n',['Time between fixation point offset and stimulus onset (sec): ',num2str(exptdesign.fixpntstimoffset)]);
    count=fprintf(fid,'%s\n',['Inter-trial interval (sec):',num2str(exptdesign.intertrial)]);
    count=fprintf(fid,'%s\n',['Light Adaptation Duration (sec):',num2str(exptdesign.adaptseconds)]);
    count=fprintf(fid,'%s\n',['Viewing distance (cm):',num2str(exptdesign.viewingdistcm)]);


    count=fprintf(fid,'%s\n\n',['Matlab workspace stored in file: ',matfname]);
    count=fprintf(fid,'%s\n',['Data were fit with a weibull function: Gamma = ',num2str(psygamma),'; Delta = ',num2str(psydelta)]);
    count=fprintf(fid,'%s\n',['Identification threshold was defined as the ',num2str(thresholdlevel*100),'% correct point on the psychometric function.']);
    count=fprintf(fid,'%s \t %s \t %s \t %s \n','Ext. Noise Var.','Stim. Threshold Var.','Alpha','Beta');
    
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

    cd(mainpath); % restore original path
    ShowCursor(0);
    Screen('CloseAll');
    

% end % function