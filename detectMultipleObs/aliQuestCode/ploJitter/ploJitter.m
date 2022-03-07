%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% tuning to the horizontal structure of textures using vertical noise
%
% Notes:
% - Train individuals on horizontal structure alone.
% - Ensure they do not learn the vertical structure (or the horizontal +
% vertical combination) by having random vertical structure (i.e. noise)
% on every single trial
% - have no noise on response screen
% - train them in a staircase, where horizontal contrast starts really
% high, and thus they will easily be able to detect the diagnostic
% information
% function vertNzTrain(subjID,traintype,day,testing,autopilot)

function ploJitter(subjID,day)

traintype=1;
stimset=1;
testing=0;
autopilot=0;

debug=true;
 if debug
    rect0 = [0,0,600,600];
 else
    rect0 = [];
 end


% presence of vertical noise determined with traintype (no=0, yes=1)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% initial setup
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% set-up staircase (questplus)... new values following simulations. 
sc.beta = linspace(-10,-0.01,10); % estimate slope of psychometric function. If you don't want this to be free, just set it as 1 value. 
sc.gamma = 1/6; % chance (lower asymptote of psychometric fit
sc.delta = 0:0.02:0.5; % free lapse rate for upper asymptote. If you don't want tis to be free, set it as 1.
sc.min = 0.005; % minimum is 2 because this is a motion stimulus.
sc.max = 0.5; % half framerate = half second
sc.nsteps = 21; % frames.
sc.stimrange = contrast2db(10.^linspace(log10(sc.min),log10(sc.max),sc.nsteps)); % the contrast2db function is from dxjones toolbox

psiParamsDomain = { sc.stimrange, sc.beta, sc.gamma, sc.delta };

% set up actual quest+ staircase
scQP.param = qpParams( ...
    'nOutcomes', 2, ...
    'stimParamsDomainList', { sc.stimrange }, ...
    'psiParamsDomainList', psiParamsDomain, ...
    'stopRule', 'nTrials', ...
    'verbose', true );
scQP.questData = qpInitialize(scQP.param);
scQP.ezcond = min(sc.stimrange);
scQP.eztrials = 5; % force 5 easy trials
scQP.sctrials = 100; % have 40 trials determined by q+
scQP.ScOrEz = [ones(scQP.eztrials, 1); zeros(scQP.sctrials,1)]; % first 5 trials are forced to be easy... why? on every trial, check you know to either pull from q+ or force an ez trial by indexing this variable.

HideCursor;

%check inputs
switch nargin
    case 0
        subjID='test';
        traintype=1;
        testing=0;
    case 1
        traintype=1;
        testing=0;
    case 2
        testing=0;
end

% if traintype==1



white       = [255 255 255];
black       = [0 0 0];
gray        = [100 100 100];
dinRect     = [0 0 200 200];
dinBRect    = [0 0 200 200];


fprintf('BEGINNING EXPERIMENT \n');

% PsychJavaTrouble; % fixes some Java issues

% Disable psychtoolbox test screen
Screen('Preference','VisualDebugLevel',3);

% reset random number generators
[InitialRandSeed,WhichRandGenerator] = ClockRandSeed();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set up calibration information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get calibration information
% scrinfo.calfile ='pacemaker_1024x768_85Hz_March12_2015.mat';
scrinfo.calfile ='radium_Oct15-2014_1024x768x85Hz.mat';
fprintf('reading calibration file and setting up screen...\n');
calfitrec=pbReadCalibrationFile(scrinfo.calfile);
rgbMat = calfitrec.caldata(:,1:3); % rgb matrix
B = calfitrec.caldata(:,4); % array of bit-stealing numbers
L = calfitrec.caldata(:,5); % array of luminance values
scrinfo.number=max(Screen('Screens'));
scrinfo.width=calfitrec.displaypixels(1);
scrinfo.height=calfitrec.displaypixels(2);
scrinfo.framerate=calfitrec.framerate;
scrinfo.pixelsize=calfitrec.pixelsize;
scrinfo.pixpercm=mean(calfitrec.displaypixels ./ calfitrec.displaycm);
dcNumber = calfitrec.backgroundNumber;
RGBgrey=pbBSindex2RGB(dcNumber);
avgLum = pbBitStealing2Lum(calfitrec.backgroundNumber,L,B);
%try
 %   oldResolution = Screen('Resolution', scrinfo.number, scrinfo.width, scrinfo.height, scrinfo.framerate);
%catch resError
 %   oldResolution = Screen('Resolution', 1);
%end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% open and set up windows
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set up windows
mainScreen=scrinfo.number;

% Open a double buffered fullscreen window and draw a gray background
numBuffers=2;
[window,wrect]=Screen('OpenWindow',mainScreen, 0,rect0,[],numBuffers);
w=window; % for compatibility with some of PJB's code
Screen('FillRect',window, RGBgrey);

Screen('Flip', window);

%define window parameters
screenWidth=wrect(RectRight)-wrect(RectLeft);
center = [wrect(3) wrect(4)]/2;	% coordinates of screen center (pixels)
fps=Screen('FrameRate',window); % frames per second
if(fps==0)
    fps=60;
    fprintf('WARNING: using default frame rate of %i Hz\n',fps);
end

% set text properties for our screen
TxtSize=18;
Screen('TextFont',window, 'Courier');
Screen('TextSize',window, TxtSize);
Screen('TextStyle', window, 0);

% Enable alpha blending with proper blend-function. We need it
% for drawing of smoothed points:
Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% define various control parameters and system settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Defining variables... \n');

% Make sounds
SND_RATE=8192;
introsnd=makesnd(600,.2,.6,SND_RATE);
corrsnd=makesnd(700,.3,.6,SND_RATE);
wrongsnd=makesnd(200,.3,.7,SND_RATE);


% Set up response keys
% ControlKeyboard = max(GetKeyboardIndices);    % takes input from EEGlab keyboard only
controlKeyboard = -1;           % takes input from all keyboards
controlKeyboard = min(GetKeyboardIndices());
escapeKey = 41;

% fixation point
fixPntX = round( abs(wrect(RectRight)-wrect(RectLeft)) / 2 );
fixPntY = round( abs(wrect(RectBottom)-wrect(RectTop)) / 2 );
fixPntSize = 10;



% timing variables
pretrialDelay = 0.2; % delay between previous response and onset of next fixation point
fixpntDuration = 0.5; % duration of fixation point, in seconds (+ random interval from 0-300ms)
stimOffsetTime1 = 0.2; % delay, in seconds, between offset of fixation point and onset 1st stimulus

stimDuration = 0.15; % stimulus duration in seconds
stimOffsetRespOnset = 0.5; % delay between stimulus offset and response screen onset
adaptDuration = 60;  % Dark adaptation length
if testing==1 || day==1
    adaptDuration=2;
end

if autopilot==1 % this is done just to make the autopiloting faster
    pretrialDelay = 0.01; % delay between previous response and onset of next fixation point
    fixpntDuration = 0.01; % duration of fixation point, in seconds (+ random interval from 0-300ms)
    stimOffsetTime1 = 0.01; % delay, in seconds, between offset of fixation point and onset 1st stimulus

    stimDuration = 0.15; % stimulus duration in seconds
    stimOffsetRespOnset = 0.01; % delay between stimulus offset and response screen onset
    adaptDuration = 2;  % Dark adaptation length
end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%SET UP textures & filters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('loading texture images...\n');
% load faceStruct.mat

if stimset==1
    load textureStim.mat
elseif stimset==2
    load textureStimC.mat
elseif stimset==3
    load textureStimD.mat
end

tmpStim = textureStim;

imsize=160;
numTex = 6;

avgStim = zeros(imsize,imsize);



fprintf('Setting up filters... \n');

hf=zeros(imsize,imsize);

% horizontal filters
baseO=0;
ho1 = baseO - 30;
ho2 = baseO + 30;
hf(:,:) = filter2d([],[],ho1,ho2,imsize);

base1 = 90;
vo1 = base1 - 30;
vo2 = base1 + 30;
sflo = 2;
sfhi = 4;
vsf = filter2d(sflo,sfhi,vo1,vo2,imsize); % thefilter=filter2d(lowf,highf,orient1,orient2,dim)


for sn=1:numTex
    curStim = squeeze(tmpStim(:,:,sn));
    curStim = imresize(curStim, [imsize imsize]);
    curStim = curStim - mean(curStim(:)); % center on zero
    curSD = sqrt(var(curStim(:)));
    curStim = curStim .* (1/curSD);
    theTextures(:,:,sn) = curStim;
    
    filtTextures(:,:,sn) = bpimage(curStim,hf(:,:),0);
    
    avgStim(:,:) = avgStim + curStim;
    
end

avgStim(:,:) = avgStim ./ numTex;
avgStim = avgStim - mean(avgStim(:));
avgSD = sqrt(var(avgStim(:)));
avgStim = avgStim .* (1/avgSD);

nr = imsize;

SNR = 1; %1.2;
stimSD = 0.035;

% this stuff will probably be ignored since quest+ was added...
stimSDresp = 0.1;
nzSDstim = 10.^(log10(stimSD) .* SNR); 
nzSDresp = 10.^(log10(stimSDresp) .* SNR);
numCOs=1; % only training on horizontal condition
numRepeats = 115; % 10 repetitions per condition/face combination (training is 2 blocks, so this is l

whiteNzSD = 0.1; % this is added on top of all trials (but not during response screen)

numTrials=numTex*numCOs*numRepeats;

breakpoints = round([numTrials*0.2, numTrials*0.4, numTrials*0.6, numTrials*0.8]);

%
% set up conditions
stimulusConditions=zeros(numTrials,2);
stimulusConditions(:,1)=repmat(linspace(1,numTex,numTex),1,numCOs*numRepeats)'; %textures
stimulusConditions(:,2)=repmat((kron([1],ones(1,numTex))),1,numRepeats)'; % center orientation


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % SETUP STAIRCASE
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% % contrast values
% xmin = 0.003;
% xmax = 0.3;
% logrange = log10(xmax) - log10(xmin);
% stepsPerLogUnit = 20;
% cval = linspace(log10(xmin),log10(xmax),logrange*stepsPerLogUnit);
% cval = 10 .^ cval; % array of possible contrast levels
% 
% % sc parameters
% numStaircases = 6;
% down = 1; % to make a 1-down/1-up staircase
% firststep = 8; % 8; % initial step size
% steparray = [7 6 5 4 3 2 1]; % step sizes throughout the experiment
% switchafterRevnum = [2 3 4 5 6 7 8];  % after which reversals should we narrow the step size
% startvalue = length(cval); % - round(0.2*length(cval)); % start at 80% of max
% trialsPerStaircase = numTex * numRepeats; % hardcoded for now, but should be numTex * numRepeats
% maxtrials = trialsPerStaircase;
% maxrevs = trialsPerStaircase; % maxReversals could be used to terminate staircases, but not really used here
% 
% numTrials = trialsPerStaircase * 2; % do 2 staircases per block
% 
% % initialize
% for kk = 1:numStaircases
%     allSCs(kk) = scInit(down,cval,startvalue,maxtrials,maxrevs);
%     allSCs(kk) = scInitStepSize(allSCs(kk),firststep,steparray,switchafterRevnum);
% end
% 
% scTrialCounter = zeros(numStaircases);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%START EXPERIMENT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

curTrial=0;

curType = traintype;
rotAngle=0;
respRotAngle=rotAngle;


% Make thumbnail stuff:
itemLocs = zeros(6,2);
hv = screenWidth / 3;
thumbnailsize=round(imsize/1.25);
thumbnailImages=zeros(thumbnailsize,thumbnailsize,numTex);
% for kk=1:numTex
%     if (kk<=(numTex/2))
%         itemLocs(kk,1)= wrect(RectTop)+round(1*thumbnailsize);
%         itemLocs(kk,2) = wrect(RectLeft) + round(hv/1.33+(kk-1)*(hv/1));
%     else
%         itemLocs(kk,1)= wrect(RectBottom)-round(1*thumbnailsize);
%         itemLocs(kk,2) = wrect(RectLeft) + round(hv/1.33+(kk-4)*(hv/1));
%     end;
% end;
for kk=1:numTex
    if (kk<=(numTex/2))
        itemLocs(kk,1)= wrect(RectTop)+round(1*thumbnailsize);
        itemLocs(kk,2) = wrect(RectLeft) + round(hv/2+(kk-1)*(hv));
    else
        itemLocs(kk,1)= wrect(RectBottom)-round(1*thumbnailsize);
        itemLocs(kk,2) = wrect(RectLeft) + round(hv/2+(kk-4)*(hv));
    end;
end;

% % unfiltered thumbnails
%     for kk=1:numTex
%         thumbnailImagesF(:,:,kk)=imresize(theTextures(:,:,kk),[thumbnailsize,thumbnailsize]);
%         thumbnailImagesF(:,:,kk)=imrotate(thumbnailImagesF(:,:,kk),respRotAngle);
%         thumbnailImagesF(:,:,kk)=avgLum*(1+respSD*thumbnailImagesF(:,:,kk));
%         thumbnailImagesF(:,:,kk)=pbLum2BS(thumbnailImagesF(:,:,kk),L,B);
%     end;

% horz filtered thumbnails
for kk=1:numTex
    
    thumbnailImagesH(:,:,kk)=imresize(filtTextures(:,:,kk),[thumbnailsize,thumbnailsize]);
    thumbnailImagesH(:,:,kk)=imrotate(thumbnailImagesH(:,:,kk),respRotAngle);
    tmpthumb = squeeze(thumbnailImagesH(:,:,kk));
    thumbnailImagesH(:,:,kk) = (stimSDresp/sqrt(var(tmpthumb(:)))) .* thumbnailImagesH(:,:,kk);
    thumbnailImagesH(:,:,kk)=avgLum*(1+thumbnailImagesH(:,:,kk));
    thumbnailImagesH(:,:,kk)=pbLum2BS(thumbnailImagesH(:,:,kk),L,B);
    
    thumbnailImagesHnz(:,:,kk)=imresize(filtTextures(:,:,kk),[thumbnailsize,thumbnailsize]);
    
end;

% % vert filtered thumbnails
%     for kk=1:numTex
%         thumbnailImagesVr(:,:,kk) = bpimage(theTextures(:,:,kk),vf1(:,:),0);
%         if curType==1
%             txavg = bpimage(avgStim,vf2(:,:),0);
%             thumbnailImagesVr(:,:,kk) = thumbnailImagesVr(:,:,kk)+txavg;
%         else
%             thumbnailImagesVr(:,:,kk) = thumbnailImagesVr(:,:,kk);
%         end
%         thumbnailImagesV(:,:,kk)=imresize(thumbnailImagesVr(:,:,kk),[thumbnailsize,thumbnailsize]);
%         thumbnailImagesV(:,:,kk)=imrotate(thumbnailImagesV(:,:,kk),respRotAngle);
%         tmpthumb = squeeze(thumbnailImagesV(:,:,kk));
%         thumbnailImagesV(:,:,kk) = (respSD/sqrt(var(tmpthumb(:)))) .* thumbnailImagesV(:,:,kk);
%         thumbnailImagesV(:,:,kk)=avgLum*(1+thumbnailImagesV(:,:,kk));
%         thumbnailImagesV(:,:,kk)=pbLum2BS(thumbnailImagesV(:,:,kk),L,B);
%     end;




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%make filename for this block
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

oldpath=pwd;
tmp=mfilename('fullpath'); % complete pathname to this m-file
s = strfind(tmp,'/ploLong');
exptPath = cd;
dataPath = [exptPath,'/data/'];
cd(exptPath);

% create file name:
cd(dataPath);
d=dir('*.mat');
numfiles=length(d);
gotName=0;
N=0;
while(gotName==0)
    N=N+1;
    filename=[subjID,'_ploLongTrain_day',num2str(day),'_N',num2str(N),'.mat'];
%     practicefilename=[subjID,'_textTuneTrain',num2str(N),'-Practice.mat'];
%     scfilename = [subjID,'_SC_textTuneTrain',num2str(N),'.mat'];
    foundName=0;
    for kk=1:numfiles
        tmp=d(kk).name;
        foundName=strcmpi(filename,tmp);
        if(foundName==1)
            break;
        end;
    end;
    if foundName==0
        gotName=1;
    end;
end;
fprintf('data will be stored in file %s\n',filename);
cd(exptPath);


% set up adapation screen
Screen('FillRect',w, RGBgrey); % clear buffer
Screen('Flip',w); % flip display
FlushEvents('keyDown');
t0 = GetSecs;
while(GetSecs-t0 < adaptDuration); % wait
    [keyIsDown, secs,keyCode] = KbCheck(controlKeyboard);
    if keyCode(escapeKey)==1
        break
    end % if
    WaitSecs(1);
    elapsedTime = GetSecs - t0;
    mytext = sprintf('Experimental trials begin in %i seconds...',round(adaptDuration - elapsedTime));
    Screen('FillRect',w, RGBgrey); % clear buffer
    [nx, ny, bbox] = DrawFormattedText(w,mytext, 'center', center(2));
    Screen('Flip',w); % flip display
end % while

Screen('FillRect',w, RGBgrey); % clear buffer
Screen('Flip',w); % flip display
mytext = sprintf('Press spacebar to begin.');
Screen('FillRect',w, RGBgrey); % clear buffer
[nx, ny, bbox] = DrawFormattedText(w,mytext, 'center', center(2));
Screen('Flip',w); % flip display
if autopilot==0
    %theKey=pbGetKey(44,min(GetKeyboardIndices())); %wait for spacebar press
    theKey=pbGetKey(KbName('space'),[]); %wait for spacebar press
end

%pbChirp(4);

Screen('FillRect',w, RGBgrey); % clear screen
Screen('Flip',window); % flip display
Snd('Play',introsnd);

WaitSecs(2);

ABORTEDDATA=0;


fprintf('$ starting experimental trials...\n');
fprintf('$ hit escape key to abort experiment...\n');


%%%%%%%%%%%%%%%%%%%%%%%%%%
%start experimental trials
%%%%%%%%%%%%%%%%%%%%%%%%%%

% numBlocks = numStaircases/2;
numBlocks=1;
curTrial=0;
for cB = 1:numBlocks 
    
    % set up trial order for this block
    stimConditions=stimulusConditions(randperm(numTrials),:);
    stimConditions=stimConditions(randperm(numTrials),:);
    
    
%     % which staircases to use
%     if cB==1
%         cbSC = [1 2]; % block 1 does staircase 1,2
%     elseif cB==2
%         cbSC = [3 4]; % block 2 does staircase 3,4
%     elseif cB==3
%         cbSC = [5 6]; % block 3 does staircase 5,6
%     end
    
    
    for cT=1:numTrials
        curTrial = curTrial+1;
        HideCursor;
        
        % set up trial conditions
        curStimID=stimConditions(cT,1);
        targStim=filtTextures(:,:,curStimID);
        curCO = 1; % only training on horizontal
        
        curEasyTrial = scQP.ScOrEz(cT);
        if curEasyTrial==1
              nzSDstimDB = scQP.ezcond;
              nzSDstim = db2contrast(nzSDstimDB); % db2contrast taken from dxjones
        else
              nzSDstimDB = qpQuery(scQP.questData);
              nzSDstim = db2contrast(nzSDstimDB);
        end
        
%         % stimSD obtained from staircase:
%         
%         %select staircase
%         gotone=0;
%         while(gotone==0)
%             %         scID=randomcondition(numStaircases); % randomly select a staircase
%             scID=RandSample(cbSC); % randomly select a staircase from current block staircases (cbSC)
%             if scTrialCounter(scID) < trialsPerStaircase % completed stairase?
%                 gotone=1;
%             end;
%         end;
%         
%         stimSD = scGetValue(allSCs(scID)); % extract contrast from sc
        
        tmpContrast = sqrt(var(targStim(:)));
        targStim = (stimSD/tmpContrast).*(targStim);
        
        if traintype==0
            finalStim=targStim;
            
            thumbnailImages = thumbnailImagesH;
            
        elseif traintype==1
            
            vertNoise = noise2d(imsize,1,-4.2,4.2); % -4.2 to 4.2 were used to create original textures too
            vertNoise = bpimage(vertNoise,vsf,0);
            tmpContrastNz = sqrt(var(vertNoise(:)));
            
            vertNoiseStim = (nzSDstim/tmpContrastNz).*(vertNoise);
            
            finalStim = targStim + vertNoiseStim;
            
%             vertNoiseResp = imresize(vertNoise, [thumbnailsize, thumbnailsize]);
%             tmpContrastNzResp = sqrt(var(vertNoiseResp(:)));
%             vertNoiseResp = (nzSDresp/tmpContrastNzResp).*(vertNoiseResp);
            
            for kk=1:numTex
                
                % the following allows for different noise in all 6 exemplars, none of which match the stimulus noise
                vertNoiseResp = noise2d(imsize,1,-4.2,4.2); % -4.2 to 4.2 were used to create original textures too
                vertNoiseResp = bpimage(vertNoiseResp,vsf,0);
                vertNoiseResp = imresize(vertNoiseResp, [thumbnailsize, thumbnailsize]);
                tmpContrastNzResp = sqrt(var(vertNoiseResp(:)));
                vertNoiseResp = (nzSDresp/tmpContrastNzResp).*(vertNoiseResp);

                % this allows for image matching (the same stim noise is used in all 6 response exemplars 
%                 vertNoiseResp = (nzSDresp/tmpContrastNz).*imresize(vertNoise,[thumbnailsize, thumbnailsize]);
                
%                 thumbnailImagesHnz(:,:,kk)=imresize(filtTextures(:,:,kk),[thumbnailsize,thumbnailsize]);
%                 thumbnailImagesHnz(:,:,kk)=imrotate(thumbnailImagesHnz(:,:,kk),respRotAngle);
                tmpthumbHnz = squeeze(thumbnailImagesHnz(:,:,kk));
                thumbnailImagesHnzFINAL(:,:,kk) = (stimSDresp/sqrt(var(tmpthumbHnz(:)))) .* thumbnailImagesHnz(:,:,kk);
                
                thumbnailImagesHnzFINAL(:,:,kk) = thumbnailImagesHnzFINAL(:,:,kk) + vertNoiseResp;
                
                thumbnailImagesHnzFINAL(:,:,kk)=avgLum*(1+thumbnailImagesHnzFINAL(:,:,kk));
                thumbnailImagesHnzFINAL(:,:,kk)=pbLum2BS(thumbnailImagesHnzFINAL(:,:,kk),L,B);
            end;
            
            thumbnailImages = thumbnailImagesHnzFINAL;
            
        end
        
        whiteNz = whiteNzSD .* randn(size(finalStim));
        
        finalStim = finalStim + whiteNz;
        

        % finalStim = imrotate(finalStim,rotAngle);
        

        % convert from contrast to luminance:
        stimLum=avgLum*(1+finalStim);
        
        % convert Luminance to BitStealing Numbers:
        stimBSnumbers=pbLum2BS(stimLum,L,B);
        
        % finally, convert BS numbers to RGB values:
        stimRGBarray = pbBitStealing2RGB(stimBSnumbers,rgbMat,0);
        
        % make final stimulus
        Stimulus1 = Screen('MakeTexture',window,stimRGBarray);
        
        
        starttrial = GetSecs;
        resp    = 0;
        rt      = 0;
        FlushEvents('keyDown');
        randInterval = randn(1) * 0.1;
        
        % initialize display
        w=window; % for compatability
        Screen('FillRect',w, RGBgrey); % clear buffer
        [VBLTimestamp StimulusOnsetTime FlipTimestamp Missed Beampos]=Screen('Flip', w); % flip display
        while(GetSecs-StimulusOnsetTime < pretrialDelay); % pre-fixation delay
        end;
        Screen('FillRect',w, RGBgrey); % clear buffer
        Screen('glPoint',w,black,fixPntX,fixPntY,fixPntSize); % draw fixation point
        [VBLTimestamp StimulusOnsetTime FlipTimestamp Missed Beampos]=Screen('Flip', w); % flip display
        Screen('FillRect',w, RGBgrey); % clear buffer
        while(GetSecs-StimulusOnsetTime < fixpntDuration); % wait
        end;
        [VBLTimestamp StimulusOnsetTime FlipTimestamp Missed Beampos]=Screen('Flip', w); % flip display
        
        Screen('DrawTexture', window, Stimulus1); %Draw face+noise array
        while(GetSecs-StimulusOnsetTime < stimOffsetTime1 + randInterval); % wait
        end;
        [VBLTimestamp StimulusOnsetTime FlipTimestamp Missed Beampos]=Screen('Flip',window); % flip display
        start_time = StimulusOnsetTime;
        
        % prepare to erase screen
        Screen('FillRect',w, RGBgrey); % clear screen
        while(GetSecs-StimulusOnsetTime < stimDuration); % wait
        end;
        
        [VBLTimestamp StimulusOnsetTime FlipTimestamp Missed Beampos]=Screen('Flip',window); % flip display
        %         WaitSecs(0.75); % wait for 200 ms
        
        Screen('Close', Stimulus1);
        
        % create and display response window:
        thumbRect = SetRect(1,1,thumbnailsize,thumbnailsize);
        Screen('FillRect',w, RGBgrey); % clear buffer
        
        for kk=1:numTex
            thumbRGBarray = pbBitStealing2RGB(thumbnailImages(:,:,kk),rgbMat,0);
            destrect=CenterRectOnPoint(thumbRect,itemLocs(kk,2),itemLocs(kk,1));
            Screen('PutImage', w,thumbRGBarray,destrect);
        end;
        
%         Screen('DrawTexture', window, Stimulus1); %Draw face+noise array
        
        while (GetSecs-StimulusOnsetTime < stimOffsetRespOnset); %wait
        end
        
        ShowCursor;
        SetMouse(fixPntX,fixPntY,scrinfo.number);
        Screen('Flip', window);
        
        % Get Mouse click
        if autopilot==1
            %             curResponse=randi(6);
            curResponse=round(curStimID + randn);
            [keyIsDown,secs,keyCode] = KbCheck(controlKeyboard);
            if keyCode(escapeKey)==1
                ABORTEDDATA=1;
            end % if
        else
            gotResp = 0;
            ShowCursor;
            SetMouse(fixPntX,fixPntY,scrinfo.number);
            curResponse = 0;
            ABORTEDDATA=0;
            while(gotResp==0)
                [xm,ym,mclick]=GetMouse(scrinfo.number);
                if (max(mclick(:))==1)
                    mL=ones(numTex,1)*[ym,xm];
                    d = sum(( (itemLocs - mL).^2 ),2);
                    d = sqrt(d);
                    if (min(d) < (thumbnailsize))
                        [v,curResponse]=min(d);
                        gotResp=1;
                    end;
                end;
                [keyIsDown,secs,keyCode] = KbCheck(controlKeyboard);
                if keyCode(escapeKey)==1
                    gotResp=1;
                    ABORTEDDATA=1;
                end % if
            end;
        end
        
        Screen('FillRect',w, RGBgrey); % clear buffer
        Screen('Flip', window);
        
%         Screen('Close', Stimulus1);
        
        if (ABORTEDDATA==0)
            
            success=(curResponse==curStimID);
            resp = curResponse;
            
            % provide feedback:
            if success %Correct keypress
                accuracy = 1;
                Snd('Play',corrsnd); % give auditory feedback for correct response
            else %Incorrect keypress
                accuracy = 0;
                Snd('Play',wrongsnd); % give auditory feedback for incorrect response
            end
            
%             scTrialCounter(scID) = scTrialCounter(scID)+1;
%             allSCs(scID) = scUpdate(allSCs(scID), accuracy);
            
            curContrast = stimSD;
            
            theData(curTrial,:)=[curTrial,curType,curCO,curStimID,curResponse,curContrast,success];
            
            %% WITHIN TRIAL, after response
            scQP.questData = qpUpdate(scQP.questData, nzSDstimDB, accuracy+1);
            
            % erase screen:
            Screen('FillRect',window,RGBgrey);
            Screen(window, 'Flip');
            
            
            
            
            cd(dataPath); save(filename,'theData','scQP'); save([filename,'_workspace']); cd(exptPath);
            fprintf('trial = %4i; type = %2i; cond = %2i; ct = %2i; id = %2i; resp = %2i;  correct = %g\n',curTrial,curType,curCO,curContrast,curStimID,curResponse,success);
            
        elseif (ABORTEDDATA==1)
            ShowCursor;
            cd(dataPath); save(filename,'theData'); save([filename,'_workspace']); cd(exptPath);
            
            
            Screen('CloseAll');
            return;
            
        end
        
        
        
        % break time!
        if sum(curTrial==breakpoints)>0
            % give break at the end of each block
            Screen('FillRect',w, RGBgrey); % clear buffer
            Screen('Flip',w); % flip display
            mytext = sprintf('Please take a short break. Press space when you are ready to continue...');
            Screen('FillRect',w, RGBgrey); % clear buffer
            [nx, ny, bbox] = DrawFormattedText(w,mytext, 'center', center(2));
            Screen('Flip',w); % flip display
            theKey=pbGetKey(44,controlKeyboard); %wait for spacebar press
        end
    
    end % end trials
    
    % save workspace at end of each block
    cd(dataPath);save([filename,'_workspace']);cd(exptPath);
    
end % end blocks


if curTrial==numTrials
    fprintf('\nBlock1: %.3g \nBlock2: %.3g \nBlock3: %.3g \nBlock4: %.3g \nBlock5: %.3g \nBlock6: %.3g\n', mean(theData(1:100,7)), mean(theData(101:200,7)), mean(theData(201:300,7)), mean(theData(301:400,7)), mean(theData(401:500,7)), mean(theData(501:600,7)))
    fprintf('\nBlock1: %.3g \nBlock2: %.3g \nBlock3: %.3g \nBlock4: %.3g \nBlock5: %.3g \nBlock6: %.3g\n', mean(theData(1:115,7)), mean(theData(116:230,7)), mean(theData(231:345,7)), mean(theData(346:460,7)), mean(theData(461:575,7)), mean(theData(576:690,7)))
end

Screen('CloseAll')

end % experiment