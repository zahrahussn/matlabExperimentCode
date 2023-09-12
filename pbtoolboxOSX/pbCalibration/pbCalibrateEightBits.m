function calRec=pbCalibrateEightBits(stimpix,portNumber,rgbBackground,whichScreen)
%
% function calRec=pbCalibrateEightBits(stimpix,portNumber,rgbBackground,whichScreen)
%


% Prevents MATLAB from reprinting the source code when the program runs.
echo off


% For an explanation of the try-catch block, see the section "Error Handling"
% at the end of this document.
try

    if (exist('whichScreen')==0)
        % Find out how many screens and use largest screen number.
        whichScreen = max(Screen('Screens'));
        fprintf('No screen number provided. Using %g as default.\n',whichScreen);
    end;


    if (exist('rgbBackground')==0)
        fprintf('No rgb background provided. Will use [160,160,160] as default.\n');
        rgbBackground=[160 160 160];
    else
    	rgbBackground=rgbBackground(1)*[1 1 1];
        fprintf('rgb background = [%i, %i, %i].\n',rgbBackground(1),rgbBackground(2),rgbBackground(3));
    end;
    
    if (exist('portNumber')==0)
        fprintf('No port number provided. Will use 1 as default.\n');
        portNumber=1;
    end;
    
    if (exist('stimpix')==0)
        fprintf('No stim size provided. Will use 256 as default.\n');
        stimpix=256;
    end;
    
    WaitSecs(0.5); % wait a moment...
    fprintf('\n(calibration)$ please set the display to the desired spatial and temporal resolution\n')
    fprintf('(calibration)$ hit any key to continue...\n');
    WaitSecs(0.1);
    while(KbCheck==0)
	end;
    
    fprintf('\n(calibration)$ turn on the photometer...\n');
    fprintf('(calibration)$ hit any key to continue...\n');
    WaitSecs(0.1);
    while(KbCheck==0)
	end;
    fprintf('initializing photometer...\n');

	% ---------- Open Photometer ------
	retval = pb650init(portNumber);
    
	% ---------- Window Setup ----------
	% Opens a window.


	% Screen is able to do a lot of configuration and performance checks on
	% open, and will print out a fair amount of detailed information when
	% it does.  These commands supress that checking behavior and just let
    % the demo go straight into action.  See ScreenTest for an example of
    % how to do detailed checking.
% 	oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
%     oldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1);
	
%     % Find out how many screens and use largest screen number.
%     whichScreen = max(Screen('Screens'));
    
	% Hides the mouse cursor
	HideCursor;
	
	% Get the list of screens and choose the one with the highest screen number.
	% Screen 0 is, by definition, the display with the menu bar. Often when 
	% two monitors are connected the one without the menu bar is used as 
	% the stimulus display.  Chosing the display with the highest dislay number is 
	% a best guess about where you want the stimulus displayed.  
	screens=Screen('Screens');

    % Find the color values which correspond to white and black.  Though on OS
	% X we currently only support true color and thus, for scalar color
	% arguments,
	% black is always 0 and white 255, this rule is not true on other platforms will
	% not remain true on OS X after we add other color depth modes.  
	white=WhiteIndex(whichScreen);
	black=BlackIndex(whichScreen);
    gray=round((white+black)/2);
	if gray==white
		gray=black;
	end
	inc=white-gray;

	% Open a double buffered fullscreen window and draw a gray background 
	% to front and back buffers:
	[w,wrect]=Screen('OpenWindow',whichScreen, 0,[],32,2);
    % get & record screen properties
    hz=Screen('NominalFrameRate', whichScreen);
    fprintf('>>> display frame rate (Hz) = %g\n',hz);
    pixelSize=Screen('PixelSize', whichScreen);
    fprintf('>>> pixel size = %g\n',pixelSize);
    [widthmm, heightmm]=Screen('DisplaySize', whichScreen);
    widthcm=widthmm/10;
    heightcm=heightmm/10;
    fprintf('>>> display size (cm)[width, height] = [%g,%g]\n',widthcm,heightcm);
    [widthPixels, heightPixels]=Screen('WindowSize', whichScreen);
    fprintf('>>> display size (pixels)[width, height] = [%g,%g]\n',widthPixels,heightPixels);
    
	Screen('FillRect',w, rgbBackground);
	Screen('Flip', w);
	Screen('FillRect',w, rgbBackground);
	Screen('Flip', w);
    
    center = [wrect(3) wrect(4)]/2;	% coordinates of screen center (pixels)
    fps=Screen('FrameRate',w);      % frames per second
    if(fps==0)
        fps=67;
        fprintf('WARNING: using default frame rate of %i Hz\n',fps);
    end;
    ifi=Screen('GetFlipInterval', w);






	  

	% ---------- Image Setup ----------
	stimrect=SetRect(0,0,stimpix,stimpix);
	destRect=CenterRect(stimrect,wrect);

	Screen('FillRect',w,rgbBackground,destRect);
	Screen('FillOval',w,[0 0 0],destRect);			
	vbl=Screen('Flip', w,1);
    fprintf('\n\n>>> center photometer on stimulus area and hit a key to continue...\n');
    while(KbCheck==0)
	end;
    fprintf('taking measurements...\n');
	
	waitframes = 2;
	Screen('FillRect', w, rgbBackground,destRect);
	vbl=Screen('Flip', w,1);
	colorNumber=[1,10:10:250,255];
	rgbvalues=colorNumber'*[1 1 1];
