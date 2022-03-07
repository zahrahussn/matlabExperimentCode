    %% Multiple observation 2IFC detection; ZH Nov 2019
    %% Textures in one noise level, at one contrast
    %% First find detection threshold using QUEST. Then use threshold for
    %% multiple observation experiment.
    clear variables;
Screen('Preference', 'SkipSyncTests', 1);
debug=true ;
 if debug
    rect0 = [0,0,600,600];
 else
    rect0 = [];
 end
    
% other method = bitStealing; zh april 22, 2018, with help from jb
%   calibrationMethod='psychophysical';
calibrationMethod='bitStealing';
    

starttime=GetSecs; 
%randn('state',sum(100*clock)); % initialize the random number generator
%rng default
%RandStream.create('mt19937ar','seed',sum(100*clock));
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
defarg('detectTEXTfolder','detectMultTEXTfiles');	% N.B. make sure this folder exists within the folder containing 'trialslab'!
defarg('detectMATfolder','detectMultMATfiles');		% N.B. make sure this folder exists within the folder containing 'trialslab'!

% set the paths
disp('setting path names...');
mfilename='detectMultObs2AFC'; mainfile = [mfilename,'.m'];
eval(['mainpath=which(',QuoteString(mainfile),');']);
mainpath=strrep(mainpath,'experimentCode', 'data'); % modified sept 10, 2018 for github rearrangement
mainpath = mainpath(1:end-2);
textdatadir=[mainpath,'/',detectTEXTfolder];
matdatadir=[mainpath,'/',detectMATfolder];
cd(mainpath);
disp(mainpath);

% stimulus dimensions
defarg('vd',114);			
defarg('stimpix',256);		% size of stimulus in pixels

nv = 0.1;	% external noise variance
numnz=length(nv);	% number of external noises
defarg('trialspervalue',[1,10,50]); % # of trials per contrast level
%value =  0.0001986;

% stimulus timing parameters
defarg('duration',0.2);	% stimulus duration in seconds
defarg('fixpntstimoffset',0.2); % time between fixation point offset and stimulus onset in seconds
defarg('intertrial',1);	% inter-trial interval in seconds; meaninful only when usespace=0 (see next line)
defarg('usespace',0);	% when zero, trials are started automatically; when 1, trials started by clicking mouse near fixation point
defarg('adaptseconds',1); % light adaptation time

% put all of these things into a structure
exptdesign.duration=duration; % stimulus duration (sec)
exptdesign.fixpntstimoffset=fixpntstimoffset; % time between fixation point offset and stimulus onset in seconds
exptdesign.intertrial=intertrial; % inter-trial duration (sec)
exptdesign.usespace=usespace; % use space bar to start each trial?
exptdesign.adaptseconds=adaptseconds; % light adaptation time (sec)
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


stimulusSet = 'Textures_LowB';


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

    disp(['5......COMMENT  (',scomment,')']);
    disp('6......LOAD PREVIOUS SETTINGS');
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
        scomment=[];
        disp('');
        while (isempty(scomment))
            scomment=input('Comment: ','s');
        end;

    case '6'
        load subjsettings;
        

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
        
    
save 'subjsettings' sidnum sgender sage groupID scomment; % save settings
load theStimulus4; % set to low textures, set 2


stimNames={'stim1';'stim2';'stim3';'stim4';'stim5';'stim6';'stim7';'stim8';'stim9';'stim10'};
% stimNames=fieldnames(eval(['theStimulus', num2str(stimset)]));
[numStim,~]=size(stimNames);
for kk=1:numStim
   % theStim(kk).stim=eval(['theStimulus',num2str(sstimset),'.',char(stimNames(kk))]);
    theStim(kk).stim=eval(['theStimulus4.',char(stimNames(kk))]); % set to texture set B
end;

% normalize all stim to a variance of 1
for kk=1:numStim
    theStim(kk).stim=theStim(kk).stim*sqrt(1/var(theStim(kk).stim(:)));
