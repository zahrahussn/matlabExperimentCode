





method=5;
AssertOpenGL;
screenid = max(Screen('Screens'));

% initialize parameters:
params.nr = 256;
[w,h] = Screen('WindowSize',screenid)
params.wsize = [w,h];
[w,h] = Screen('DisplaySize',screenid)
params.sCM = [w,h]/10;
params.PixelsPerCm = round(mean(params.wsize/params.sCM));
params.CRT_FRAMERATE = Screen('Framerate',1);

%gamma = 1.4946;
gamma = 1;


% Key mappings, unified across operating systems:
KbName('UnifyKeyNames');
GammaDecrease = KbName('LeftArrow');
GammaIncrease = KbName('RightArrow');
SpaceKey = KbName('space');
Escape = KbName('ESCAPE');
Screen('Preference', 'VisualDebugLevel', 0);




% Define requirements for onscreen window - Setup imaging pipeline:
PsychImaging('PrepareConfiguration');

% Want a full 32 bit floating point precision framebuffer:
% This will provide an effective resolution of 23 bits in the displayable
% luminance range -- Plenty of headroom for the up-to 16 bits output devices.
% Hardware older than NVidia Geforce 8000 or ATI Radeon HD 2000 won't be
% able to do alpha-blending at this mode though. Not an issue here, as we
% don't need alpha-blending...
PsychImaging('AddTask', 'General', 'FloatingPoint32Bit');

if method == 1
    PsychImaging('AddTask', 'General', 'EnableNative10BitFramebuffer');
    params.mode = 'EnableNative10BitFramebuffer';
end

if method == 2
    PsychImaging('AddTask', 'General', 'EnablePseudoGrayOutput');
    params.mode = 'EnablePseudoGrayOutput';
end

%if method == 3
%    % Want to use Mono++ mode: The appendix "WithOverlay" enables the color
%    % overlay in Mono++ mode, so we can display colorful text:
%    PsychImaging('AddTask', 'General', 'EnableBits++Mono++OutputWithOverlay');
%    params.mode = 'EnableBits++Mono++OutputWithOverlay';
%end
%%
%if method == 4
%    PsychImaging('AddTask', 'General', 'EnableVideoSwitcherSimpleLuminanceOutput');
%end

if method == 5
    % Want to use M16 mode: The appendix "WithOverlay" enables the color
    % overlay in M16 mode, so we can display colorful text:
    PsychImaging('AddTask', 'General', 'EnableDataPixxM16OutputWithOverlay');
    params.mode = 'EnableDataPixxM16OutputWithOverlay';
end
%
%if method == 6
%    PsychImaging('AddTask', 'General', 'EnableNative11BitFramebuffer');
%end
%
%if method == 7
%    PsychImaging('AddTask', 'General', 'EnableNative16BitFramebuffer');
%end
%
%if method == 8
%    PsychImaging('AddTask', 'General', 'EnableNative16BitFloatingPointFramebuffer');
%end

% Want to have simple power-law gamma correction of stims: We choose the
% method here. After opening the onscreen window, we can set and change
% encoding gamma via PsychColorCorrection() function...
PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'SimpleGamma');

% Open the onscreen window, get its handle and bounding rectangle. We open
% with a black background ( == 0 ) on display screen 'screenid':
[win, winRect] = PsychImaging('OpenWindow', screenid, 0);

% Get a window handle for the overlay window - This only makes sense for
% Bits++ Mono++ mode and DataPixx M16 mode though:
if method == 3 || method == 5
    overlay = PsychImaging('GetOverlayWindow', win);
else
    % In any other mode, our main 'win'dow and overlay window are the same:
    overlay = win;
    LoadIdentityClut(win);
end

if method == 3 || method == 5
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

% Draw new one:
mytxt = 'Press any key to continue.\n';

DrawFormattedText(overlay, mytxt, 'center', 'center', 255);
Screen('Flip', win);

% Wait for keystroke to start:
KbStrokeWait;

nr = 384;
f = 8;
c = 0.2;
o = 0;
p = 0;

patImage = 0.5 + c .* pbGabor(nr,f,1,p,o,0.8,0.8);
patTex=Screen('MakeTexture', win, patImage, [], [], 2);

stimRect = SetRect(0,0,nr,nr);
stimDestRect = CenterRect(stimRect,winRect);
fillColor = linspace(0,1,9);
fi = 1;

nzImage = round(rand(winRect(4),winRect(3)));
nzTex = Screen('MakeTexture', win, nzImage, [], [], 2);

Screen('FillRect', overlay, 0.5);

waitTimeSecs = 1/60;
patOrientation = 0;
RotDegPerSec = 180/1;
toggle = 1;
doLoop = 1;
while doLoop 
  if (toggle)
    Screen('DrawTexture', win, nzTex);
%    Screen('FillRect', win, 0.5);
    Screen('FillOval', win, fillColor(fi), stimDestRect);
%    Screen('DrawTexture', win, patTex, [], [], patOrientation, 0);
    txt1 = sprintf('Stimulus: %f', fillColor(fi));
    % Draw new text into it: We draw with index color 1 out of set of (1-255):
%              Screen('FillRect', overlay, 0);
    DrawFormattedText(overlay, [txt1], 64, 64, 255);
 
    Screen('Flip', win);
    toggle = 0;
  end;
  
%  WaitSecs(waitTimeSecs);
%  patOrientation = patOrientation + RotDegPerSec*waitTimeSecs;
%  if (patOrientation >= 360)
%    patOrientation = 0;
%  end;
  [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
  if keyIsDown
      if keyCode(Escape)
        doLoop = 0;
      elseif (keyCode(SpaceKey))
        toggle = 1;
        fi = fi + 1;
        if (fi>length(fillColor))
          fi = 1;
        end;
        WaitSecs(0.5);
      end;     
  end;
    
end;
  
%  if (keyIsDown)
%    if (keyCode==SpaceKey)
%      fi = fi + 1;
%      if (fi > length(fillColor))
%        fi = 1;
%      end;
%    elseif (keyCode==Escape)
%      doLoop = 0;
%    end;
%  end;
   





if method == 3
    % Load identity CLUT into Bits++ to restore proper display:
    BitsPlusPlus('LoadIdentityClut', win);
end

% This flip is needed for the 'LoadIdentityClut' to take effect:
Screen('Flip', win);

% Load old gamma tables into gfx-card:
RestoreCluts;

% Demo done. Close Screen...
Screen('CloseAll');

% Bye!
return;
