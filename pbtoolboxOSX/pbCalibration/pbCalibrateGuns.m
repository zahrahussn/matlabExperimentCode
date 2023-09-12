function [redGun,greenGun,blueGun]=pbCalibrateGuns()
%
% [redGun,greenGun,blueGun] = pbCalibrateGuns()
%


% Prevents MATLAB from reprinting the source code when the program runs.
echo off


% For an explanation of the try-catch block, see the section "Error Handling"
% at the end of this document.
try
    whichScreen = max(Screen('Screens'));
    rgbBackground=[160 160 160];
%     bkgrndRGBnumber = pbRGB2BitStealingIndex(rgbBackground);
    
    portNumber=1;
    reps=2;
    if(exist('rgbIndex','var')==1)
        if (length(rgbIndex)<2)
            dpf=0; % dpf : do Pelli Fit
        else
            dpf=1;
        end;
    else
        dpf=1;
    end;
    stimpix=512;
    alldone=0;
    while (alldone==0)
        gotone=0;
        while (gotone==0)
            fprintf('\tCalibration Parameters:\n');
            fprintf('\t1... screen number = %i\n',whichScreen);
            fprintf('\t2... port number = %i\n',portNumber);
            fprintf('\t3... stimulus size (pixels) = %i\n',stimpix);
            if (dpf==1)
                fprintf('\t4... fit pelli function to data? YES\n');
            else
                fprintf('\t4... fit pelli function to data? NO\n');
            end;   
            fprintf('\t5... reps = %i\n',reps);
            fprintf('\td... do calibration\n');
            fprintf('\tx... exit\n');
            theInput=lower(input(sprintf('\t>> '),'s'));
            gotone=ismember(theInput,'12345dx');
        end; % while(gotone)

        switch theInput
            case '1'
                tmp = input(sprintf('\t screen number >> '));
                if isnumeric(tmp)
                    whichScreen=round(abs(tmp));
                end;
            case '2'
                tmp = input(sprintf('\t port number >> '));
                if isnumeric(tmp)
                    portNumber=round(abs(tmp));
                end;
            case '3'
                tmp = input(sprintf('\t stimulus size (pixels) >> '));
                if isnumeric(tmp)
                    stimpix=round(abs(tmp));
                end;
            case '4'
                dpf=not(dpf);
            case '5'
                tmp = input(sprintf('\t number of repetitions >> '));
                if isnumeric(tmp)
                    reps=round(abs(tmp));
                end;
            case 'd'
                alldone=1;
            case 'x'
                fprintf('calibration procedure aborted by user\n');
                calibrationRecord=NaN;
                return;

        end; % switch theInput
    end; % while alldone




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
		retval = pb650init(portNumber);

%         activeGun = lower(activeGun);
%     switch activeGun
%         case 'red'
%             rgbMask = [1 0 0];
%         case 'green'
%             rgbMask = [0 1 0];
%         case 'blue'
%             rgbMask = [0 0 1];
%         otherwise
%             error('activeGun must be red, green or blue');
%     end;

    
    
	    
	% ---------- Window Setup ----------
	% Opens a window.
	screens=Screen('Screens');
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
    fprintf('>>> display size (cm)[width, height] = [%g,%g]\n >>> N.B. These numbers may be inaccurate; PLEASE CHECK!!\n',widthcm,heightcm);
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

    fprintf('\n\n>>> center photometer on stimulus area and hit a key to continue...\n');
    while(KbCheck==0)
	end;
    fprintf('taking measurements...\n');
    fprintf('HOLD DOWN ANY KEY TO ABORT...\n\n');
	
	waitframes = 2;
    
 

% 	Screen('FillRect',w, [0 0 0]);
% 	Screen('Flip', w);
% 	Screen('FillRect',w, [0 0 0]);
% 	Screen('Flip', w);
%     fprintf('\n\n>>> taking zero measurement...\n');
%     rgb=[0 0 0];
%     [qual,DCOFFSET,U,V] = getMeasurement(w,[0 0 0],rgb,destRect,2);
%     fprintf('RGB = [%3i,%3i,%3i]; DC OFFSET = %6.2f\n\n',rgb(1),rgb(2),rgb(3),DCOFFSET);
%     
%     Screen('FillRect',w, rgbBackground);
%     Screen('Flip', w);
%     Screen('FillRect',w, rgbBackground);
%     Screen('Flip', w);
%     fprintf('\n\n>>> taking background measurement...\n');
%     rgb=[0 0 0];
%     [qual,BACKGROUND,U,V] = getMeasurement(w,rgbBackground,rgb,destRect,3);
%     fprintf('RGB = [%3i,%3i,%3i]; BACKGROUND = %6.2f\n\n',rgb(1),rgb(2),rgb(3),BACKGROUND);
%     pb650close;
% 	% Closes all windows.
% 	Screen('CloseAll');
    
    
    [tmp,dcOffset]=pbGunMeasurements('red',512,2,[0 0 0],1,1,0);
    [tmp,bkgrndOffset]=pbGunMeasurements('red',512,2,[160 160 160],1,1,0);
    [Nred,redData]=pbGunMeasurements('red',512,2,[160 160 160],1,3,[10:10:250,255]);
    [Ngreen,greenData]=pbGunMeasurements('green',512,2,[160 160 160],1,3,[20:10:250,255]);
    [Nblue,blueData]=pbGunMeasurements('blue',512,2,[160 160 160],1,3,[30:10:250,255]);

    % convert data to Luminance
    redLum=[redData-dcOffset-bkgrndOffset]';
    redLum=max(redLum,0);
    % insert zero:
    redLum=[0;redLum];
    redLUT=[0,Nred]';

    greenLum=[greenData-dcOffset-bkgrndOffset]';
    greenLum=max(greenLum,0);
    greenLum=[0;greenLum];
    greenLUT=[0,Ngreen]';

    blueLum=[blueData-dcOffset-bkgrndOffset]';
    blueLum=max(blueLum,0);
    blueLum=[0;blueLum];
    blueLUT=[0,Nblue]';
    
    % interpolate from 0 to 255
    redNumber=0:255;
    redInterpolated=interp1(redLUT,redLum,redNumber,'pchip');
    greenNumber=0:255;
    greenInterpolated=interp1(greenLUT,greenLum,greenNumber,'pchip');
    blueNumber=0:255;
    blueInterpolated=interp1(blueLUT,blueLum,blueNumber,'pchip');
    
    redGun.N = Nred;
    redGun.data = redData;
    redGun.dcOffset = dcOffset;
    redGun.bkgrndOffset = bkgrndOffset;
    redGun.Luminance = redLum;
    redGun.lut = redLUT;
    redGun.number = redNumber;
    redGun.lumInterpolated = redInterpolated;
    
    greenGun.N = Ngreen;
    greenGun.data = greenData;
    greenGun.dcOffset = dcOffset;
    greenGun.bkgrndOffset = bkgrndOffset;
    greenGun.Luminance = greenLum;
    greenGun.lut = greenLUT;
    greenGun.number = greenNumber;
    greenGun.lumInterpolated = greenInterpolated;
    
    blueGun.N = Nblue;
    blueGun.data = blueData;
    blueGun.dcOffset = dcOffset;
    blueGun.bkgrndOffset = bkgrndOffset;
    blueGun.Luminance = blueLum;
    blueGun.lut = blueLUT;
    blueGun.number = blueNumber;
    blueGun.lumInterpolated = blueInterpolated;