end;
theStim=theStim(1:5); % use only 5 textures
numStim=5;

% % parameters for fitting weibulls and calculating threshold
% psygamma=1/2; % should be set to 1/N, where N is the number of stimulus alternatives (i.e., guessing rate)
% psydelta=0.01;
% psybeta=1.5;
% thresholdlevel=0.5;
 exptdesign.numStim=numStim;
 starttime=GetSecs;

%% set-up quest 
psybeta = linspace(0.01,10,10); % estimate slope of psychometric function. If you don't want this to be free, just set it as 1 value. 
psygamma = 1/2; % chance (lower asymptote of psychometric fit)
psydelta = 0:0.02:0.5; % free lapse rate for upper asymptote. If you don't want tis to be free, set it as 1.
psymin = 0.000001;
psymax = 0.05; 
nsteps = 50; 
stimrange = contrast2db(10.^linspace(log10(psymin),log10(psymax),nsteps)); % the contrast2db function is from dxjones toolbox


psiParamsDomain = { stimrange, psybeta, psygamma, psydelta };

% set up actual quest+ staircase
scQP.param = qpParams( ...
    'nOutcomes', 2, ...
    'stimParamsDomainList', { stimrange }, ...
    'psiParamsDomainList', psiParamsDomain, ...
    'stopRule', 'nTrials', ...
    'verbose', true );
questData = qpInitialize(scQP.param);
for iBlock = 1:2
    questData(iBlock) = questData(1);
end

warning('off','MATLAB:dispatcher:InexactMatch');
MONTE_CARLO_SIM=0;

% initialize the random number generator
%randn('state',sum(100*clock));

% for playing sounds using 'snd'
SND_RATE=[];% 8192;

% data matrix
data=zeros(1,11); % 

% set up response keys
kb = GetKeyboardIndices; % list of keyboard indices
responseKeyboard=max(kb); % my guess of which one we'll be using

escapeKey = KbName('escape');
if ismac
   interval1Key = KbName('LeftArrow');
   interval2Key = KbName('RightArrow');
else
    interval1Key = KbName('KP_End'); % Make sure to use this line for Fisk
    interval2Key = KbName('KP_Down'); % Make sure to use this line for Fisk
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
screenWidth = 1280; % 1280
screenHeight = 1024; % 1024
screenFrequency = 100;% 85
screenPxSize = 32; %32
%oldResolution = Screen('Resolution', mainscrs, screenWidth, screenHeight, screenFrequency, screenPxSize);

% calibrate monitor # adapted april 22, 2018 to run without
% bit-stealing and using tim's calibration.

switch(calibrationMethod)
    case 'bitStealing'
%         scrinfo.calfile     = 'curCalRecTmpFileADJUSTED.mat';
        scrinfo.calfile     = 'curCalRecTmpFileRAW_13-Dec-2021.mat';
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

% Setting up the rects OS X
fixpnt = [0 0 8 8]; fixpnt=CenterRect(fixpnt, wrect);
stimRect = [0 0 256 256];
dstRect=[0 0 256 256]; % destination rect
% destRect = CenterRect(stimRect, wrect);
stim1Loc=[wrect(1) wrect(2) wrect(3)/2, wrect(4)];
stim2Loc=[wrect(3)/2 wrect(2) wrect(3), wrect(4)];
dstRect1=CenterRect(dstRect, stim1Loc); % dest rect centered
dstRect2=CenterRect(dstRect, stim2Loc); % dest rect centered
srcRect=[0 0 256 256]; % source rect, whatever that is
boxrect = [0 0 264 264];
%boxrect = CenterRect(boxrect,wrect);
boxrect1 = CenterRect(boxrect,stim1Loc);
boxrect2 = CenterRect(boxrect,stim2Loc);

% start of the scan...
HideCursor; % this hides the mouse cursor
starttime=GetSecs;

