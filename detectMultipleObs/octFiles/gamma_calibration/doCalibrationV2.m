
function params = doCalibrationV2;


Screen('Closeall')
Datapixx('Close')
close all;
fclose("all");
pkg load optim;


AssertOpenGL;


% Key mappings, unified across operating systems:
KbName('UnifyKeyNames');
GammaDecrease = KbName('LeftArrow');
GammaIncrease = KbName('RightArrow');
SpaceKey = KbName('space');
Escape = KbName('ESCAPE');
LeftShift = KbName('LeftShift');
RightShift = KbName('RightShift');
FiveKey = KbName('5');
Screen('Preference', 'VisualDebugLevel', 0);


screenid = max(Screen('Screens'));
%gamma = 1.4946;
calGamma = 1;


% initialize parameters:
params.theDate = datestr(now);
params.today = datestr(now,1);
params.curTime = datestr(now,13);
params.displayName ="crtName";
params.fname = [params.displayName,"_calibration_",datestr(now,30),".mat"];
params.csvfname = [params.displayName,"_calibration_",datestr(now,30),".csv"];
params.nr = 256;
[w,h] = Screen('WindowSize',screenid);
params.wsize = [w,h];
[w,h] = Screen('DisplaySize',screenid);
params.sCM = [w,h]/10;
params.PixelsPerCm = round(mean(params.wsize/params.sCM));
params.CRT_FRAMERATE = Screen('Framerate',1);
params.method=5;
switch params.method
  case 1
      params.mode = 'EnableNative10BitFramebuffer';
  case 2
      params.mode = 'EnablePseudoGrayOutput';
  case 5
      % Want to use M16 mode: The appendix "WithOverlay" enables the color
      % overlay in M16 mode, so we can display colorful text:
      params.mode = 'EnableDataPixxM16OutputWithOverlay';
  otherwise
      fprintf("Unkown video mode. Bye!\n");
      pause(1);
      return;
  end


[win,winRect,overlay] = openDisplayWindow(params,calGamma);
nzImage = round(rand(winRect(4),winRect(3)));
nzTex = Screen('MakeTexture', win, nzImage, [], [], 2);




abortFlag = 0;
while (abortFlag == 0)
  gotOne = 0;
  while (gotOne == 0)
    
    fprintf("\n========= %s =========\n",params.fname)
    fprintf("n.....display name is %s\n",params.displayName);
    fprintf("s.....pattern Size (pixels) is %i\n",params.nr);
    fprintf("g.....Geometry test\n");
    fprintf("c.....Calibrate display\n");
    fprintf("x.....eXit\n");
    strInput=lower(input(" -->> ","s"));
    switch strInput
      case "n"
        params.displayName=input("new display name: -->> ","s");
        params.fname = [params.displayName,"_calibration_",datestr(now,30),".mat"];
        params.csvfname = [params.displayName,"_calibration_",datestr(now,30),".csv"];
      case "s"
        [x,state]=str2num(strInput);
        if state
          params.nr = floor(x);
        endif
      case "g"
        % adjust geometry
        nr = params.nr;
        stimRect = SetRect(0,0,nr,nr);
        stimDestRect = CenterRect(stimRect,winRect);
        fillColor = 0;
        % show pattern
        Screen('FillRect', overlay, 0.5);
        Screen('DrawTexture', win, nzTex);
        Screen('FillRect', win, fillColor, stimDestRect);
        Screen('Flip', win);
        
        mytxt = 'Press any key to continue.\n';
        fprintf(mytxt)
        KbStrokeWait; % Wait for keystroke
        
        Screen('FillRect', overlay, 0.5);
        Screen('DrawTexture', win, nzTex);
        Screen('Flip', win);
        gotLength = 0;
        while(gotLength==0)
          strInput=lower(input("length of 1 side of square (cm): -->> ","s"));
          [x,state]=str2num(strInput);
          if state
            gotLength = 1;
            params.geomTestLength = x;
            params.geomTestResolution = params.nr/x;
            fprintf("\nNominal resolution = %g\n",params.PixelsPerCm)
            fprintf("Measured resolution = %g\n",params.geomTestResolution);
          endif
        endwhile
      case "c"
        % calibrate display
        nr = params.nr;
        stimRect = SetRect(0,0,nr,nr);
        stimDestRect = CenterRect(stimRect,winRect);
        fillColor = linspace(0,1,9);
        fi = 1;
        curColor = nan(1,length(fillColor));
        curLum = nan(1,length(fillColor));
        curMeasurementNumber = 1;
        Screen('FillRect', overlay, 0.5);       
        toggle = 1;
        doLoop = 1;