%     for curRGB=1:length(rgbIndex)
%         Screen('FillRect',w,rgbBackground,destRect);
%         vbl=Screen('Flip', w,1);
%         WaitSecs(1);
%         curRGBnumber=rgbIndex(curRGB);
%         v = rgbIndex(curRGB);
%         rgb = [v v v] .* rgbMask;
%         [qual,L,U,V] = getMeasurement(w,rgbBackground,rgb,destRect,reps);
%         L = L - DCOFFSET;
%         calData(curRGB,:)=[rgb(1),rgb(2),rgb(3),qual,L,U,V,curRGBnumber];
% 		fprintf('RGB = [%3i,%3i,%3i]; luminance = %6.2f; rgbIndex = %g\n',rgb(1),rgb(2),rgb(3),L,curRGBnumber);
%         WaitSecs(0.1);
% 
%         if KbCheck
%             break;
%         end;
% 
% 	end;
	

	% ---------- Window Cleanup ---------- 

	 
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
    calRec.backgroundBITS = bkgrndRGBnumber;
    calRec.caldata=calData;
    calRec.lmaxminave=pbBitStealing2Lum([pbMaxBITStealingIndex,1,bkgrndRGBnumber],pbExtractLuminanceValues(calRec,0),pbExtractNumbers(calRec,0));
    fprintf('(calibration)$ saving data in curCalRecTmpFile.mat\n');
    save 'curCalRecTmpFile' calRec;
    if dpf
        fprintf('(calibration)$ fitting pelli functions to data...\n');
        calibrationRecord=pbFitBitStealingData(calRec);
    else
        calibrationRecord=calRec;
    end;
    fprintf('(calibration)$ saving calibrationRecord in curCalRecord.mat\n');
    save 'curCalRecord' calibrationRecord;
    fprintf('(calibration)$ information about screen size may be incorrect... PLEASE CHECK!\n');

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
    function [qual,L,U,V] = getMeasurement(w,bkgrndRGB,rgb,destRect,reps)
        Priority(MaxPriority(w));
        Screen('FillRect',w,bkgrndRGB);
        Screen('FillOval',w,rgb,destRect);
        vbl=Screen('Flip', w,1);
        WaitSecs(0.2);
        Lm=zeros(reps,1);
        Um=zeros(reps,1);
        Vm=zeros(reps,1);
        qualm=zeros(reps,1);
        for kk=1:reps
            WaitSecs(0.2);
            [qualm(kk),Lm(kk),Um(kk),Vm(kk)]=pb650Measure;
            if KbCheck
                break;
            end;
        end;
        qual=min(qualm);
        L=mean(Lm);
        U=mean(Um);
        V=mean(Vm);
        finalprio = Priority(0);
    end

    function calFitRecord=pbFitBitStealingData(calRecord)

        caldata=calRecord.caldata;
        if (size(caldata,1)<2)
            calFitRecord=calRecord;
            calFitRecord.ABKG=NaN;
            calFitRecord.calmatrix=NaN;
            warning('Insufficient points to fit pelli function');
        else
            
            bitsNumbers = caldata(:,8);
            lumValues = caldata(:,5);
            % initial parameters
            alpha = min(min(caldata(:,5)));
            beta = .01;
            kappa = .01;
            gamma = 2;
            initcoeffs = [alpha beta kappa gamma];

            % fits
            coeffs = pbPelliFit(bitsNumbers,lumValues,initcoeffs);

            bn = 1:pbMaxBITStealingIndex;
            bn = bn';
            rgb = pbBitStealing2RGB(bn);
            L = pbPelliPower(coeffs,bn);

            % final calibration plot
            plot(bn,L,'k-');
            ylabel('Luminance (cd/m^2)');
            xlabel('Index');
            title('Look-Up Table');		

            drawnow;


            calFitRecord=calRecord;
            calFitRecord.ABKG=coeffs;
            calFitRecord.calmatrix=[rgb,L,bn];
        end;


    end


end