% light adapt OSX
adaptTime = adaptseconds;
adaptpause(w,wrect,adaptTime,0);

Snd('Open'); % open the sound buffer
Snd('Play',introsnd,SND_RATE); Snd('Play',corrsnd,SND_RATE); Snd('Play',wrongsnd,SND_RATE);
%sound(introsnd); 

FlushEvents;
WaitSecs(1);
    
Screen('DrawText',w,'Please press SPACE when ready to begin.',fixPntX/2,fixPntY);
%Screen('DrawText',w,'1 = present, 2 = absent.',fixPntX/2,fixPntY+60);
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

noiseCondition=randperm(2); % constant or variable noise; blocked, 2 blocks;   
curtrial=1;
condID = {'constant','variable'};
escaped=false;
for b = 1:length(noiseCondition) % for length of blocks
    nc=noiseCondition(b);

    for t = 1:trialspervalue(groupID)
        noise1=zeros(256,256); noise2=zeros(256,256);
        
        if noiseCondition(b)== 1 
            [noise0,nzseed0]=noise2d(stimpix,nv,cmin,cmax,0); 
            noise1=noise0;
            nzseed1=nzseed0;
            noise2=noise0;
            nzseed2=nzseed0;
            c=corrcoef(noise1, noise2);
            c=c(1,2);

        elseif noiseCondition(b)== 2
            [noise1,nzseed1]=noise2d(stimpix,nv,cmin,cmax,0); 
            [noise2,nzseed2]=noise2d(stimpix,nv,cmin,cmax,0);
            c=corrcoef(noise1, noise2);
            c=c(1,2);

        end    
        int=randomcondition(2); % interval 1 or 2, for all observations  
        stime=GetSecs; % get the start time for this trial; we'll use this later
        curStim=randomcondition(exptdesign.numStim); % randomly select the texture for this trial
        stimDB = qpQuery(questData(b));
        curStimVariance = db2contrast(stimDB);

        if int==1
            corresp = 1; stim1var = curStimVariance; stim2var=0;
        else
            corresp = 2; stim1var=0; stim2var=curStimVariance;
        end
            
        % fixation point to mark start of new trial
        vbl=GetSecs;
        vblendtime = vbl + 1;
        while (vbl < vblendtime)
            Screen('FillRect',w, [160 160 160]);
            Screen('glPoint',w,255,fixPntX,fixPntY,12);
            [vbl]=Screen('Flip', w); % flip the buffer to the screen
        end
            
        %%%  2IFC contrasts 
        tmpStim1=theStim(curStim).stim*sqrt(stim1var); % this formula works because the stimuli have a variance of 1
        Stim1=noise1+tmpStim1; % add noise to texture

        tmpStim2=theStim(curStim).stim*sqrt(stim2var);
        Stim2=noise2+tmpStim2; % add noise to texture

        switch(calibrationMethod)
            case 'bitStealing'
                Stim1Lum=avgLum*(1+Stim1); % convert image from contrast to luminance values
                Stim2Lum=avgLum*(1+Stim2); % convert image from contrast to luminance values
                Stim1BS=pbLum2BS(Stim1Lum,L,B);  % bits-stealing 
                Stim2BS=pbLum2BS(Stim2Lum,L,B);  % bits-stealing 
                Stim1Final=pbBitStealing2RGB(Stim1BS, rgbMat,0); % bit-stealing to RGB  
                Stim2Final=pbBitStealing2RGB(Stim2BS, rgbMat,0); % bit-stealing to RGB  
            case 'psychophysical'
                avgind=(160/255)^(gamma)*255;
                Stim1Lum=avgind*(1+Stim1); % convert image from contrast to luminance values
                Stim2Lum=avgind*(1+Stim2); % convert image from contrast to luminance values
                Stim1Final=(Stim1Lum/255).^(1/gamma)*255;
                Stim2Final=(Stim2Lum/255).^(1/gamma)*255;
        end

           
            Stim1=Screen('MakeTexture', w, Stim1Final); % pre- DrawTexture preparation
            Stim2=Screen('MakeTexture', w, Stim2Final); % pre- DrawTexture preparation

            trialStartTime=GetSecs;
            gotime=stime+exptdesign.intertrial; % wait here

            while (GetSecs<gotime), end;

            vbl=GetSecs;
            vblendtime = vbl + 0.1; % vbl + 1
            while (vbl < vblendtime)
                Screen('FillRect',w, [160 160 160]);
                [vbl]=Screen('Flip', w); 
            end

            % interval 1
            time0=GetSecs;
            timeStim=time0+.2;
            while(time0<timeStim)
                Screen('DrawTexture', w, Stim1, srcRect, dstRect1);  % put the image on the screen
                Screen('FrameRect', w, 10, boxrect1, 1); % put the frame around the stim on the screen
                Screen('DrawTexture', w, Stim2, srcRect, dstRect2);  % put the image on the screen
                Screen('FrameRect', w, 10, boxrect2, 1); % put the frame around the stim on the screen
                [time0]= Screen('Flip', w); % make it appear
            end

