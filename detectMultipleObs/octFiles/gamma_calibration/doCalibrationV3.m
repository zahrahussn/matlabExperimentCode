
function calRec = doCalibrationV3;



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
uniGamma = 1;


% initialize parameters:
calRec.theDate = datestr(now);
calRec.today = datestr(now,1);
calRec.curTime = datestr(now,13);
calRec.displayName ="crtName";
calRec.fname = [calRec.displayName,"_calibration_",datestr(now,30),".mat"];
calRec.csvfname = [calRec.displayName,"_calibration_",datestr(now,30),".csv"];
calRec.computer = Screen('Computer');
[status,calRec.gcard] = system("lspci | grep VGA");
calRec.nr = 256;
[w,h] = Screen('WindowSize',screenid);
calRec.wsize = [w,h];
[w,h] = Screen('DisplaySize',screenid);
calRec.sCM = [w,h]/10;
calRec.PixelsPerCm = round(mean(calRec.wsize/calRec.sCM));
calRec.CRT_FRAMERATE = Screen('Framerate',1);
calRec.method=5;
switch calRec.method
  case 1
      calRec.mode = 'EnableNative10BitFramebuffer';
  case 2
      calRec.mode = 'EnablePseudoGrayOutput';
  case 5
      % Want to use M16 mode: The appendix "WithOverlay" enables the color
      % overlay in M16 mode, so we can display colorful text:
      calRec.mode = 'EnableDataPixxM16OutputWithOverlay';
  otherwise
      fprintf("Unkown video mode. Bye!\n");
      pause(1);
      return;
  end

% here is where we'll store fitted parameters:
% calRec.calMatrix = [];
% following lines are used for testing:
tmpFill = linspace(0,1,9);
tmpLum = rand(size(tmpFill)) + 2 + (10.*tmpFill).^2.2; 
calRec.calMatrix = transpose([tmpFill;tmpLum]);

calRec.gammaFit = NaN;
calRec.lumRange = [];


[win,winRect,overlay] = openDisplayWindow(calRec,uniGamma);
nzImage = round(rand(winRect(4),winRect(3)));
nzTex = Screen('MakeTexture', win, nzImage, [], [], 2);




abortFlag = 0;
while (abortFlag == 0)
  gotOne = 0;
  while (gotOne == 0)
    
    fprintf("\n========= %s =========\n",calRec.fname)
    fprintf("n.....display name is %s\n",calRec.displayName);
    fprintf("s.....pattern Size (pixels) is %i\n",calRec.nr);
    fprintf("g.....Geometry test\n");
    fprintf("c.....Calibrate display\n");
    fprintf("e.....Estimate gamma\n");
    fprintf("x.....eXit\n");
    strInput=lower(input(" -->> ","s"));
    switch strInput
      case "e"
        if (isempty(calRec.calMatrix)==0)
          fillValues = calRec.calMatrix(:,1);
          luminance = calRec.calMatrix(:,2);
          [calRec.gammaFit,calRec.lumRange] = estimateGamma(fillValues,luminance);
          fprintf('Min, Avg, and Max luminance = [%4.2f, %4.2f, %4.2f]\n',calRec.lumRange);
          fprintf('Estimate gamma = %4.3f\n',calRec.gammaFit);
        else
          fprintf('You need to calibrate the monitor first\n');
        endif
        
        
      case "n"
        calRec.displayName=input("new display name: -->> ","s");
        calRec.fname = [calRec.displayName,"_calibration_",datestr(now,30),".mat"];
        calRec.csvfname = [calRec.displayName,"_calibration_",datestr(now,30),".csv"];
      case "s"
        [x,state]=str2num(strInput);
        if state
          calRec.nr = floor(x);
        endif
      case "g"
        % adjust geometry
        nr = calRec.nr;
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
            calRec.geomTestLength = x;
            calRec.geomTestResolution = calRec.nr/x;
            fprintf("\nNominal resolution = %g\n",calRec.PixelsPerCm)
            fprintf("Measured resolution = %g\n",calRec.geomTestResolution);
          endif
        endwhile
      case "c"
        % calibrate display
        nr = calRec.nr;
        stimRect = SetRect(0,0,nr,nr);
        stimDestRect = CenterRect(stimRect,winRect);
        fillColor = linspace(0,1,9);
        fi = 1;
%        curColor = nan(1,length(fillColor));
%        curLum = nan(1,length(fillColor));
        curColor = [];
        curLum = [];
        curMeasurementNumber = 1;
        Screen('FillRect', overlay, 0.5);       
        toggle = 1;
        doLoop = 1;
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
        
        calRec.fillColor = curColor;
        calRec.luminance = curLum;
        Screen('FillRect', overlay, 0.5);
        Screen('DrawTexture', win, nzTex);
        Screen('Flip', win);
        nflushed = KbEventFlush();
        calRec.calMatrix = transpose([calRec.fillColor;calRec.luminance]);
        % write to CSV file:
        [nr,nc] = size(calRec.calMatrix);
        fid = fopen(calRec.csvfname,'w');
        if (fid < 0)
          err = -2;
          fprintf('Error opening csv file.\n');
        else
          fprintf('\n\nWriting calibration matrix to %s\n',calRec.csvfname);
          if (ftell(fid)==0)
            txt = 'val,lum\n';
            fprintf(fid,txt); % write header for CSV file
          end;        
          for kk=1:nr
            txt = sprintf('%f,%f\n',calRec.calMatrix(kk,:));
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


