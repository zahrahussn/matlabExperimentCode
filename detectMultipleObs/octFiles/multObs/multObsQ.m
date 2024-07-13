function eRec=multObsQ(params)

  pkg load statistics;
  pkg load image;
  %Screen("Preference", "SkipSyncTests", 1);
  
  if nargin<1
    return;
  endif;
  
 
  %% -----------------------------------------------------------
  % Load textures:

  load "theStimulus4"
  stimNames=fieldnames(theStimulus4);
  [numTextures,kk]=size(stimNames);
%  numTextures = params.numTextures;
  % set mean to zero and variance to one:
  for kk=1:numTextures
      tmp = eval(["theStimulus4",".",char(stimNames(kk))]);
      tmp = tmp - mean(tmp(:));
      tmp = tmp ./std(tmp(:),1);
      texImages(kk).stim=tmp;
  end

  % check stimulus size:
  params.nr = size(texImages(1).stim,1);
  
  %% ------------------------------------------------------------
  % Create stimulus conditions (contrasts & external nz variances)
  
  % external noise variances
%  nv=params.extNzVariance;			% external noise variance (medium)

  trialsPerBlock = params.numTrials;


  %% -----------------------------------------------------------
  % initialize variables:
  M_FILE_NAME = "/multObs"; % used to create file name
  FILE_XTENSION = "_multObs.mat";
  DEBUG_FLAG = 0;
  SHOW_STIMULUS = 1;
  DO_SIM = params.simulatedObserver;
  GIVE_FEEDBACK = 1;
  USE_PIXX_RESPONSE = 1;
  PNB_BUTTON_BOX = 0;
  USE_M16_MODE = params.USE_M16_MODE;
  DISPLAY_GAMMA_VALUE = params.CRT_GAMMA; % for NEC-multisync display with M16 mode
  screenid = max(Screen("Screens"));
  VIEWING_DISTANCE = params.viewingDistance; % cm
  PRACTICE_FLAG = 1;
  PRACTICE_TRIALS = 10;
  CRT_METHOD = params.CRT_METHOD;
  CRT_GAMMA  = params.CRT_GAMMA; 
  eRec=[];
  eRec.params = params;
  
  % Key mappings, unified across operating systems:
  KbName("UnifyKeyNames");
  Escape = KbName("ESCAPE");
  escapeKey = KbName("ESCAPE");
  spaceKey = KbName("SPACE");
  leftKey = KbName("LEFTARROW");
  rightKey = KbName("RIGHTARROW");

  
  % ------------------------------------------------
  
  eRec.mfilename = M_FILE_NAME;
  eRec.startTime = GetSecs;
  eRec.endTime = GetSecs;
  eRec.abortFlag = 0;
  
  
  
  
  
  % set up paths -----------------------------------------------
  oldpath=pwd;
  [filename,exptPath,dataPath] = getFileName(params);
  csvname = filename;
  xtx = "_trials.csv";
  n1 = strfind(csvname,".mat");
  n2 = n1 + length(xtx) - 1;
  csvname(n1:n2) = xtx;
  fprintf("data will be stored in file %s\n",filename);
  eRec.filename = filename; % save the file name
  eRec.csvname = csvname; % save the file name
  eRec.exptPath = exptPath;
  eRec.dataPath = dataPath;
  cd(exptPath);
  tmp = exist(eRec.csvname);
  
  % ----------------------------------------------------------------
  % initialize screen display 
  % Abort script if it isn"t executed on Psychtoolbox-3:
  AssertOpenGL;
  

  [scrInfo, window, winRect, overlay, OVERLAY_FILL] = InitDisplay(CRT_METHOD,CRT_GAMMA,screenid);
  eRec.scrInfo = scrInfo;
  circRect = [0,0,winRect(4),winRect(4)];
  circRect = CenterRect(circRect,winRect);  
  % fixation point
  fixpnt.X = round( abs(winRect(RectRight)-winRect(RectLeft)) / 2 );
  fixpnt.Y = round( abs(winRect(RectBottom)-winRect(RectTop)) / 2 );
  fixpnt.size = 3;

  
  % ---------------------------------------------------
  % timing variables
  tr = getTimeParams(DO_SIM);
  eRec.tr = tr;
 
  if USE_PIXX_RESPONSE
    ResponsePixx("Open");
  endif;
  
  % -----------------------------------------------
  % Make sounds  
  InitializePsychSound;
  % initialize parameters:
  device = [];
  SND_RATE = 48000;
  nrchannels = 2;
  % now find default device:
  d = PsychPortAudio("GetDevices");
  numDev = size(d,2);
  for kk=1:numDev
    if strcmp(lower(d(kk).DeviceName),"sysdefault")
      device = d(kk).DeviceIndex;
      SND_RATE = d(kk).DefaultSampleRate;
      break;
    endif
  endfor;
 
  if ~isinf(tr.stimDurationSec)
    stimsnd=makesnd(800,tr.stimDurationSec,0.8,SND_RATE);
  else
    stimsnd=makesnd(800,1,0.8,SND_RATE);
  endif;
  
  introsnd = makesnd(600,0.1,.6,SND_RATE);
  corrsnd = makesnd(1131,0.1,.6,SND_RATE);
  wrongsnd = makesnd(565,0.1,.7,SND_RATE);
  
  % set up QUEST  
  if (params.UseQuest==1)   
    pThreshold=0.70;
    beta=2.5;
    delta=0.02;
    gamma=0.5;
    tGuess = log10(params.QuestThresholdGuess);
    tGuessSd = params.QuestSD;
    q = QuestCreate(tGuess,tGuessSd,pThreshold,beta,delta,gamma);
    q.normalizePdf=1; % This adds a few ms per call to QuestUpdate, but otherwise the pdf will underflow after about 1000 trials.
  endif
  

  % -----------------------------------------------
  % get stimulus parameters
  eRec.fixpnt = fixpnt;
  % scale stimulus dest rect: 
  stimRect = SetRect(0,0,params.nr,params.nr);
  stimScale = 1;
  stimDestRect = stimScale * stimRect;
  stimDestRect = CenterRect(stimDestRect,winRect);

 
  startExptRec = SetRect(0,0,128,128);
  startExptRec = CenterRect(startExptRec,winRect);
  
  uniImage = 0.5 + zeros(params.nr,params.nr); % uniform field
  uniTex = Screen("MakeTexture", window, uniImage, [], [], 2);
  HideCursor(window);

  % -----------------------------------------------
  % show instructions
  if USE_PIXX_RESPONSE
    if PNB_BUTTON_BOX==0
      mytxt = sprintf("Adapt to the display luminance for %i seconds.\n\nPress red or green button to start adaptation.",tr.adaptDuration);
    else
      mytxt = sprintf("Adapt to the display luminance for %i seconds.\n\nPress red or blue button to start adaptation.",tr.adaptDuration);
    endif;
  else
    mytxt = sprintf("Adapt to the display luminance for %i seconds.\n\nPress any key to start adaptation.",tr.adaptDuration);
  endif;
  DrawFormattedText(overlay, mytxt, "center", "center", 255);
  Screen("Flip", window,1);
  bResp = getButtonPress(USE_PIXX_RESPONSE);
  if bResp < 0
    Screen("CloseAll");
    eRec.endTime = GetSecs;
    eRec.abortFlag = 1;
    return; % bye
  endif;
  % Clear the overlay to transparent "background color":
  Screen("FillRect", overlay, OVERLAY_FILL);
  Screen("Flip", window,1);
  
  
  % -------------------------------------------------------
  % Adaptation
  Screen("FillRect",window, 0.5); % clear buffer
  Screen("Flip",window,1); % flip display
  WaitSecs(0.25);
  t0 = GetSecs;
  while(GetSecs-t0 < tr.adaptDuration); % wait
      [keyIsDown, secs, keyCode] = KbCheck;
      if keyCode(Escape) 
          break;
      endif % if
      WaitSecs(1);
      elapsedTime = GetSecs - t0;
      mytext = sprintf("%i seconds remaining...",round(tr.adaptDuration - elapsedTime));
      Screen("FillRect",overlay, OVERLAY_FILL); % clear buffer
      DrawFormattedText(overlay, mytext, "center", 64, 255);
      Screen("Flip",window,1); % flip display
  endwhile % while
  
  % ------------------------------------------------------
  % Experimental trials
  pbChirp(4);
  
  % Clear overlay from old text:
  Screen('FillRect', overlay,  OVERLAY_FILL);
  Screen('Flip', window,1);
  % Wait for keystroke to start:
  if USE_PIXX_RESPONSE
    if PNB_BUTTON_BOX==0
      mytxt = 'Press red or green button to start experimental trials.';
    else
      mytxt = 'Press red or blue button to start experimental trials.';
    endif;
    
    DrawFormattedText(overlay, mytxt, 'center', 'center', 255);
    Screen('Flip', window,1);
    bResp = getPixxResponse;
    if bResp < 0
      Screen('CloseAll');
      eRec.endTime = GetSecs;
      eRec.abortFlag = 1;
      return; % bye
    end;     
  else
    mytxt = 'Press any key to start experimental trials.';
    DrawFormattedText(overlay, mytxt, 'center', 'center', 255);
    Screen('Flip', window,1);
    [secs, keyCode, deltaSecs] = KbStrokeWait;
    if (keyCode(Escape))
      Screen('CloseAll');
      eRec.endTime = GetSecs;
      eRec.abortFlag = 1;
      return; % bye
    end;   

  endif;
  % Clear display
  Screen('FillRect',overlay, OVERLAY_FILL)
  % draw fixaxtion point
  Screen('BlendFunction', overlay, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  Screen('gluDisk',overlay,200,fixpnt.X,fixpnt.Y,fixpnt.size); % draw fixation point
  Screen('Flip', window);
  Screen('Flip',window,1);  
  WaitSecs(1);




% initialize these variables:
curNoiseVar = params.extNzVariance;
curNoiseSD = sqrt(curNoiseVar);
curTexVar = params.texFigureVar;
curTexSD = sqrt(curTexVar);
curTexID = params.textureID;

if(strcmp(lower(params.uncertaintyID),"ske"))
  tmpSD = sqrt(params.texFigureVar);
  texImage = 0.5.* (1 + tmpSD.*texImages(curTexID).stim);
  % show noise-free image of texture:
  stimTexture = Screen("MakeTexture",window,texImage,[],[],2);
  Screen("BlendFunction", window, GL_ONE, GL_ZERO);
  Screen("DrawTexture",window,stimTexture,[],stimDestRect); % draw
  mytxt = sprintf("This is the signal. Press any button to continue.");
  DrawFormattedText(overlay, mytxt, "center", 64, 255);
  Screen("Flip", window);


  % wait for a button press
  if (DO_SIM==0)
    WaitSecs(0.25);
    if USE_PIXX_RESPONSE
      curResponse = getPixxResponse;
    else
      curResponse = getKbResponse;
    endif;
  elseif
    WaitSecs(1);
  endif
  
  % clear screen
  Screen('FillRect',window,0.5);
  Screen('FillRect',overlay,OVERLAY_FILL);
  Screen("Flip", window);
  Screen("Close", stimTexture); % release stimTexture
endif


pahandle = PsychPortAudio('Open', device, [], 0, [], nrchannels);
numFrames = tr.trialDurFrames;
stim1onsetFrame = tr.stim1onsetFrame;
stim1offsetFrame = tr.stim1offsetFrame;
stim2onsetFrame = tr.stim2onsetFrame;
stim2offsetFrame = tr.stim2offsetFrame;
curTrial = 1;
curDataRec = 1; % used to write lines to data file
alldone = 0;
ABORTEDDATA = 0;

curTime = GetSecs;
    
% Our experimental trials loop:
while (alldone==0) && (ABORTEDDATA==0)

  if (curTrial==(params.QuestTrials+1))
    mytxt = sprintf("Starting multiple observations...");
    DrawFormattedText(overlay, mytxt, "center", "center", 255);
    Screen("Flip", window);
    WaitSecs(1);    
    Screen('FillRect',window,0.5);
    Screen('FillRect',overlay,OVERLAY_FILL);
    Screen("Flip", window);
  endif  

  
%   get contrast:
  if (params.UseQuest==0) 
    qflag = 0;
    curTexVar = params.BaselineStimVariance;
    curTexSD = sqrt(curTexVar);
  elseif (params.UseQuest==1)  
    if (curTrial <= params.QuestTrials)
      qflag = 1;
      qEstimate = QuestMean(q);
      curTexVar = 10^(qEstimate);
      curTexSD = sqrt(curTexVar);    
    elseif (curTrial > params.QuestTrials)
      qflag = 0;
      qEstimate = QuestMean(q);
      curTexVar = 10^(qEstimate);
      curTexSD = sqrt(curTexVar);    
    endif
  endif
  
  if (qflag==1)
    mumStimObs = 1;
  else
    mumStimObs = params.numObs;
  endif
  
  SetMouse(winRect(RectRight),winRect(RectBottom),window);
  HideCursor(window); 
  curTargInterval = 1 + round(rand(1));


     
    stimulus_1_ON = 0;
    PsychPortAudio("FillBuffer", pahandle, [stimsnd; stimsnd]);

    
%     get texture ID:
    if (strcmp(lower(params.uncertaintyID),'ske'))
      curTexID = params.textureID;
    endif
    
    if (strcmp(lower(params.uncertaintyID),'composite'))
      curTexID = randperm(5,1);
    endif

    while (GetSecs - curTime) < tr.trialISI
      ;
    endwhile
    
    tStartTime = GetSecs;
    
    for observation=1:mumStimObs

      if (strcmp(lower(params.uncertaintyID),'simple'))
        curTexID = randperm(5,1);
      endif
   

      texImage = curTexSD.*texImages(curTexID).stim;
      nzImage1 = curNoiseSD * randn(params.nr, params.nr);
      nzImage2 = curNoiseSD * randn(params.nr, params.nr);
    
      if (curTargInterval==1)
        stimImage1 = 0.5 + texImage + nzImage1;
        stimImage2 = 0.5 + nzImage2;
      else
        stimImage1 = 0.5 + nzImage1;
        stimImage2 = 0.5 + texImage + nzImage2;
      endif
    
%       clip stim images:
      tmp = stimImage1 > 1;
      stimImage1(tmp) = 1;
      tmp = stimImage1 < 0;
      stimImage1(tmp) = 0;
    
      tmp = stimImage2 > 1;
      stimImage2(tmp) = 1;
      tmp = stimImage2 < 0;
      stimImage2(tmp) = 0;
    
      stimTexture1 = Screen("MakeTexture",window,stimImage1,[],[],2);
      stimTexture2 = Screen("MakeTexture",window,stimImage2,[],[],2);
    
      
      GIVE_FEEDBACK = (observation==mumStimObs); 
      WaitSecs(tr.observationISI);
      
      if (observation==1)
      % flicker fixation point 3 cycles at 7 Hz       
        Screen('BlendFunction', overlay, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        for (fpf=1:3) 
          Screen('FillRect',overlay, OVERLAY_FILL)
          Screen('Flip', window);
          WaitSecs(0.075);
          Screen('gluDisk',overlay,200,fixpnt.X,fixpnt.Y,fixpnt.size); % draw fixation point
          Screen('Flip', window);
          WaitSecs(0.075);
        endfor
        WaitSecs(params.fixPntDelaySec);        
      endif

      
      for fcount=1:numFrames
  
        if (fcount >= stim1onsetFrame)&&(fcount < stim1offsetFrame)
          stimulus_1_ON = 1;
        else
          stimulus_1_ON = 0;
        end;
  
        if (fcount >= stim2onsetFrame)&&(fcount < stim2offsetFrame)
          stimulus_2_ON = 1;
         else
          stimulus_2_ON = 0;
        end;
       
%         Disable alpha-blending, so we can just overwrite the framebuffer
%         with our new pixels:
        Screen("BlendFunction", window, GL_ONE, GL_ZERO);
    
        if (stimulus_1_ON)
          Screen("DrawTexture",window,stimTexture1,[],stimDestRect); % draw alpha/gabor mask
        elseif (stimulus_2_ON)
           Screen("DrawTexture",window,stimTexture2,[],stimDestRect); % draw alpha/gabor mask       
        else
          Screen("DrawTexture", window, uniTex, [], [], 0, 0); % draw uniform screen
        end;
  
        if (params.PLAY_STIM_SOUND==1) && (fcount == stim1onsetFrame)
          t1 = PsychPortAudio("Start", pahandle, 1, 0, 0);
        end;
        
        if (fcount == stim1onsetFrame) || (fcount == stim2onsetFrame)
          t1 = PsychPortAudio('Start', pahandle, 1, 0, 0);
        end;
       
  
%         Enable alpha blending with proper blend-function. We need it
%         for drawing of smoothed points:
        Screen("BlendFunction", overlay, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        Screen("gluDisk",overlay,200,fixpnt.X,fixpnt.Y,fixpnt.size); % draw fixation point  
        Screen("DrawingFinished",window);
%         Show new image at next retrace:
        Screen("Flip", window);   
      end; % for frames loop
      
%       end trial, clear screen, flush image textue memory:
      tEndTime = GetSecs;
      Screen('FillRect',window,0.5);
      Screen('FillRect',overlay,OVERLAY_FILL);
      Screen('BlendFunction', overlay, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
      Screen('gluDisk',overlay,200,fixpnt.X,fixpnt.Y,fixpnt.size); % draw fixation point
      Screen('Flip', window);
      
      if DEBUG_FLAG
        fprintf("\n\nTrial time (sec) = %f; msec per frame = %0.3f\n\n",(tEndTime-tStartTime),1000.*(tEndTime-tStartTime)/numFrames);
      endif
      
%       get response  
      WaitSecs(0.02);  
      if (DO_SIM==0)
        if USE_PIXX_RESPONSE
          curResponse = getPixxResponse;
        else
          curResponse = getKbResponse;
        endif;
        if curResponse < 0
          ABORTEDDATA = 1;
          eRec.abortFlag = 1;
        endif;
      else % DO_SIM==1
        [keyIsDown, secs, keyCode] = KbCheck;
        ABORTEDDATA = keyCode(Escape); 
        if qflag==0
          pc = [0.60, 0.65, 0.70, 0.75, 0.8];
          probCorr = pc(observation);
          response = CoinFlip(1,probCorr);
        else
           probCorr = 0.5 + 0.5 * normcdf(log10(curTexVar),log10(params.QuestThresholdGuess),0.5);
          tg = 1.5 * params.QuestThresholdGuess;          
          response=QuestSimulate(q,log10(curTexVar),log10(tg));
        endif       
        if (response==1)
          tmp = [1,2];
          curResponse = curTargInterval;
        else
          tmp = [2,1];
          curResponse = tmp(curTargInterval);
        endif
      endif   % DO_SIM    
    
      if (ABORTEDDATA==0)
        success=(curResponse==curTargInterval);        
        if qflag==1        
          q=QuestUpdate(q,log10(curTexVar),success); % update quest:
        endif               
        if GIVE_FEEDBACK 
%          WaitSecs(0.025);
          if success %Correct keypress
              PsychPortAudio('FillBuffer', pahandle, [corrsnd; corrsnd]);        
              t1 = PsychPortAudio('Start', pahandle, 1, 0, 1);
          else
              PsychPortAudio('FillBuffer', pahandle, [wrongsnd; wrongsnd]);
              t1 = PsychPortAudio('Start', pahandle, 1, 0, 1);
          endif               
        endif        
        fprintf('t = %4i; obs = %2i; texID = %3i; texSD = %8.7f; i = %2i;  s = %2i; quest = %i\n',curTrial,observation,curTexID,curTexSD,curTargInterval,success,qflag);
        eRec.trialdata(curDataRec,:) = [curTrial,observation,curTexID,curTexSD,curTargInterval,success,qflag];
        curDataRec = curDataRec + 1;
      endif
      
      if (ABORTEDDATA==1)
%       abort...      
        ShowCursor;
        eRec.endTime = GetSecs;
        eRec.abortFlag = 1;
        cd(dataPath); save(filename,"eRec");cd(exptPath);
        Screen("CloseAll");
        PsychPortAudio("Close", pahandle);
        ResponsePixx("Close");  
        Datapixx("Close");
        return;
      endif
    endfor % end of all observations and of trial
    curTrial=curTrial+1;
    alldone = curTrial > params.numTrials;
    curTime = GetSecs; % get time... will use this to time inter-trial interval
    cd(dataPath); save(filename,'eRec');cd(exptPath);
    Screen('Close', stimTexture1);           
    Screen('Close', stimTexture2);                   

  
endwhile; %alldone
  

if (SHOW_STIMULUS)
  mytxt = "Finished!";
  DrawFormattedText(overlay, mytxt, "center", "center", 255);
  Screen("Flip", window,1);
  WaitSecs(2);
  Screen("FillRect",overlay,0);
  Screen("Flip", window);
%  Stop playback:
  PsychPortAudio("Stop", pahandle, 1);
  PsychPortAudio("Close", pahandle);
%  Load identity CLUT into Bits++ to restore proper display:
  BitsPlusPlus("LoadIdentityClut", window);
%   This flip is needed for the "LoadIdentityClut" to take effect:
  Screen("Flip", window);
%   Load old gamma tables into gfx-card:
  RestoreCluts;
%   Close Screen...
  Screen("CloseAll");
  ResponsePixx("Close");
  ShowCursor;
  
endif

eRec.endTime = GetSecs;
% Bye!
return;

% ----------------------------------
function theResp = getButtonPress(USE_PIXX_RESPONSE)
  if nargin < 1
    USE_PIXX_RESPONSE = 0;
  endif

  if USE_PIXX_RESPONSE
   theResp = getPixxResponse;   
  else
   [secs, keyCode, deltaSecs] = KbStrokeWait;
   if (keyCode(Escape))
    theResp = -1;
   else
    theResp = 1;
   endif;
 endif;

endfunction

  
% -------------------------------------------------------
function bResp = getPixxResponse
  if PNB_BUTTON_BOX
    RED = 1;
    WHITE = 2;
    BLUE = 3;
    GREEN = 4;
    buttonName = {"RED", "WHITE", "BLUE", "GREEN"};
  else
    RED = 1;
    YELLOW = 2;
    GREEN = 3;
    BLUE = 4;
    WHITE = 5;
    buttonName = {"RED", "YELLOW", "GREEN", "BLUE", "WHITE"};
  endif
  numWhitePresses = 0;
   printf("\nPress a button...");
  
  [tb,ts] = ResponsePixx("StartNow",1);

  gotOne = 0;
  while gotOne==0
    WaitSecs(0.05);
    [buttonStates, boxTimeSecs, getsecsTimeSecs] = ResponsePixx("GetButtons");
    if (buttonStates(WHITE)==1)
      numWhitePresses = numWhitePresses+1;
      if numWhitePresses==1
        mytxt = sprintf("Press white button again to abort the experiment");
        DrawFormattedText(overlay, mytxt, "center", "center", 255);
        Screen("Flip", window);
        WaitSecs(0.5);
      elseif numWhitePresses > 1
        gotOne = 1;
        bResp = -1;
      end     
    endif
    if PNB_BUTTON_BOX && (buttonStates(BLUE)==1)
      gotOne = 1;
      bResp = 1;
    endif
    if (PNB_BUTTON_BOX==0) && (buttonStates(GREEN)==1)
      gotOne = 1;
      bResp = 1;
    endif
    if (buttonStates(RED)==1)
      gotOne = 1;
      bResp = 2;
    endif
%     check keyboard escape key:
    [keyIsDown, secs, keyCode] = KbCheck;
    if keyCode(Escape) 
      gotOne = 1;
      bResp = -1;
    end % if

   endwhile 
   

endfunction

% -------------------------------------------------------
function kResp = getKbResponse
   Key mappings, unified across operating systems:
  KbName("UnifyKeyNames");
  Escape = KbName("ESCAPE");
  LeftKey = KbName("LEFTARROW");
  RightKey = KbName("RIGHTARROW");
   
   Wait for a keypress, returns its "keyCode":
  kResp = 0;
  gotOne = 0;

  while (gotOne==0)
    keyCode = 0;
    [secs keyCode] = KbWait([],2);
    
    if keyCode(Escape)
      
      gotOne=Escape;
      kResp = -1;
    end;
    
    if keyCode(LeftKey)
      gotOne = LeftKey;
      kResp = 1;
    end;
    
    if keyCode(RightKey)
      gotOne = RightKey;
      kResp = 2;
    end;
  endwhile;
endfunction



% -----------------------------------------------------
function [scrInfo, window, winRect, overlay, OVERLAY_FILL] = InitDisplay(CRT_METHOD,CRT_GAMMA,screenid) 
  if nargin < 3
   screenid = max(Screen("Screens"));   
  endif

  scrInfo = Screen("Resolution", screenid);
  [scrInfo.Wmm, scrInfo.Hmm] = Screen("DisplaySize", screenid);
  Screen("Preference", "VisualDebugLevel", 0);
  
%   Define requirements for onscreen window - Setup imaging pipeline:
  PsychImaging("PrepareConfiguration");
  
%   Want a full 32 bit floating point precision framebuffer:
%   This will provide an effective resolution of 23 bits in the displayable
%   luminance range -- Plenty of headroom for the up-to 16 bits output devices.
%   Hardware older than NVidia Geforce 8000 or ATI Radeon HD 2000 won"t be
%   able to do alpha-blending at this mode though. Not an issue here, as we
%   don"t need alpha-blending...
  PsychImaging("AddTask", "General", "FloatingPoint32Bit");
  
  
  if strcmp(CRT_METHOD,"PseudoGrayOutput")
      PsychImaging("AddTask", "General", "EnablePseudoGrayOutput");
  end
  
  if strcmp(CRT_METHOD,"DataPixxM16OutputWithOverlay")
%       Want to use M16 mode: The appendix "WithOverlay" enables the color
%       overlay in M16 mode, so we can display colorful text:
      PsychImaging("AddTask", "General", "EnableDataPixxM16OutputWithOverlay");
  end
  
%   Want to have simple power-law gamma correction of stims: We choose the
%   method here. After opening the onscreen window, we can set and change
%   encoding gamma via PsychColorCorrection() function...
  PsychImaging("AddTask", "FinalFormatting", "DisplayColorCorrection", "SimpleGamma");
  
%   Open the onscreen window, get its handle and bounding rectangle. We open
%   with a grey background ( == 0.5 ) on display screen "screenid":
  [window, winRect] = PsychImaging("OpenWindow", screenid, 0.5);
  
  
%   Get a window handle for the overlay window - This only makes sense for
%   Bits++ Mono++ mode and DataPixx M16 mode though:
  if strcmp(CRT_METHOD,"DataPixxM16OutputWithOverlay")
      overlay = PsychImaging("GetOverlayWindow", window);
      OVERLAY_FILL = 0;
  else
%       In any other mode, our main "win"dow and overlay window are the same:
      overlay = window;
      LoadIdentityClut(window);
      OVERLAY_FILL = 0.5;
  end
  
  if strcmp(CRT_METHOD,"DataPixxM16OutputWithOverlay")
%     Upload a CLUT palette into the Bits++ or DPixx box for definition of overlay
%     colors. We define a nice "blue intensity ramp", this way our text, which
%     is anti-aliased, will look beautiful.
    clut = zeros(256,3);
    clut(1:256, 3) = transpose(linspace(0,1,256));
    Screen("LoadNormalizedGammaTable", window, clut, 2);
  end
  
%   Set encoding gamma: It is 1/gamma to compensate for decoding gamma...
  PsychColorCorrection("SetEncodingGamma", window, 1/CRT_GAMMA);
  
%   Set larger text size for text in overlay window:
  Screen("TextSize", overlay, 24);
  
endfunction

% ----------------------------------------------------------------------
function tr = getTimeParams(DO_SIM)
  
  if nargin < 1
    DO_SIM = 0;
  endif
  tr.hz = Screen("FrameRate",screenid);
  if (DO_SIM==0)
      tr.adaptDuration = 60;  % light adaptation length
      tr.stimDurationFrames = params.STIM_DURATION_FRAMES; % 12 frames = 100 ms at 120 Hz
      tr.stimDurationSec = params.STIM_DURATION_FRAMES / tr.hz;
      tr.isiDurationFrames = params.ISI_DURATION_FRAMES;
      tr.stim1onsetFrame = params.STIM_ONSET_FRAMES;
      tr.stim1offsetFrame = tr.stim1onsetFrame+tr.stimDurationFrames;
      tr.stim2onsetFrame = tr.stim1offsetFrame+tr.isiDurationFrames;
      tr.stim2offsetFrame=tr.stim2onsetFrame+tr.stimDurationFrames;
      tr.trialDurFrames = tr.stim1offsetFrame + tr.stimDurationFrames + tr.isiDurationFrames + tr.stimDurationFrames + tr.stim1offsetFrame;
      tr.trialDurSec = tr.trialDurFrames/tr.hz;
      tr.trialISI = 0.5; % seconds
      tr.observationISI = params.observationISI;    
   else
      tr.adaptDuration = 3;  % light adaptation length
      tr.stimDurationFrames = params.STIM_DURATION_FRAMES; % 12 frames = 100 ms at 120 Hz
      tr.stimDurationSec = params.STIM_DURATION_FRAMES / tr.hz;
      tr.isiDurationFrames = params.ISI_DURATION_FRAMES;
      tr.stim1onsetFrame = params.STIM_ONSET_FRAMES;
      tr.stim1offsetFrame = tr.stim1onsetFrame+tr.stimDurationFrames;
      tr.stim2onsetFrame = tr.stim1offsetFrame+tr.isiDurationFrames;
      tr.stim2offsetFrame=tr.stim2onsetFrame+tr.stimDurationFrames;
      tr.trialDurFrames = tr.stim1offsetFrame + tr.stimDurationFrames + tr.isiDurationFrames + tr.stimDurationFrames + tr.stim1offsetFrame;
      tr.trialDurSec = tr.trialDurFrames/tr.hz;
      tr.trialISI = 0.5; % seconds
      tr.observationISI = params.observationISI;    
   endif
    
endfunction

% -----------------------------------------------------------------------------

function [filename,exptPath,dataPath] = getFileName(params)
  tmp=mfilename("fullpath"); % complete pathname to this m-file
  s = strfind(tmp,M_FILE_NAME);
  exptPath = tmp(1:s(length(s)));
  dataPath = [exptPath "data/"];
  cd(exptPath);  
%   create file name:
  cd(dataPath);
  d=dir("*.mat");
  numfiles=length(d);
  gotName=0;
  N=0;
  while(gotName==0)
    N=N+1;
    sid = params.subjID;
    dnum = params.dayNum;
    tnum = params.textureID;
    ucond = params.uncertaintyID;
    if (strcmp(lower(ucond),"ske"))
      filename=[sid,"_",ucond,"_t",num2str(tnum),"_d",num2str(dnum),"_",num2str(N),FILE_XTENSION];
    else
      filename=[sid,"_",ucond,"_d",num2str(dnum),"_",num2str(N),FILE_XTENSION];      
    endif
    
    foundName=0;
    for kk=1:numfiles
      tmp=d(kk).name;
      foundName=strcmpi(filename,tmp);
      if(foundName==1)
        break;
       endif;
    endfor;
    if foundName==0
         gotName=1;
    endif;
  endwhile;
endfunction


% END EXPERIMENT%%%

endfunction