%             intTime=GetSecs;
%             intTime2=intTime+0.100;
%             while intTime<intTime2
%                 Screen('FillRect',w,[160 160 160])
%                 intTime=Screen('Flip',w);
%             end;

            % interval 2
%             time0=GetSecs;
%             timeStim=time0+.2;
%             while(time0<timeStim)
%                 Screen('DrawTexture', w, Stim2, srcRect, dstRect);  % put the image on the screen
%                 Screen('FrameRect', w, 10, boxrect, 1); % put the frame around the stim on the screen
%                 [time0]= Screen('Flip', w); % make it appear
%             end
             stimofftime=GetSecs;

            % wait for response
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
                            if keyCode(interval1Key)==1
                                gotresponse=1; response = 1;
                            elseif  keyCode(interval2Key)==1;
                                gotresponse=1; response = 2;
                            elseif  keyCode(escapeKey)==1
                                gotresponse=1;
                                % Screen('CloseAll');
                                % ShowCursor(0)
                                escaped=true;
                            end
                        end
            end

            %HideCursor; % this hides the mouse cursor
            ListenChar(0);
            rlatency=GetSecs-stimofftime;

            % auditory feedback on 5th observation
            if (response > 0)
                correct=(response==corresp);
                    if correct
                        err=Snd('Play',corrsnd,SND_RATE);
                    else
                        err=Snd('Play',wrongsnd,SND_RATE);
                    end
            end

            % erase thumbnail images OSX
            Screen('FillRect',w, [160 160 160]);
            timeInterval=GetSecs;
            timeInterval2=GetSecs+1; % 0.500
            while timeInterval<timeInterval2
                Screen('FillRect',w,[160 160 160]);
                Screen('glPoint',w,0,fixPntX,fixPntY,8); %%%%%%%%%%%%%%%%%
                timeInterval=Screen('Flip',w);
            end

            if (response>0)
                data(curtrial,:)=[curtrial,b,t,nc,curStim,curStimVariance,int,response,correct,rlatency,c]; % update data matrix
                curtrial=curtrial+1; % increment trial counter
            end % if (response > 0)   
            questData(b) = qpUpdate(questData(b), stimDB, correct+1);
            
            % This needs to be at the end of the trial loop for the program
            % to quit properly when escape is pressed. Do not move! JB
            if keyCode(escapeKey)==1
                break; 
            end
    end % end of trials for this block
 
    % Do not remove! 
    if escaped
                break; 
    end        
    %%%  mark the end of the block
    if b<length(noiseCondition)
        Screen('DrawText',w,'Next block. Press SPACE when ready.',fixPntX/2,fixPntY);
        Screen('Flip',w);
        [secs, keyCode, deltaSecs] = KbWait;
        while keyCode(KbName('space'))~=1;
            [secs, keyCode, deltaSecs] = KbWait;
        end
        WaitSecs(1);
    end