closeDisplayWindow(calRec,win);
Screen('Close'); 

fprintf('\n\nStoring calibration data in file %s\n',calRec.fname);
pause(1);          
save(calRec.fname,"calRec")




% Bye!
return


function [win,winRect,overlay] = openDisplayWindow(calRec,gamma)
  
  % Define requirements for onscreen window - Setup imaging pipeline:
  PsychImaging('PrepareConfiguration');
  
  % Want a full 32 bit floating point precision framebuffer:
  % This will provide an effective resolution of 23 bits in the displayable
  % luminance range -- Plenty of headroom for the up-to 16 bits output devices.
  % Hardware older than NVidia Geforce 8000 or ATI Radeon HD 2000 won't be
  % able to do alpha-blending at this mode though. Not an issue here, as we
  % don't need alpha-blending...
  PsychImaging('AddTask', 'General', 'FloatingPoint32Bit');
  
  if calRec.method == 1
      PsychImaging('AddTask', 'General', 'EnableNative10BitFramebuffer');
      calRec.mode = 'EnableNative10BitFramebuffer';
  end
  
  if calRec.method == 2
      PsychImaging('AddTask', 'General', 'EnablePseudoGrayOutput');
      calRec.mode = 'EnablePseudoGrayOutput';
  end
  
  if calRec.method == 5
      % Want to use M16 mode: The appendix "WithOverlay" enables the color
      % overlay in M16 mode, so we can display colorful text:
      PsychImaging('AddTask', 'General', 'EnableDataPixxM16OutputWithOverlay');
      calRec.mode = 'EnableDataPixxM16OutputWithOverlay';
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
  if calRec.method == 3 || calRec.method == 5
      overlay = PsychImaging('GetOverlayWindow', win);
  else
      % In any other mode, our main 'win'dow and overlay window are the same:
      overlay = win;
      LoadIdentityClut(win);
  end
  
  if calRec.method == 3 || calRec.method == 5
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

function closeDisplayWindow(calRec,win)
  
  if calRec.method == 3
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

function [gammaEst,lumRange] = estimateGamma(fillValues,luminance)
  
  % calculate mean values for luminance
  pixVal = sort(unique(fillValues));
  lumMean = zeros(size(pixVal));
  for (rk=1:(length(pixVal)))
    tmp = fillValues(:)==pixVal(rk);
    tdat = luminance(tmp);
    lumMean(rk) = mean(tdat(:));
  endfor
  % for testing:
%  pixVal	= linspace(0,1,9);
%  lumMean = [0.3588,2.031,6.791,15.31,28,45.37,67.68,95.57,128.9];

  gFunc = @(g,p)(p.^g(1)); % a power function
  backLight = lumMean(1);
  lumNorm = lumMean - backLight;
  lumNorm = lumNorm/max(lumNorm(:)); % lumNorm goes from zero to one
  gInit = 2.0;
  [gammaEst,R,J,covb,mse] = nlinfit(pixVal,lumNorm,gFunc,gInit);
  
  
  pixFit = transpose(linspace(0,1,100));
  lFit = (pixFit.^gammaEst);

  figure(1);
  xlabel('fill value');
  ylabel('normalized luminance');
  plot(pixVal,lumNorm,'x',pixFit,lFit,'-')
  mytxt = sprintf('Gamma = %4.3f',gammaEst);
  title(mytxt);

  figure(2);
  lum2 = lumNorm.^(1/gammaEst); % apply inverse gamma 
  [mSlope,bIntercept,R] = ols(lum2,pixVal);  % fit line to lum2
  lineFit2 = bIntercept + mSlope.*pixFit;
  plot(pixVal,lum2,'x',pixFit,lineFit2,'-')
  xlabel('fill value');
  ylabel('normalized luminance');
  title('Gamma-Corrected Normalized Luminance');
  
  figure(3);
  lum3 = lum2.*max(lumMean) + backLight;
  [mSlope,bIntercept,R] = ols(lum3,pixVal);  % fit line to lum3
  lineFit3 = bIntercept + mSlope.*pixFit;
  plot(pixVal,lum3,'x',pixFit,lineFit3,'-')
  xlabel('fill value');
  ylabel('luminance');
  title('Gamma-Corrected Luminance');
  
  Lmin = bIntercept + mSlope*0;
  Lavg = bIntercept + mSlope*0.5;
  Lmax = bIntercept + mSlope*1.0;
  lumRange = [Lmin,Lavg,Lmax];
  

endfunction

endfunction % end doCalibrationV3
