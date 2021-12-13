
function calMat = zhCal()

clear all;
timeout=30;
stimpix = 512;
rgbBackground = [190 190 190];
%rgbIndex = [0, 1, 5, 10, 30, 50, 100, 150, 200, 250, 255];
rgbIndex = [0, 100, 250];
randOrder = randperm(length(rgbIndex));
calMat = zeros(length(rgbIndex), 2);
N=zeros(1,1);
Lum=N;

oldEnableFlag = Screen('Preference', 'SuppressAllWarnings', 1);
whichScreen = max(Screen('Screens'));

WaitSecs(0.5); % wait a moment...
fprintf('\n(calibration)$ please set the display to the desired spatial and temporal resolution\n')
fprintf('(calibration)$ hit any key to continue...\n');
WaitSecs(0.1);
while(KbCheck==0)
end;

fprintf('\n(calibration)$ turn on the photometer...\n');
fprintf('(calibration)$ hit any key to continue...\n');
WaitSecs(0.5);
while(KbCheck==0)
end;
fprintf('initializing photometer...\n');

retval = PR655init;  % initialize the photometer

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
[w,wrect]=Screen('OpenWindow',whichScreen, 0,[],32,2);
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
%[widthcm,heightcm] = pbGetScreenDimensions(whichScreen);


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
meas1=PR655rawxyz(30)

fprintf('\n\n>>> center photometer on stimulus area and hit a key to continue...\n');

while(KbCheck==0)
end;
% Screen('CloseAll');
Screen('Preference','SuppressAllWarnings',oldEnableFlag);


for curRGB=1:length(rgbIndex)
      Screen('FillRect',w,rgbBackground,destRect);
      vbl=Screen('Flip', w,0);
      WaitSecs(1.5);
      ktmp=randOrder(curRGB);
      curRGBnumber=rgbIndex(ktmp);
      V = rgbIndex(ktmp);
      rgb = [V V V];
      Priority(MaxPriority(w));
      Screen('FillRect',w,rgbBackground);
      Screen('FillOval',w,rgb,destRect);
      vbl=Screen('Flip', w,0);
      WaitSecs(0.2);
      meas = PR655rawxyz(timeout);
%        WaitSecs(30);
        rr = str2num(meas);
        L = rr(3);
%         
        calMat(curRGB,1)= V;
        calMat(curRGB,2)= L;
        N(ktmp)=curRGBnumber;
        Lum(ktmp)=L;
 		fprintf('RGB = [%3i,%3i,%3i]; luminance = %6.2f; rgbIndex = %g\n',rgb(1),rgb(2),rgb(3),L,curRGBnumber);
        WaitSecs(0.1);

         if KbCheck
            abortFlag=1;
            break;
        end;

	end;
    
    PR655close;
    
    Screen('CloseAll');
    Screen('Preference','SuppressAllWarnings',oldEnableFlag);   
	% Restores the mouse cursor.
	ShowCursor;
    
    save calMat calMat;

end


    