end

Screen('DrawText',w,'Phase one done.',fixPntX/1.5,fixPntY);
Screen('Flip',w);
WaitSecs(2);
Screen('CloseAll');
ShowCursor(0);
%% trialswritefile;
% write data files to disk
cd(matdatadir);
dt=dir; tmp=size(dt); kk=tmp(1);
found=1;
k=1;
while found
    matfname=['grp',num2str(trialspervalue(groupID)), '_detectionThreshold','_ID',num2str(sidnum),'_TexturesB', '_N',num2str(k)];
    testname=[matfname,'.mat'];
    tmp=0;
    for n=1:kk
        tmp(n)=strcmp(lower(testname),lower(dt(n).name));
    end;
    found=max(tmp);
    k=k+1;
end;

thedate=date;
clear images facestim thumbnail tmpStim tmpStimBS tmpStimFinal tmpStimLum stim rgbMat finalStim B L theStim theStimulus4; % we don't need these any more, so delete 'em
save(matfname); % save everything else to a mat file

cd(mainpath);
disp(['workspace stored in file ',testname]);
%     cd(mainpath);

cd(textdatadir);

textfname=['grp',num2str(trialspervalue(groupID)), '_detectionThreshold','_ID',num2str(sidnum),'_TexturesB'];
testname=[textfname,'.txt'];
datafilename=testname;

figure; 
for iBlock = 1:length(noiseCondition)
    fprintf('--------------------\nFitted parameters for %s condition\n',condID{noiseCondition(iBlock)})
    
    %% Find out QUEST+'s estimate of the stimulus parameters, obtained
    % on the gridded parameter domain.
    psiParamsIndex = qpListMaxArg(questData(iBlock).posterior);
    psiParamsQuest = questData(iBlock).psiParamsDomain(psiParamsIndex,:);
    fprintf('Max posterior QUEST+ parameters: %0.1f, %0.1f, %0.1f, %0.2f\n', ...
        psiParamsQuest(1),psiParamsQuest(2),psiParamsQuest(3),psiParamsQuest(4));

    %% Find maximum likelihood fit.  Use psiParams from QUEST+ as the starting
    % parameter for the search, and impose as parameter bounds the range
    % provided to QUEST+.
    psiParamsFit(iBlock,:) = qpFit(questData(iBlock).trialData,questData(iBlock).qpPF,psiParamsQuest,questData(iBlock).nOutcomes,...
        'lowerBounds', [stimrange(1) psybeta(1) psygamma(1) psydelta(1)],'upperBounds',[stimrange(end) psybeta(end) psygamma(end) psydelta(end)]);
  
    fprintf('Maximum likelihood fit parameters: %0.1f, %0.1f, %0.1f, %0.2f\n', ...
        psiParamsFit(iBlock,1),psiParamsFit(iBlock,2),psiParamsFit(iBlock,3),psiParamsFit(iBlock,4));
    fprintf(['Threshold = ', num2str(db2contrast(psiParamsFit(iBlock,1))) '\n\n']);

    subplot(1,length(noiseCondition),iBlock)
    hold on
    stimCounts = qpCounts(qpData(questData(iBlock).trialData),questData(iBlock).nOutcomes);
    stim = [stimCounts.stim];
    stimFine = linspace(stimrange(1),stimrange(end),100)';
    plotProportionsFit = qpPFWeibull(stimFine,psiParamsFit(iBlock,:));
    for cc = 1:length(stimCounts)
        nTrials(cc) = sum(stimCounts(cc).outcomeCounts);
        pCorrect(cc) = stimCounts(cc).outcomeCounts(2)/nTrials(cc);
    end
    for cc = 1:length(stimCounts)
        h = scatter(stim(cc),pCorrect(cc),100,'o','MarkerEdgeColor',[0 0 1],'MarkerFaceColor',[0 0 1]);
    end
    plot(stimFine,plotProportionsFit(:,2),'-','Color',[1.0 0.2 0.0],'LineWidth',3);
    xlabel('Stimulus Value');
    ylabel('Proportion Correct');
    xlim([stimrange(1) stimrange(end)]); ylim([0 1]);
    title({[condID{noiseCondition(iBlock)} ' noise: threshold = ' num2str(db2contrast(psiParamsFit(iBlock,1)))]});
    drawnow;
    