%        fprintf('\nHit the space bar to record luminance\n');
%        fprintf('Hit Escape key to return to menu\n\n');
%        pause(1);
        while doLoop 
          if (toggle)
            Screen('DrawTexture', win, nzTex);
            Screen('FillOval', win, fillColor(fi), stimDestRect);
            txt1 = sprintf('Stimulus: %f', fillColor(fi));
            % Draw new text into it: We draw with index color 1 out of set of (1-255):
            Screen('FillRect', overlay, 0.5);
            DrawFormattedText(overlay, [txt1], 64, 64, 255);         
            Screen('Flip', win);
            toggle = 0;
          end; % toggle 
          mytxt = sprintf("Fill Colour = %i; Luminance (negative to exit): -->> ",fillColor(fi));
          gotLumMeasure = 0;
          while(gotLumMeasure==0)
            strInput=lower(input(mytxt,"s"));
            [x,gotLumMeasure]=str2num(strInput);
          endwhile % gotLumMeasure
          if x < 0
            doLoop = 0;
          else
            curColor(curMeasurementNumber) = fillColor(fi);
            curLum(curMeasurementNumber) = x;
            curMeasurementNumber = curMeasurementNumber + 1;
            % go to next fill color:
            toggle = 1;
            fi = fi + 1;
            if (fi>length(fillColor))
              fi = 1;
            end;
            WaitSecs(0.5);
          endif
          

        endwhile % doLoop
        params.fillColor = curColor;
        params.luminance = curLum;
        Screen('FillRect', overlay, 0.5);
        Screen('DrawTexture', win, nzTex);
        Screen('Flip', win);
        nflushed = KbEventFlush();
        params.calMatrix = transpose([params.fillColor;params.luminance]);
        % write to CSV file:
        [nr,nc] = size(params.calMatrix);
        fid = fopen(params.csvfname,'w');
        if (fid < 0)
          err = -2;
          fprintf('Error opening csv file.\n');
        else
          fprintf('\n\nWriting calibration matrix to %s\n',params.csvfname);
          if (ftell(fid)==0)
            txt = 'val,lum\n';
            fprintf(fid,txt); % write header for CSV file
          end;        
          for kk=1:nr
            txt = sprintf('%f,%f\n',params.calMatrix(kk,:));
            fprintf(fid,txt); % write to file
          end
          err = fclose(fid);
        endif
      case "x"
        gotOne = 1;      
        abortFlag = 1;
    endswitch
  endwhile % gotOne
endwhile % abortFlag


closeDisplayWindow(params,win);
Screen('Close');           
save(params.fname,"params")



