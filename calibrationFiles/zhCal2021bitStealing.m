
function [rgbTable,calRec] = zhCal2021bitStealing()

clear all;

debug=false;
if debug
    rect0 = [0,0,1000,600];
else
    rect0 = [];
end



%timeout=30;
stimpix = 512;
rgbBackground = [160 160 160];
rgbIndex = [1, 5, 10, 30, 50, 100, 150, 200, 250, 255];
nMeas=length(rgbIndex);
%randOrder = randperm(length(rgbIndex));
calMat = zeros(length(rgbIndex), 2);
N=zeros(1,1);
Lum=N;
escapeKey = KbName('Escape');

oldEnableFlag = Screen('Preference', 'SuppressAllWarnings', 1);
whichScreen = max(Screen('Screens'));
% widthcm=57.4; % Viewpixx (with bezel)
% heightcm=39.18;
[widthmm, heightmm] = Screen('DisplaySize', max(Screen('Screens')));
widthcm = widthmm/10;
heightcm = heightmm/10;


WaitSecs(0.5); % wait a moment...
% fprintf('\n(calibration)$ please set the display to the desired spatial and temporal resolution\n')
% fprintf('(calibration)$ hit any key to continue...\n');
% WaitSecs(0.1);
% while(KbCheck==0)
% end
% 
% fprintf('\n(calibration)$ turn on the photometer...\n');
% fprintf('(calibration)$ hit any key to continue...\n');
% WaitSecs(0.5);
% while(KbCheck==0)
% end
%fprintf('initializing photometer...\n');
Screen('Preference', 'SkipSyncTests', 1)
Screen('Preference','VisualDebugLevel', 0)
Screen('Preference','SuppressAllWarnings', 1)   

%retval = PR655init;  % initialize the photometer

% Opens a window.
screens=Screen('Screens');
white=WhiteIndex(whichScreen);
black=BlackIndex(whichScreen);
gray=round((white+black)/2);
if gray==white
    gray=black;
end
    
% Open a double buffered fullscreen window and draw a gray background 
% % to front and back buffers:
% WaitSecs(1);
[w,wrect]=Screen('OpenWindow',whichScreen, 0,rect0,32,2);
% 
 Screen('FillRect',w, rgbBackground);
 Screen('Flip', w);
% Screen('FillRect',w, rgbBackground);
% Screen('Flip', w);

% get & record screen properties
hz=Screen('NominalFrameRate', whichScreen);
fprintf('>>> display frame rate (Hz) = %g\n',hz);
pixelSize=Screen('PixelSize', whichScreen);
fprintf('>>> pixel size = %g\n',pixelSize);

[widthPixels, heightPixels]=Screen('WindowSize', whichScreen);
fprintf('>>> display size (pixels)[width, height] = [%g,%g]\n',widthPixels,heightPixels);


center = [wrect(3) wrect(4)]/2;	% coordinates of screen center (pixels)
fps=Screen('FrameRate',w);      % frames per second
% if(fps==0)
%         fps=67;
%         fprintf('WARNING: using default frame rate of %i Hz\n',fps);
%     end;
% ifi=Screen('GetFlipInterval', w);

% ---------- Image Setup ----------
stimrect=SetRect(0,0,stimpix,stimpix);
destRect=CenterRect(stimrect,wrect);
Screen('FillRect',w,rgbBackground,destRect);
Screen('FillOval',w,[0 0 0],destRect);			
Screen('DrawText',w,'Center photometer on stimulus area and hit a key to continue..', 300, 200);
vbl=Screen('Flip', w,1);
%meas1=PR655rawxyz(30)

fprintf('\n\n>>> center photometer on stimulus area and hit a key to continue...\n');

while(KbCheck==0)
end
% Screen('CloseAll');
Screen('Preference','SuppressAllWarnings',oldEnableFlag);

% construct RGB table for the three guns
rgbTable = zeros(2+3*nMeas,4); % first row is for DC offset measurement
rgbTable(2:end,4)=1; % second row is for background offset measurement
c = 2; % rest is for R, G and B gun measurements
for i = 1:3
    for curRGB = 1:nMeas
        c = c + 1;
        rgbTable(c,i) = rgbIndex(curRGB);
    end
end

for curRGB=1:size(rgbTable,1)
    Screen('FillRect',w,rgbTable(curRGB,4)*rgbBackground);
    vbl=Screen('Flip', w,0);
    WaitSecs(.5);
    % ktmp=randOrder(curRGB);
    Priority(MaxPriority(w));
%     Screen('FillRect',w,rgbTable(curRGB,4)*rgbBackground);
    Screen('FillOval',w,rgbTable(curRGB,1:3),destRect);
    Screen('DrawText',w,sprintf('Meas. %d/%d',curRGB,size(rgbTable,1)), wrect(3)-150, wrect(4)-30, rgbTable(curRGB,4)*rgbBackground+50);
    vbl=Screen('Flip', w,0);
    while(KbCheck==0)
        [keyIsDown,secs,keyCode] = KbCheck;
         if  keyCode(escapeKey)==1
             Screen('CloseAll')
         end 
    end
end
    
    
    Screen('CloseAll');
    Screen('Preference','SuppressAllWarnings',oldEnableFlag);   
	% Restores the mouse cursor.
	ShowCursor;
    
    calRec.calType='BITSTEALING';
    calRec.date=datestr(now);
    calRec.stimsize = stimpix;
    calRec.displaypixels =  [widthPixels, heightPixels];
    calRec.framerate = hz;
    calRec.displaycm =  [widthcm, heightcm];
    calRec.pixelsize = pixelSize;    
    calRec.backgroundRGB = rgbBackground;


    save(sprintf('rgbTable_%s',strrep(datestr(now),':','-')),'rgbTable');
    save(sprintf('calRec_%s',strrep(datestr(now),':','-')),'calRec');
end


    
