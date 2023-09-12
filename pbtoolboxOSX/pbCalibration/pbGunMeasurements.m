function [N,Lum,abortFlag]=pbGunMeasurements(activeGun,stimpix,portNumber,rgbBackground,whichScreen,reps,rgbIndex)
%
% [N,Lum,abortFlag]=pbGunMeasurements(activeGun,stimpix,portNumber,rgbBackground,whichScreen,reps,rgbIndex)
%


% Prevents MATLAB from reprinting the source code when the program runs.
echo off


% For an explanation of the try-catch block, see the section "Error Handling"
% at the end of this document.
try
    oldEnableFlag = Screen('Preference', 'SuppressAllWarnings', 1);
    abortFlag=0;
    activeGun = lower(activeGun);
    switch activeGun
        case 'red'
            rgbMask = [1 0 0];
        case 'green'
            rgbMask = [0 1 0];
        case 'blue'
            rgbMask = [0 0 1];
        otherwise
            error('activeGun must be red, green or blue');
    end;

    fprintf('initializing photometer...\n');
    retval = pb650init(portNumber);

    
    
    
	    
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
%     fprintf('>>> display frame rate (Hz) = %g\n',hz);
    pixelSize=Screen('PixelSize', whichScreen);
%     fprintf('>>> pixel size = %g\n',pixelSize);
    [widthmm, heightmm]=Screen('DisplaySize', whichScreen);
    widthcm=widthmm/10;
    heightcm=heightmm/10;
%     fprintf('>>> display size (cm)[width, height] = [%g,%g]\n >>> N.B. These numbers may be inaccurate; PLEASE CHECK!!\n',widthcm,heightcm);
    [widthPixels, heightPixels]=Screen('WindowSize', whichScreen);
%     fprintf('>>> display size (pixels)[width, height] = [%g,%g]\n',widthPixels,heightPixels);
    
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

%     fprintf('\n\n>>> center photometer on stimulus area and hit a key to continue...\n');
%     while(KbCheck==0)
% 	end;
    fprintf('taking measurements...\n');
    fprintf('HOLD DOWN ANY KEY TO ABORT...\n\n');
	
	waitframes = 2;
    
    
 	if(exist('rgbIndex','var')==0)
        rgbIndex = [[0:10:250],255];
    end;
    randOrder = randperm(length(rgbIndex));
	calData=zeros(1,8);
    N=zeros(1,1);
    Lum=N;


    for curRGB=1:length(rgbIndex)
        Screen('FillRect',w,rgbBackground,destRect);
        vbl=Screen('Flip', w,1);
        WaitSecs(1.5);
        ktmp=randOrder(curRGB);
        curRGBnumber=rgbIndex(ktmp);
        v = rgbIndex(ktmp);
        rgb = [v v v] .* rgbMask;
        [qual,L,U,V] = getMeasurement(w,rgbBackground,rgb,destRect,reps);
        calData(ktmp,:)=[rgb(1),rgb(2),rgb(3),qual,L,U,V,curRGBnumber];
        N(ktmp)=curRGBnumber;
        Lum(ktmp)=L;
		fprintf('RGB = [%3i,%3i,%3i]; luminance = %6.2f; rgbIndex = %g\n',rgb(1),rgb(2),rgb(3),L,curRGBnumber);
        WaitSecs(0.1);

        if KbCheck
            abortFlag=1;
            break;
        end;

	end;
	

		pb650close;

	% ---------- Window Cleanup ---------- 

	% Closes all windows.
	Screen('CloseAll');
    Screen('Preference','SuppressAllWarnings',oldEnableFlag);   
	% Restores the mouse cursor.
	ShowCursor;
	
	

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
