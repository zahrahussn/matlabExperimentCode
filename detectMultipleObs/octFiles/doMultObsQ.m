%% Multiple observation 2IFC detection; ZH Oct 2019
%% Textures in one noise level, at one contrast

DEFAULT_SIMULATED_OBSERVER = 1; % set to zero if you are testing a real observer
DEFAULT_USE_QUEST = 1; % SET TO ZERO IF YOU DO NOT WANT TO USE QUEST
DEFAULT_NUMBER_OF_QUEST_TRIALS = 50;
DEFAULT_NUMBER_OF_DPRIME_TRIALS = 100; 

%DEFAULT_SIGNAL_CONTRAST_SD = 0.0002; % % DEFAULT VALUE WHEN YOU DO NOT USE QUEST
%DEFAULT_EXTERNAL_NOISE_CONTRAST_SD = 0.3162;
DEFAULT_SIGNAL_CONTRAST_SD = 0.012; % % DEFAULT VALUE WHEN YOU DO NOT USE QUEST
DEFAULT_EXTERNAL_NOISE_CONTRAST_SD = 0.2;



DEFAULT_VIEWING_DISTANCE_CM = 80; % to produce 4.8 x 4.8 deg stimulus on my display
 
ShowCursor;    
ResponsePixx('Close');
Datapixx('Close');
curpath = pwd;
cd('~/octFiles/multObs');
%params.calFile = "~/octFiles/gamma_calibration/Dell428F_calibration_20240212T164326.mat";
%params.calFile="~/octFiles/gamma_calibration/vpixx428G_calibration_20240220T171247.mat";
params.calFile=fullfile(octFilepath"~/octFiles/gamma_calibration/vpixx528G_calibration_20240712T140755.mat";

load(params.calFile);

% the calibration parameters are in calRec

params.wsize = calRec.wsize; % screen size in pixels
params.sCM = calRec.sCM; % screen size in cm
params.PixelsPerCm = calRec.PixelsPerCm; % pixels per cm
params.CRT_GAMMA = calRec.gammaFit; % gamma
params.lumRange = calRec.lumRange; % [min, avg, and max] luminance


%if (Datapixx('IsReady'))
%  Datapixx('Close');
%endif


% initialize parameters:
params.simulatedObserver = DEFAULT_SIMULATED_OBSERVER;
params.exptname = "multipleObjects";
params.uncertaintyID = upper("SKE");
%params.uncertaintyID = upper("SIMPLE");
%params.uncertaintyID = upper("COMPOSITE");
params.dayNum = 1;
params.nr = 256;
params.extNzVariance = (DEFAULT_EXTERNAL_NOISE_CONTRAST_SD)^2;	% external noise variance
%params.StartingStimVariance = (DEFAULT_SIGNAL_CONTRAST_SD)^2; % stimulus contrast VARIANCE
params.QuestThresholdGuess = (DEFAULT_SIGNAL_CONTRAST_SD)^2; % stimulus contrast VARIANCE
params.BaselineStimVariance = (DEFAULT_SIGNAL_CONTRAST_SD)^2; % stimulus contrast VARIANCE when QUEST is not used to find threshold
params.texFigureVar = (0.25)^2; % variance for noise-free image of signal shown in SKE condition

params.UseQuest = DEFAULT_USE_QUEST;
if (params.UseQuest==1)
  params.QuestTrials = DEFAULT_NUMBER_OF_QUEST_TRIALS;
else
  params.QuestTrials = 0;
endif
  
params.dprimeTrials = DEFAULT_NUMBER_OF_DPRIME_TRIALS;
params.numTrials = params.QuestTrials + params.dprimeTrials;
params.QuestSD = 2; % SD in log units
params.numObs = 5; %  number of observations per trial
params.textureID = 1;
params.maxTexID = 5; % maximum ID of the textures that we will use (i.e., textures 1-5)
params.USE_M16_MODE  = 1;
params.CRT_METHOD = "DataPixxM16OutputWithOverlay";
params.CRT_FRAMERATE = Screen('Framerate',1); %75;
params.viewingDistance = DEFAULT_VIEWING_DISTANCE_CM; % in cm
params.vdInches = params.viewingDistance*0.393701;
params.stimWidthCM = params.nr/params.PixelsPerCm;
params.stimWidthDEG = (180/pi)*atan2(params.stimWidthCM,params.viewingDistance);
params.aComment = '';  
params.theDate = datestr(now);
params.subjID = 'XXX';
params.noiseCondition = 'variable'; 
params.noiseType = 'white';

params.observationISI = 0.5; % seconds
params.fixPntDelaySec = 0.1; % interval between the end of fix point flicker and stimulus onset
params.STIM_ONSET_SEC = 0.1; % at start of trial: time between fixation point onset and stimulus 1 onset
params.STIM_ONSET_FRAMES = round(params.STIM_ONSET_SEC*params.CRT_FRAMERATE); % time between fixation point onset and stimulus onset
params.STIM_ONSET_SEC = params.STIM_ONSET_FRAMES/params.CRT_FRAMERATE;
params.STIM_DURATION_SEC = 0.20;
params.STIM_DURATION_FRAMES = round(params.STIM_DURATION_SEC*params.CRT_FRAMERATE);
params.STIM_DURATION_SEC = params.STIM_DURATION_FRAMES/params.CRT_FRAMERATE;
params.ISI_DURATION_SEC = 0.10;
params.ISI_DURATION_FRAMES = round(params.ISI_DURATION_SEC*params.CRT_FRAMERATE);
params.ISI_DURATION_SEC = params.ISI_DURATION_SEC/params.CRT_FRAMERATE;
params.PLAY_STIM_SOUND = 0;
params.aComment = "";  
params.theDate = datestr(now);
params.today = datestr(now,1);
params.curTime = datestr(now,13);
params.subjID = "XXX";



  
subjIDset = 0;
abortFlag = 0;


  
while abortFlag==0
  % get/set experimental parameters:
  gotOne = 0;
  while (gotOne == 0)
    fprintf("\n========= %s =========\n",params.theDate)
    fprintf("s.....Subject ID is %s\n",params.subjID);
    fprintf("u.....Uncertainty condition is %s\n",params.uncertaintyID);
    if (strcmp(params.uncertaintyID,"SKE"))
      fprintf("t.....Texture number is %i\n",params.textureID);      
    endif
    if (params.UseQuest==0)
      fprintf("c.....signal Contrast (SD) is fixed at %f\n",sqrt(params.BaselineStimVariance));
    else
      fprintf("c.....using QUEST to adjust signal contrast\n");
    endif
    fprintf("d.....testing Day number is %i\n",params.dayNum);
    fprintf("v.....Viewing distance is %.1f cm (%.2f inches)\n",params.viewingDistance,params.vdInches);
    fprintf("6.....Comment: %s\n",params.aComment);
    if params.USE_M16_MODE
      fprintf("7.....Using M16 display mode\n");
    else
      fprintf("7.....Using PseudoGray display mode\n");
    endif; 
%    fprintf("g.....display Gamma value is %f\n",params.CRT_GAMMA);
    fprintf("b.....Begin experiment\n");
    fprintf("x.....eXit\n");
    strInput=lower(input(" -->> ","s"));
    switch lower(strInput)
      case "s"
        params.subjID = upper(input("subject ID: ","s"));
        subjIDset = 1;
      case "u"
        fprintf('uncertainty\n')
        fprintf('\t 1.....Signal Known Exactly (SKE)\n');
        fprintf('\t 2.....Simple Signal(SIMPLE)\n');
        fprintf('\t 3.....Composite Signal(COMPOSITE)\n');
        uCondition = input(' --> ','s');
        switch uCondition
          case '1'
            params.uncertaintyID = upper("SKE");
          case '2'
            params.uncertaintyID = upper("SIMPLE");
          case '3'
            params.uncertaintyID = upper("COMPOSITE");
        end;  
        
      case "t"
        if (strcmp(params.uncertaintyID,"SKE"))
          s = input("texture number (1-5): ","s");
          [X, STATE] = str2num(s);
          if (STATE)
            tmpVal = round(X);
          endif;
          if (tmpVal>0)&(tmpVal<6)
            params.textureID = tmpVal;
          else
            fprintf("\n TEXTURE ID MUST BE BETWEEN 1 AND 5 INCLUSIVE!\n");
            pause(1)
          endif
        endif
        
      case "c"
        if (params.UseQuest==1)
          s = input("signal contrast SD: ","s");
          [X, STATE] = str2num(s);
          if (STATE)
            tmpVal = round(X);
          endif;
          if (tmpVal>0)&(tmpVal<0.5) % sanity check
            params.UseQuest=0; % contrast is now fixed
            params.BaselineStimVariance = tmpVal^2;
          endif
        else
          params.UseQuest=1; % use quest to adjust signal contrast
          params.QuestTrials = DEFAULT_NUMBER_OF_QUEST_TRIALS;
        endif
        
        
      case "d"
        s = input("Testing day number: ","s");
        [X, STATE] = str2num(s);
        if (STATE)
          tmpVal = round(X);
        endif;
        if (tmpVal>0)&(tmpVal<3)
          params.dayNum = tmpVal;
        else
          fprintf("\n DAY NUMBER MUST BE BETWEEN 1 AND 2 INCLUSIVE!\n");
          pause(1)
        endif
        
      case "6"
        params.aComment = input("Enter a comment: ","s");
%      case "7"
%        fprintf("\nswitching display mode...\n");
%        WaitSecs(0.25);
%        params.USE_M16_MODE = ~params.USE_M16_MODE;
%        if params.USE_M16_MODE
%          params.CRT_METHOD = "DataPixxM16OutputWithOverlay";
%          params.CRT_GAMMA = calRec.gammaFi;
%        else
%          params.CRT_METHOD = "PseudoGrayOutput";
%          params.CRT_GAMMA = calRec.gammaFi;
%        end;
      case "x"
        abortFlag = ~abortFlag;
        gotOne = 1;
      case "b"
        params.theDate = datestr(now);
        params.today = datestr(now,1);
        params.curTime = datestr(now,13);
        if subjIDset==1
          gotOne = 1;
        else
          fprintf ("continue with subject ID set to %s ? (y/n)",params.subjID);
          yesNo = lower(input(" --> ","s"));
          if yesNo=="y"
            gotOne = 1;
          endif
        endif       
      end % switch      
  endwhile;
        

  
  if abortFlag
    cd("~/octFiles/");
    return;
  end;
  
  close all; % close all figure windows
  cd('~/octFiles/multObs');
  eRec = multObsQ(params);
  fprintf("Experiment took %f to complete\n",(eRec.endTime-eRec.startTime)/60);

  if eRec.abortFlag==0
    eRec.postComment = input("Enter a comment (or hit return to continue): ","s");
    cd("~/octFiles/multObs");
    fprintf("Writing trial data to CSV file\n");
    err = writeMOBS_DataCSV(eRec);
    if (err!=0)
      fprintf("Error writing CSV data file.\n");
      return;
    endif
  endif; 

  abortFlag = eRec.abortFlag;
endwhile
cd(curpath);




return;