%%
%%
%%nr = params.nr;
%%f = 8;
%%c = 0.2;
%%o = 0;
%%p = 0;
%%
%%patImage = 0.5 + c .* pbGabor(nr,f,1,p,o,0.8,0.8);
%%patTex=Screen('MakeTexture', win, patImage, [], [], 2);
%%
%%stimRect = SetRect(0,0,nr,nr);
%%stimDestRect = CenterRect(stimRect,winRect);
%%fillColor = linspace(0,1,9);
%%fi = 1;
%%
%%nzImage = round(rand(winRect(4),winRect(3)));
%%nzTex = Screen('MakeTexture', win, nzImage, [], [], 2);
%%
%%Screen('FillRect', overlay, 0.5);
%%
%%waitTimeSecs = 1/60;
%%patOrientation = 0;
%%RotDegPerSec = 180/1;
%%toggle = 1;
%%doLoop = 1;
%%while doLoop 
%%  if (toggle)
%%    Screen('DrawTexture', win, nzTex);
%%    Screen('FillOval', win, fillColor(fi), stimDestRect);
%%    txt1 = sprintf('Stimulus: %f', fillColor(fi));
%%    % Draw new text into it: We draw with index color 1 out of set of (1-255):
%%    DrawFormattedText(overlay, [txt1], 64, 64, 255);
%% 
%%    Screen('Flip', win);
%%    toggle = 0;
%%  end;
%%  
%%  [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
%%  if keyIsDown
%%      if keyCode(Escape)
%%        doLoop = 0;
%%      elseif (keyCode(SpaceKey))
%%        toggle = 1;
%%        fi = fi + 1;
%%        if (fi>length(fillColor))
%%          fi = 1;
%%        end;
%%        WaitSecs(0.5);
%%      end;     
%%  end;
%%    
%%end;
%%  


% Bye!
return


function [win,winRect,overlay] = openDisplayWindow(params,gamma)
  
  % Define requirements for onscreen window - Setup imaging pipeline:
  PsychImaging('PrepareConfiguration');
  
  % Want a full 32 bit floating point precision framebuffer:
  % This will provide an effective resolution of 23 bits in the displayable
  % luminance range -- Plenty of headroom for the up-to 16 bits output devices.
  % Hardware older than NVidia Geforce 8000 or ATI Radeon HD 2000 won't be
  % able to do alpha-blending at this mode though. Not an issue here, as we
  % don't need alpha-blending...
  PsychImaging('AddTask', 'General', 'FloatingPoint32Bit');
  
  if params.method == 1
      PsychImaging('AddTask', 'General', 'EnableNative10BitFramebuffer');
      params.mode = 'EnableNative10BitFramebuffer';
  end
  
  if params.method == 2
      PsychImaging('AddTask', 'General', 'EnablePseudoGrayOutput');
      params.mode = 'EnablePseudoGrayOutput';
  end
  
  if params.method == 5
      % Want to use M16 mode: The appendix "WithOverlay" enables the color
      % overlay in M16 mode, so we can display colorful text:
      PsychImaging('AddTask', 'General', 'EnableDataPixxM16OutputWithOverlay');
      params.mode = 'EnableDataPixxM16OutputWithOverlay';
  end
  
  % Want to have simple power-law gamma correction of stims: We choose the
  % method here. After opening the onscreen window, we can set and change
  % encoding gamma via PsychColorCorrection() function...
  PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'SimpleGamma');
  
  % Open the onscreen window, get its handle and bounding rectangle. We open
  % with a black background ( == 0 ) on display screen 'screenid':
  [win, winRect] = PsychImaging('OpenWindow', screenid, 0);
  
  % Get a window handle for the overlay window - This only makes sense for
  % Bits++ Mono++ mode and DataPixx M16 mode though:
  if params.method == 3 || params.method == 5
      overlay = PsychImaging('GetOverlayWindow', win);
  else
      % In any other mode, our main 'win'dow and overlay window are the same:
      overlay = win;
      LoadIdentityClut(win);
  end
  
  if params.method == 3 || params.method == 5
      % Upload a CLUT palette into the Bits++ or DPixx box for definition of overlay
      % colors. We define a nice "blue intensity ramp", this way our text, which
      % is anti-aliased, will look beautiful.
      clut = zeros(256,3);
      clut(1:256, 3) = linspace(0,1,256)';
      Screen('LoadNormalizedGammaTable', win, clut, 2);
  end
  
  % Set encoding gamma: It is 1/gamma to compensate for decoding gamma...
  PsychColorCorrection('SetEncodingGamma', win, 1/gamma);
  
  % Set larger text size for text in overlay window:
  Screen('TextSize', overlay, 48);
      
  
  % Set encoding gamma: It is 1/gamma to compensate for decoding gamma...
  PsychColorCorrection('SetEncodingGamma', win, 1/gamma);
  
  % Set larger text size for text in overlay window:
  Screen('TextSize', overlay, 24);

  % Clear overlay from old text:
  Screen('FillRect', overlay, 0.5);


endfunction

function closeDisplayWindow(params,win)
  
  if params.method == 3
      % Load identity CLUT into Bits++ to restore proper display:
      BitsPlusPlus('LoadIdentityClut', win);
  end
  
  % This flip is needed for the 'LoadIdentityClut' to take effect:
  Screen('Flip', win);
  
  % Load old gamma tables into gfx-card:
  RestoreCluts;
  
  % Demo done. Close Screen...
  Screen('CloseAll');
endfunction

function y=gFunc(p,g)
  y = p^g;
endfunction

endfunction