end
threshold = db2contrast(mean(psiParamsFit(:,1)));
fprintf(['Average threshold across noise conditions = ', num2str(threshold) '\n\n']);


%%
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
% count=fprintf(fid,'%s\n',['Display Frame Rate (Hz): ',num2str(exptResolution.hz)]);
count=fprintf(fid,'%s \t %s \t %s\n','Display Size (pixels): ',['Width: ',num2str(calfitrec.displaycm(1))],['Height: ',num2str(calfitrec.displaycm(2))]);
% count=fprintf(fid,'%s\n',['Display set to ',num2str(exptResolution.pixelSize),' bits per pixel']);
count=fprintf(fid,'%s\n',['Stimulus duration (sec): ',num2str(exptdesign.duration)]);
count=fprintf(fid,'%s\n',['Time between fixation point offset and stimulus onset (sec): ',num2str(exptdesign.fixpntstimoffset)]);
count=fprintf(fid,'%s\n',['Inter-trial interval (sec):',num2str(exptdesign.intertrial)]);
count=fprintf(fid,'%s\n',['Light Adaptation Duration (sec):',num2str(exptdesign.adaptseconds)]);
count=fprintf(fid,'%s\n',['Viewing distance (cm):',num2str(exptdesign.viewingdistcm)]);

count=fprintf(fid,'%s\n\n',['Matlab workspace stored in file: ',matfname]);
count=fprintf(fid,'%s\n',['Detection threshold for condition ' condID{noiseCondition(1)} ' was estimated as ' num2str(db2contrast(psiParamsFit(1,1)))]);
count=fprintf(fid,'%s\n',['Data were fit with a weibull function: Gamma = ',num2str(psiParamsFit(1,3)),'; Delta = ',num2str(psiParamsFit(1,4))]);
count=fprintf(fid,'%s\n',['Detection threshold for condition ' condID{noiseCondition(2)} ' was estimated as ' num2str(db2contrast(psiParamsFit(2,1)))]);
count=fprintf(fid,'%s\n',['Data were fit with a weibull function: Gamma = ',num2str(psiParamsFit(2,3)),'; Delta = ',num2str(psiParamsFit(2,4))]);
count=fprintf(fid,'%s\n',['Average threshold was estimated as ', num2str(threshold)]);

%count=fprintf(fid,'%s \t %s \t %s \t %s \n','Ext. Noise Var.','Stim. Threshold Var.','Alpha','Beta');

count=fprintf(fid,'%s \t %s \n','Face ID: ','Name');
for kk=1:exptdesign.numStim
    count=fprintf(fid,'%s\t %s\n',num2str(kk),char(stimNames(kk)));
end;
count=fprintf(fid,'\n%s\n','DATA');
count=fprintf(fid,'%s \t %s \t %s \t %s \t %s \t %s \t %s \t %s \t %s \t %s \t %s \n','trial #', 'block', 'blockTrial', 'conditionID','stim ID', 'stimContrast','interval', 'response','correct','RT(sec)', 'noiseCorrelation');

[numtrials,tmp0]=size(data);

for kk=1:numtrials, fprintf(fid,'%i \t %i \t %i \t %i \t %i \t %8.6f \t %8.6f \t %i \t %i \t %i \t %i \n',data(kk,1:11)); end
fclose(fid);

cd(mainpath);
disp(['data stored in text file ',datafilename]);

totalTrial = data(end,1);

cd(mainpath); % restore original path

detectMultObs2AFC;