%    colorNumber=[5,10:40:250,255];
	calData=zeros(length(colorNumber),8);

%     curRGB=1;
%     rgb=[0 0 0];
%     Screen('FillRect',w,rgbBackground,destRect);
%     Screen('FillOval',w,rgb,destRect);
%     vbl=Screen('Flip', w,1);
%     WaitSecs(0.1);
%     [qual,L,U,V]=pb650Measure;
%     calData(curRGB,:)=[rgb(1),rgb(2),rgb(3),qual,L,U,V];
%     curRGB=curRGB+1;

    for kk=1:length(colorNumber)
		rgb=rgbvalues(kk,:);
		Screen('FillRect',w,rgbBackground);
		Screen('FillOval',w,rgb,destRect);
		vbl=Screen('Flip', w,1);
		WaitSecs(0.1);
		[qual,L,U,V]=pb650Measure;
		calData(kk,:)=[rgb(1),rgb(1),rgb(2),rgb(3),qual,L,U,V];
		fprintf('RGB = [%i,%i,%i]; luminance = %g\n',rgb(1),rgb(2),rgb(3),L);
		WaitSecs(0.1);
		if KbCheck
			break;
		end;
	end;
	
	pb650close;
	% ---------- Window Cleanup ---------- 

	% Closes all windows.
	Screen('CloseAll');
	 
	% Restores the mouse cursor.
	ShowCursor;
    calRec.caldata=calData;
    calRec.background = rgbBackground;
    calRec.stimsize = stimpix;
    calRec.displaypixels =  [widthPixels, heightPixels];
    calRec.framerate = hz;
    calRec.displaycm =  [widthcm, heightcm];
    calRec.pixelsize = pixelSize;
    calRec.date = datestr(now);
    fprintf('(calibration)$ saving data in calTmpFile.mat\n');
    save 'calTmpFile' calRec;
    fprintf('(calibration)$ fitting pelli functions to data...\n');
    lutindex=calData(:,1);
    luminance=calData(:,6);
    calfuncparams=pbCalcCalFunction(lutindex,luminance,[0,255]);

	calRec.ABKG=calfuncparams.ABKG;

    minLum=pbPelliPower(calRec.ABKG,0);
    avgLum=pbPelliPower(calRec.ABKG,rgbBackground(1));
    maxLum=pbPelliPower(calRec.ABKG,255);
    calRec.lmaxminave=[maxLum,minLum,avgLum];


    tmp0=reshape(calfuncparams.lutnumber,length(calfuncparams.lutnumber),1);
    tmp0=(tmp0)*[1 1 1];
    tmp1=reshape(calfuncparams.lumfit,length(calfuncparams.lumfit),1);
    calRec.calmatrix=[tmp0,tmp1];

    
    %    lmaxminave=[bigdata(end,4),bigdata(1,4),bigdata(tmp,4)];
%    calFitRecord.lmaxminave=lmaxminave;
%    calFitRecord.REDparams=coeffs(1,:);
%    calFitRecord.GREENparams=coeffs(2,:);
%    calFitRecord.BLUEparams=coeffs(3,:);
%    calFitRecord.ABKG=coeffs(4,:);
%    calFitRecord.calmatrix=bigdata;

   
  

%     % Restore preferences
%     Screen('Preference', 'VisualDebugLevel', oldVisualDebugLevel);
%     Screen('Preference', 'SuppressAllWarnings', oldSupressAllWarnings);
catch
   
	% ---------- Error Handling ---------- 
	% If there is an error in our code, we will end up here.

	% The try-catch block ensures that Screen will restore the display and return us
	% to the MATLAB prompt even if there is an error in our code.  Without this try-catch
	% block, Screen could still have control of the display when MATLAB throws an error, in
	% which case the user will not see the MATLAB prompt.
	Screen('CloseAll');

	% Restores the mouse cursor.
	ShowCursor;
    
%     % Restore preferences
%     Screen('Preference', 'VisualDebugLevel', oldVisualDebugLevel);
%     Screen('Preference', 'SuppressAllWarnings', oldSupressAllWarnings);

	% We throw the error again so the user sees the error description.
	psychrethrow(psychlasterror);
    
end
