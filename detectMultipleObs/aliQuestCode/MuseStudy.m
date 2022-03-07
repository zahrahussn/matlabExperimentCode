function MuseStudy(study, eegConnect, DEBUG, LCD_FLAG)
% MuseStudy(study, eegConnect, debug, lcd_flag)
% 
% 'study' can be 1 (EnVision) or 2 (iMeditate). No Default value... this is
% a required input.
% 'eegConnect' can be 0 (no Muse) or 1 (requires active muse LSL stream).
% Default=1
% 'debug' can be 0 (off) or 1 (on). When on, will draw window inside screen
% (but only if screenr esoltuion is higher than experiment CRT resolution).
% Default=0.
% 'lcd_flag' can be 0 (no LCD), 1 (1 LCD), or 2 (2 LCD) screens. Here for
% debugging purposes to work with the debug argument when drawing windows.
% Default=0

% in case it wasnt closed before, this'll prevent crashing
PsychPortAudio('Close');

% enable low latency audio timing
InitializePsychSound(1)

switch nargin
    case 0
        fprintf('\nMISSING STUDY NUMBER\n');
        return
    case 1
        eegConnect = 1;
        DEBUG = 0;
        LCD_FLAG = 0;
    case 2
        DEBUG = 0;
        LCD_FLAG = 0;
    case 3
        LCD_FLAG = 0;
    otherwise
        % all good
end

sessinfo.eegConnect = eegConnect; % 1 = muse, 2 = biosemi, 3 = both
sessinfo.testing = 0; % what is this... i think it goes unused...

musefilepath = mfilename('fullpath');
musefolder = musefilepath(1:(end-(length(mfilename))));

cd(musefolder);

% add pbtoolbox and muse-lsl-to path to read calibration data
%addpath(genpath('/Users/alihashemi/Documents/MATLAB/toolboxes/pbtoolboxOSX'));
if sessinfo.eegConnect == 1
    %addpath('/Users/alihashemi/Documents/MATLAB/MuseLSL/Muse_LSL_Stuff')
    %addpath(genpath('/Users/alihashemi/Documents/MATLAB/MuseLSL/labstreaminglayer/LSL/liblsl-matlab/'))
    %addpath('/Users/alihashemi/Documents/MATLAB/MuseLSL/labstreaminglayer/LSL/liblsl-matlab')
    
    %addpath('/Users/alihashemi/Documents/MATLAB/MuseLSL/Muse_LSL_Stuff')
    addpath(genpath('../../../installations/labstreaminglayer/LSL/liblsl-Matlab/'))
    addpath('../../../installations/labstreaminglayer/')
end

% add questplus and dxjones folders to path
% addpath(genpath('../toolboxes/pbtoolboxOSX/'));
% addpath('../toolboxes/dxjones');
% addpath(genpath('../toolboxes/mQUESTPlus/'));
% addpath('ContourStuff/ContextPath')

alldone = 0;
firstTime = 1;

while ~alldone
    
    switch study
        case 1 % study 1
            fprintf(['\n****************\nTask legend for Study 1:\n',...
                '0 = view Muse data on this screen\n',...
                '1 = Resting state EEG [Rest1] - 60 CM\n',...
                '2 = Attentional Field of View [AFOV] - 60 CM\n',...
                '3 = Multisensory Evoked Potential [MSEP1] - 114 CM\n',...
                '4 = Sound-flash illusion [SIFI] - 114 CM\n',...
                '5 = Center Surround [CnSr] - 114 CM\n',...
                '6 = Contour Integration [CnIg] - 114 CM\n',...
                '7 = Global Motion [GlMn] - 114 CM\n',...
                '8 = Biological Motion [BiMn] - 114 CM\n',...
                '9 = Face Identification [Face] - 114 CM\n',...
                '10 = Resting state EEG [Rest2] - 114 CM\n',...
                '11 = Multisensory Evoked Potential [MSEP2] - 114 CM\n',...
                'x = Muse problems. Restart Muse Connection\n',...
                'Press Cancel to exit\n****************\n']);
        case 2 % study 2
            fprintf(['\n****************\nTask legend for Study 2:\n',...
                '0 = view Muse data on this screen\n',...
                '1 = Resting state EEG [Rest1]\n',...
                '2 = Auditory Oddball [AOdd]\n',...
                '3 = Attentional Field of View [AFOV] - 60 CM\n',...
                '4 = Face Memorization [FVWM] - 114 CM\n',...
                '5 = Breath Counting [Brth]\n',...
                '6 = Resting state EEG [Rest2]\n',...
                'x = Muse problems. Restart Muse Connection\n',...
                'Press Cancel to exit\n****************\n']);
            
        otherwise % show everything
            fprintf(['\n****************\nTask legend for ALL TASKS:\n',...
                '0 = view Muse data on this screen\n',...
                '1 = Resting state EEG [Rest1] - 60 CM\n',...
                '2 = Attentional Field of View [AFOV] - 60 CM\n',...
                '3 = Multisensory Evoked Potential [MSEP1] - 114 CM\n',...
                '4 = Sound-flash illusion [SIFI] - 114 CM\n',...
                '5 = Center Surround [CnSr] - 114 CM\n',...
                '6 = Contour Integration [CnIg] - 114 CM\n',...
                '7 = Global Motion [GlMn] - 114 CM\n',...
                '8 = Biological Motion [BiMn] - 114 CM\n',...
                '9 = Face Identification [Face] - 114 CM\n',...
                '10 = Resting state EEG [Rest2] - 114 CM\n',...
                '11 = Multisensory Evoked Potential [MSEP2] - 114 CM\n',...
                '12 = Face Memorization [FVWM]\n',...
                '13 = Auditory Oddball [AOdd]\n',...
                '14 = Breath Counting [Brth]\n',...
                'x = Muse problems. Restart Muse Connection\n',...
                'Press Cancel to exit\n****************\n']);
    end
    
%     try load 'lastsession.mat'
%     catch
%         sessinput = [];
%     end

    if firstTime
        sessinput = [];
    end
    
    %if isempty(dir('lastsession.mat')) || (isempty(dir('lastsession.mat'))==0 && isempty(sessinput))
    if isempty(sessinput)
        tmpinput.subjID = 'Participant ID (####)';
        tmpinput.sessID = 'Session #';
        tmpinput.task = 'Task # (see legend)';
        tmpinput.museID = 'Muse ID (A/B/C/D/E/F)';
        tmpinput.room = 'Room (1006/1008/APX/other)';
    else
        %load 'lastsession.mat';
        tmpinput.subjID = sessinput{1};
        tmpinput.sessID = sessinput{2};
        tmpinput.task = sessinput{3};
        tmpinput.museID = sessinput{4};
        tmpinput.room = sessinput{5};
    end
    
    sessinput = inputdlg({'Participant ID: ',...
        'Session #: ',...
        'Task #: ',...
        'Muse ID: ',...
        'Room #: '},'IA Study',1,{tmpinput.subjID, ...
        tmpinput.sessID, ...
        tmpinput.task, ...
        tmpinput.museID,...
        tmpinput.room});
        
    firstTime = 0;
    
    if isempty(sessinput)
        
        alldone = 1;
        return % if subject hits cancel, exit whole thing and don't try to run
        
    else % otherwise save sessinput and run!
        
        %save('lastsession.mat','sessinput'); % save for next session
        
        sessinfo.datetime = datestr(now,'yyyy-mm-dd_HHMMSS');
        sessinfo.thedate = datestr(now,'yyyymmdd');
        
        sessinfo.subjID = sessinput{1};
        sessinfo.sessID = sessinput{2};
        sessinfo.task = sessinput{3};
        sessinfo.museID = sessinput{4};
        sessinfo.room = sessinput{5};
        
        sessinfo.exptPath = musefolder;
        %sessinfo.dataPath = ['../../IAData/RawBeh/',sessinfo.thedate,'_',sessinfo.subjID,'/'];
        sessinfo.dataPath = [sessinfo.exptPath,'behdata/',sessinfo.thedate,'_',sessinfo.subjID,'/'];
        mkdir(sessinfo.dataPath);
    end
    
    switch study
        
        case 1 % study 1
            
            switch sessinfo.task
                case '0'
                    sessinfo.taskName = 'viewmuse';
                case '1'
                    sessinfo.taskName = 'Rest1';
                case '2'
                    sessinfo.taskName = 'AFOV';
                case '3'
                    sessinfo.taskName = 'MSEP1';
                case '4'
                    sessinfo.taskName = 'SIFI';
                case '5'
                    sessinfo.taskName = 'CnSr';
                case '6'
                    sessinfo.taskName = 'CnIg';
                case '7'
                    sessinfo.taskName = 'GlMn';
                case '8'
                    sessinfo.taskName = 'BiMn';
                case '9'
                    sessinfo.taskName = 'Face';
                case '10'
                    sessinfo.taskName = 'Rest2';
                case '11'
                    sessinfo.taskName = 'MSEP2';
                case {'x', 'X'}
                    restartmuse; % runs this function
                    sessinfo.taskName = 'none';
                    return
                otherwise
                    sessinfo.taskName = 'none';
                    fprintf('\nno task selected...\n')
                    return
            end
            
        case 2 % study 2
            
            switch sessinfo.task
                case '0'
                    sessinfo.taskName = 'viewmuse';
                case '1'
                    sessinfo.taskName = 'Rest1';
                case '2'
                    sessinfo.taskName = 'AOdd';
                case '3'
                    sessinfo.taskName = 'AFOV';
                case '4'
                    sessinfo.taskName = 'FVWM';
                case '5'
                    
                    vernierID = '0K200167';
                    
                    fprintf(['\n1. Ensure Respiration belt is properly worn and connected via USB to this computer',...
                        '\n2. Open Terminal and paste the following line of code:',...
                        '\n\tsudo python ''/home/sekulerlab/app-vernier/verniersl'' --serial_number ', vernierID,... %--order_code GDX-RB\n',...
                        '\n3. If terminal is streaming, then you may proceed.\n\n']);
                    
                    gotvernier = 0;
                    while ~gotvernier
                        resp = input('Press ''y'' to proceed or ''x'' to abort:  ','s');
                        switch resp
                            case 'y'
                                sessinfo.taskName = 'Brth';
                                gotvernier = 1;
                            case 'x'
                                gotvernier = 1;
                                sessinfo.taskName = 'none';
                            otherwise
                                sessinfo.taskName = 'none';
                                gotvernier = 0;
                        end
                    end

                case '6'
                    sessinfo.taskName = 'Rest2';
                case {'x', 'X'}
                    restartmuse; % runs this function
                    sessinfo.taskName = 'none';
                    return
                otherwise
                    sessinfo.taskName = 'none';
                    fprintf('\nno task selected...\n')
                    return
            end
            
        otherwise
            
            switch sessinfo.task
                case '0'
                    sessinfo.taskName = 'viewmuse';
                case '1'
                    sessinfo.taskName = 'Rest1';
                case '10'
                    sessinfo.taskName = 'Rest2';
                case '3'
                    sessinfo.taskName = 'MSEP1';
                case '11'
                    sessinfo.taskName = 'MSEP2';
                case '4'
                    sessinfo.taskName = 'SIFI';
                case '5'
                    sessinfo.taskName = 'CnSr';
                case '6'
                    sessinfo.taskName = 'CnIg';
                case '7'
                    sessinfo.taskName = 'GlMn';
                case '8'
                    sessinfo.taskName = 'BiMn';
                case '9'
                    sessinfo.taskName = 'Face';
                case '2'
                    sessinfo.taskName = 'AFOV';
                case '12'
                    sessinfo.taskName = 'FVWM';
                case '13'
                    sessinfo.taskName = 'AOdd';
                case '14'
                    sessinfo.taskName = 'Brth';
                case {'x', 'X'}
                    restartmuse; % runs this function
                    sessinfo.taskName = 'none';
                    return
                otherwise
                    sessinfo.taskName = 'none';
                    fprintf('\nno task selected...\n')
                    return
            end
    end
    
    
    % sample filename: tRest_s01_65f_2019-01-14_132053.mat
    sessinfo.filename = [sessinfo.taskName, '_',sessinfo.subjID,'_', sessinfo.datetime];
    fprintf('data will be stored in file %s\n',sessinfo.filename);
    
    %%% setting up eeg
    muselsl = [];
    if sessinfo.eegConnect==1
        
        switch sessinfo.museID
            case 'A'
                museMacID = '00:55:DA:B3:C9:21';
            case 'B'
                museMacID = '00:55:DA:B3:CB:BB';
            case 'C'
                museMacID = '00:55:DA:B0:C5:61';
            case 'D'
                museMacID = '00:55:DA:B3:CB:AC';
            case 'E'
                museMacID = '00:55:DA:B3:9D:AE';
            case 'ALI'
                museMacID = '00:55:DA:B3:CB:AD';
                %museMacID = '00:55:DA:B0:C5:6A';
            otherwise
                fprintf('\n *** MUSE ID NOT VALID *** \n');
        end
        
        % load lsl library
        muselsl.lib = lsl_loadlib();
        muselsl.info = lsl_streaminfo(muselsl.lib,['room',sessinfo.room],'Markers',1,0,'cf_string',['markers',museMacID]);
        %muselsl.info = lsl_streaminfo(muselsl.lib,'Markers','Markers',3,0,'cf_string',['markers',museMacID]);
        muselsl.outlet = lsl_outlet(muselsl.info);
        
        disp('Resolving an EEG stream...');
        muselsl.result = {};
        while isempty(muselsl.result)
            muselsl.result = lsl_resolve_byprop(muselsl.lib,'source_id',['Muse',museMacID]);
            %muselsl.result = lsl_resolve_byprop(muselsl.lib,'type','EEG');
        end
        
        if strcmp(sessinfo.taskName,'Brth')
            disp('Resolving a Go Direct stream...');
            muselsl.result_vernier = {};
            while isempty(muselsl.result_vernier)
                muselsl.result_vernier = lsl_resolve_byprop(muselsl.lib,'source_id',vernierID);
            end
        end
        
        
        % create a new inlet
        disp('Opening an inlet...');
        muselsl.inlet = lsl_inlet(muselsl.result{1}); % create inlet for getting proper timestamps
        %lsl_record_go = 1;
        muselsl.outlet.push_sample({'start'}, GetSecs);
        %WaitSecs(1)
        %outlet.push_sample({'SUBJINFO'},0);
        %muselsl.outlet.push_sample({['task',sessinfo.task,'_',sessinfo.subjID,'_age',sessinfo.age,'_gender',sessinfo.gender,'_sess',sessinfo.sessID]},GetSecs);
        
    end
    
    switch sessinfo.taskName
        case 'viewmuse'
            
        otherwise
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % set-up and open psychtoolbox screen %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            fprintf('setting up psychtoolbox screen \n');

            % fixes some Java issues
            PsychJavaTrouble;

            AssertOpenGL; % make sure we are using OpenGL

            % Disable psychtoolbox test screen
            %oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
            %oldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1);

            % reset random number generators
            [InitialRandSeed,WhichRandGenerator] = ClockRandSeed();
            exptdesign.randSeed = InitialRandSeed;
            exptdesign.randGen = WhichRandGenerator;

            % get calibration information
            switch sessinfo.room
                case '1006'
                    scrinfo.calfile ='sekulerA_1280x1024x85_2019-04-08.mat';
                case '1008'
                    scrinfo.calfile ='sekulerB_1280x1024x85_2019-04-22.mat';
                otherwise % just take 1006 otherwise for filler...
                    scrinfo.calfile ='sekulerA_1280x1024x85_2019-04-08.mat';
            end
            fprintf('reading calibration file and setting up screen...\n');
            calfitrec=pbReadCalibrationFile(scrinfo.calfile);
            scrinfo.rgbMat = calfitrec.caldata(:,1:3); % rgb matrix
            scrinfo.B = calfitrec.caldata(:,4); % array of bit-stealing numbers
            scrinfo.L = calfitrec.caldata(:,5); % array of luminance values
            scrinfo.number=max(Screen('Screens'));
            scrinfo.width=calfitrec.displaypixels(1);
            scrinfo.height=calfitrec.displaypixels(2);
            scrinfo.framerate=calfitrec.framerate;
            scrinfo.pixelsize=calfitrec.pixelsize;
            scrinfo.pixpercm=mean(calfitrec.displaypixels ./ calfitrec.displaycm);
            scrinfo.dcNumber = calfitrec.backgroundNumber;
            scrinfo.RGBgrey=pbBSindex2RGB(scrinfo.dcNumber);
            scrinfo.avgLum = pbBitStealing2Lum(scrinfo.dcNumber,scrinfo.L,scrinfo.B);
            scrinfo.useBitStealing = 1;
            if LCD_FLAG>0
                scrinfo.width = 1920*LCD_FLAG; % if dual screen, acknowledges both
                scrinfo.height = 1080;
                scrinfo.framerate = 60;
                scrinfo.pixpercm = mean([scrinfo.width scrinfo.height] ./ [52*LCD_FLAG 29]);
            end
           % oldResolution = Screen('Resolution', scrinfo.number, scrinfo.width, scrinfo.height, scrinfo.framerate);

            avgLumBS=pbLum2BS(scrinfo.avgLum ,scrinfo.L,scrinfo.B);            % convert Luminance to BitStealing Numbers:
            avgLumRGB = pbBitStealing2RGB(avgLumBS,scrinfo.rgbMat,0);

            % actually open new screen
            mainScreen=scrinfo.number;

            switch sessinfo.taskName
                case 'AFOV'
                    scrinfo.viewingdistcm = 60; % in centimetres
                otherwise
                    scrinfo.viewingdistcm = 114; %60; % in centimetres
            end
            % is 60 for AFOV only, 114 for everything else

            scrinfo.degperpixel=(atan2(1,scrinfo.viewingdistcm)*180/pi)/scrinfo.pixpercm;
            scrinfo.degpercm = atand(1/scrinfo.viewingdistcm);
            scrinfo.pixperdeg = scrinfo.pixpercm/scrinfo.degpercm;

            % Open a double buffered fullscreen window and draw a gray background
            scrinfo.numBuffers=2;
            %[window,wrect]=Screen('OpenWindow',scrinfo.number, 0,[],scrinfo.pixelsize,scrinfo.numBuffers);
            if DEBUG
                [scrinfo.w,scrinfo.wrect]=Screen('OpenWindow',scrinfo.number, scrinfo.RGBgrey,round([0 0 1280 1024]), scrinfo.pixelsize, scrinfo.numBuffers);
            else
                [scrinfo.w,scrinfo.wrect]=Screen('OpenWindow',scrinfo.number, scrinfo.RGBgrey,[], scrinfo.pixelsize, scrinfo.numBuffers);
            end


            % define white and black
            scrinfo.white       = WhiteIndex(scrinfo.w);
            scrinfo.black       = BlackIndex(scrinfo.w);
            scrinfo.grey = avgLumRGB(:)';
            %scrinfo.grey        = round((scrinfo.white + scrinfo.black)/2); %scrinfo.RGBgrey;scrinfo.RGBgrey; %

            scrinfo.ifi         = Screen('GetFlipInterval', scrinfo.w);

            scrinfo.w=scrinfo.w; % for compatibility with some of PJB's code
            Screen('FillRect',scrinfo.w, scrinfo.grey);
            Screen('Flip', scrinfo.w);

            %define window parameters
            scrinfo.width = scrinfo.wrect(RectRight) - scrinfo.wrect(RectLeft);
            scrinfo.height = scrinfo.wrect(RectBottom) - scrinfo.wrect(RectTop);
            scrinfo.center = round([scrinfo.wrect(3) scrinfo.wrect(4)]/2);	% coordinates of screen center (pixels)
            scrinfo.fps=Screen('FrameRate',scrinfo.w); % frames per second
            if(scrinfo.fps==0)
                scrinfo.fps=60;
                fprintf('WARNING: using default frame rate of %i Hz\n',scrinfo.fps);
            end

            % set text properties for our screen
            exptdesign.aes.txtsize = 35;
            exptdesign.aes.txtfont = 'Helvetica';
            exptdesign.aes.txtwrapsize = 60;
            exptdesign.aes.txtspacing = 1.2; % vertical spacing argument to be used in DrawFormattedText arg #9
            exptdesign.aes.align = 'centerblock'; % used as the 'sx' argument for left aligning text/instructions
            %exptdesign.aes.txtbox = ( scrinfo.wrect / 2 ) + scrinfo.wrect([3,4,3,4])/4; % creates virtual box half of screen width centered on screen.
            Screen('TextFont',scrinfo.w, exptdesign.aes.txtfont);
            Screen('TextSize',scrinfo.w, exptdesign.aes.txtsize);
            Screen('TextStyle', scrinfo.w, 0);


            % Enable alpha blending with proper blend-function. We need it
            % for drawing of smoothed points:
            Screen('BlendFunction', scrinfo.w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

            MaxPriority(scrinfo.w);


            HideCursor; % hide the cursor; will restore at end of expt
            ListenChar(2); % suppress command window input; will restore at end

            % set-up all keys that will be used
            KbName('UnifyKeyNames')
            exptdesign.rspkeys.escape = KbName('escape'); % abort key
            exptdesign.rspkeys.space = KbName('5%'); %KbName('space'); % proceed key
            exptdesign.rspkeys.left = KbName('3#');
            exptdesign.rspkeys.midleft = KbName('4$');
            exptdesign.rspkeys.midright = KbName('5%');
            exptdesign.rspkeys.right = KbName('6^');
            exptdesign.rspkeys.topleft = KbName('1!');
            exptdesign.rspkeys.topright = KbName('2@');
            
            exptdesign.rspkeys.morePracticeKey = KbName('p');
            exptdesign.rspkeys.donePracticeKey = KbName('e');
            

            % set-up fixation point params
            exptdesign.fixation.shape = '+'; % ?
            exptdesign.fixation.colour1 = scrinfo.black;
            exptdesign.fixation.colour2 = scrinfo.white;
            exptdesign.fixation.xloc = 'center';%scrinfo.center(1);
            exptdesign.fixation.yloc = 'center';%scrinfo.center(2);
            exptdesign.fixation.size = 10; % does not apply if using text + as fixation
            exptdesign.fixation.numflick = 3;

            % NEW FIXATION based on Thaler et al.
            [fiximageB, map, alpha] = imread('FixationBlack.png');
            fiximageB(:,:,4) = alpha;
            [fiximageW, map, alpha] = imread('FixationWhite.png');
            fiximageW(:,:,4) = alpha;
            exptdesign.fixationBlack = Screen('MakeTexture', scrinfo.w, fiximageB);
            exptdesign.fixationWhite = Screen('MakeTexture', scrinfo.w, fiximageW);

            exptdesign.trialStartMode = 'noflicker'; % 'flicker'

            %% make and play sounds to check volume.

            % this needs to change based on computer
            devices = PsychPortAudio('GetDevices');
            exptdesign.audio.device = 0;
            % 1 for SEK-EWS1 LCD monitor...
            % 2 for twinspot laptop monitor (when connected to dock)
            exptdesign.audio.nchannels = devices(exptdesign.audio.device+1).NrOutputChannels; % 2
            exptdesign.audio.samplerate = devices(exptdesign.audio.device+1).DefaultSampleRate; % 44100
            exptdesign.audio.stimVolume = 0.1; %1;
            exptdesign.audio.fdbkCorHz = 700;
            exptdesign.audio.fdbkIncHz = 300;
            exptdesign.audio.fdbkDur = 0.1;
            exptdesign.audio.fdbkVolume = 0.03;


            pahandle = PsychPortAudio('Open', exptdesign.audio.device, 1, 1, exptdesign.audio.samplerate, exptdesign.audio.nchannels); % open 1 channel
            % set feedback volume consistent from all trials
            oldVolume = PsychPortAudio('Volume',pahandle,exptdesign.audio.fdbkVolume);
            corrsnd = MakeBeep(exptdesign.audio.fdbkCorHz, exptdesign.audio.fdbkDur, exptdesign.audio.samplerate);
            wrongsnd = MakeBeep(exptdesign.audio.fdbkIncHz, exptdesign.audio.fdbkDur, exptdesign.audio.samplerate);

            if exptdesign.audio.nchannels==2
                corrsnd = [corrsnd; corrsnd];
                wrongsnd = [wrongsnd; wrongsnd];
            end

            Astim.freq = 3000; %Hz.  3.5 khz freq tone
            Astim.dur  = 0.016; %s.
            Astim.amp  = 1; %.  % ADJUST THIS TO CHANGE VOLUME OF BEEP IF IT"S TOO LOUD
            Astim.fs   = exptdesign.audio.samplerate ; %Hz.  sampling rate.\
            Astim.rampDur   = 0.004; % 5 ms for fall/rise ramp

            %tmpAmp = ones(1,ceil(Astim.fs * (Astim.dur-(Astim.rampDur*2)))) * Astim.amp;
            %tmpRamp = linspace(0,Astim.amp, Astim.fs*Astim.rampDur);
            %tmpAmp = [tmpRamp, tmpAmp, fliplr(tmpRamp), 0]; % add this 0 because MakeBeep has an extra sample for some reason...
            Astim.beep = MakeBeep(Astim.freq, Astim.dur, Astim.fs);
            ampVector = Astim.amp.*ones(1,length(Astim.beep));

            ampRampUp = linspace(0, Astim.amp, length(0:Astim.rampDur*Astim.fs));
            ampRampDown = linspace(Astim.amp,0, length(0:Astim.rampDur*Astim.fs));
            ampVector(1:length(ampRampUp)) = ampRampUp;
            ampVector((end-length(ampRampDown)+1):end) = ampRampDown;
            Astim.beep = ampVector.*Astim.beep;

            % Astim params are taken from SIFI expt
            Astim.freqs     = [500 2000]; % just testing this...
            Astim.dur       = 0.1; % Claude does 100 ms for all stimuli, with 5ms fall/rise time
            Astim.amp       = [0.7 1];
            Astim.fs        = exptdesign.audio.samplerate;
            Astim.rampDur   = 0.005; % 5 ms for fall/rise ramp

            tmpAmp = ones(1,ceil(Astim.fs * (Astim.dur-(Astim.rampDur*2)))) * Astim.amp(1);
            tmpRamp = linspace(0,Astim.amp(1), Astim.fs*Astim.rampDur);
            tmpAmp = [tmpRamp, tmpAmp, fliplr(tmpRamp)];%, 0]; % add this 0 because MakeBeep has an extra sample for some reason...

            Astim.beepLow   = tmpAmp .* MakeBeep(Astim.freqs(1), Astim.dur, Astim.fs);
            tmpAmp = ones(1,ceil(Astim.fs * (Astim.dur-(Astim.rampDur*2)))) * Astim.amp(2);
            tmpRamp = linspace(0,Astim.amp(2), Astim.fs*Astim.rampDur);
            tmpAmp = [tmpRamp, tmpAmp, fliplr(tmpRamp)];%, 0]; % add this 0 because MakeBeep has an extra sample for some reason...

            Astim.beepHigh  = tmpAmp .* MakeBeep(Astim.freqs(2), Astim.dur, Astim.fs);


            %         if alldone < 1 && DEBUG == 1
            %
            %             tmp = GetSecs;
            %             oldVolume = PsychPortAudio('Volume',pahandle,exptdesign.audio.fdbkVolume);
            %
            %             PsychPortAudio('FillBuffer', pahandle, wrongsnd);
            %             PsychPortAudio('Start', pahandle, 1, tmp+1);
            %
            %             PsychPortAudio('FillBuffer', pahandle, corrsnd);
            %             PsychPortAudio('Start', pahandle,1,tmp+2);
            %
            %             WaitSecs(1);
            %             tmp = GetSecs;
            %             oldVolume = PsychPortAudio('Volume',pahandle,exptdesign.audio.stimVolume);
            %
            %             PsychPortAudio('FillBuffer', pahandle, [Astim.beep; Astim.beep]);
            %             PsychPortAudio('Start', pahandle,1,tmp+1);
            %
            %
            %             PsychPortAudio('FillBuffer', pahandle, [Astim.beepLow; Astim.beepLow]);
            %             PsychPortAudio('Start', pahandle,1,tmp+2);
            %
            %             PsychPortAudio('FillBuffer', pahandle, [Astim.beepHigh; Astim.beepHigh]);
            %             PsychPortAudio('Start', pahandle,1,tmp+3);
            %
            %             WaitSecs(3)
            %
            %         end
            PsychPortAudio('Close');

            %%
            % clear instructions for next round so doesn't interfere
            if isfield(exptdesign,'instructions')
                exptdesign = rmfield(exptdesign,'instructions');
            end


            if sessinfo.eegConnect==1
                muselsl.outlet.push_sample({['name',sessinfo.filename]}, GetSecs);
            end
        
    end % viewmuse switch
    
    if strcmp(sessinfo.taskName,'viewmuse')
        
        cmd = sprintf('muselsl view -a=%s', museMacID);
        system(cmd)
        
    elseif startsWith(sessinfo.taskName, 'Rest') % resting EEG
        
        restingMuse(sessinfo, scrinfo, muselsl, exptdesign);
        
        
    elseif startsWith(sessinfo.taskName, 'MSEP') % MSEP
        
        MSEPMuseFoveal(sessinfo, scrinfo, muselsl, exptdesign);
        
    elseif strcmp(sessinfo.taskName, 'SIFI') % soundFlash illusion
        
        
        %sessinfo.datetime = datestr(now,'yyyy-mm-dd_HHMMSS');
        %sessinfo.filename = [sessinfo.taskName, 'V_',sessinfo.subjID,'_', sessinfo.datetime];
        %SIFIMuse(sessinfo, scrinfo, muselsl, exptdesign, 'visual');
        
        sessinfo.datetime = datestr(now,'yyyy-mm-dd_HHMMSS');
        sessinfo.filename = [sessinfo.taskName, 'M_',sessinfo.subjID,'_', sessinfo.datetime];
        SIFIMuse(sessinfo, scrinfo, muselsl, exptdesign, 'multisensory');
        
        sessinfo.datetime = datestr(now,'yyyy-mm-dd_HHMMSS');
        sessinfo.filename = [sessinfo.taskName, 'A_',sessinfo.subjID,'_', sessinfo.datetime];
        SIFIMuse(sessinfo, scrinfo, muselsl, exptdesign, 'auditory');
        
    elseif strcmp(sessinfo.taskName, 'CnSr') % center-surround
        
        CenSurrMuse(sessinfo, scrinfo, muselsl, exptdesign);
        
    elseif strcmp(sessinfo.taskName, 'CnIg') % contour integration
        ContoursFovealMuse(sessinfo, scrinfo, muselsl, exptdesign);
        %             Contours2AFCMuse(sessinfo, scrinfo, muselsl, exptdesign);
        
    elseif strcmp(sessinfo.taskName, 'GlMn') % global, radial motion
        
        MotionCoherenceMuse(sessinfo, scrinfo, muselsl, exptdesign);
        
    elseif strcmp(sessinfo.taskName, 'BiMn') % biomotion
        
        sessinfo.datetime = datestr(now,'yyyy-mm-dd_HHMMSS');
        sessinfo.filename = [sessinfo.taskName, 'DIR_',sessinfo.subjID,'_', sessinfo.datetime];
        BioMotionMuseCentral(sessinfo, scrinfo, muselsl, exptdesign, 'direction');
        
        sessinfo.datetime = datestr(now,'yyyy-mm-dd_HHMMSS');
        sessinfo.filename = [sessinfo.taskName, 'EMO_',sessinfo.subjID,'_', sessinfo.datetime];
        BioMotionMuseCentral(sessinfo, scrinfo, muselsl, exptdesign, 'emotion');
        
    elseif strcmp(sessinfo.taskName, 'Face') % face ID ABx task
        
        ABxTaskMuse(sessinfo, scrinfo, muselsl, exptdesign);
        
    elseif strcmp(sessinfo.taskName, 'AFOV') % ufov task
        
        sessinfo.datetime = datestr(now,'yyyy-mm-dd_HHMMSS');
        sessinfo.filename = [sessinfo.taskName, 'C_',sessinfo.subjID,'_', sessinfo.datetime];
        AFOVMuse('C', sessinfo, scrinfo, muselsl, exptdesign);
        
        sessinfo.datetime = datestr(now,'yyyy-mm-dd_HHMMSS');
        sessinfo.filename = [sessinfo.taskName, 'P_',sessinfo.subjID,'_', sessinfo.datetime];
        AFOVMuse('P', sessinfo, scrinfo, muselsl, exptdesign);
        
        sessinfo.datetime = datestr(now,'yyyy-mm-dd_HHMMSS');
        sessinfo.filename = [sessinfo.taskName, 'B_',sessinfo.subjID,'_', sessinfo.datetime];
        AFOVMuse('B', sessinfo, scrinfo, muselsl, exptdesign);
        
    elseif strcmp(sessinfo.taskName, 'FVWM') %face memory task
        
        FaceMemoryTaskMuse(sessinfo, scrinfo, muselsl, exptdesign);
        
    elseif strcmp(sessinfo.taskName, 'Strp') % stroop task
        
        CountStroopMuse(sessinfo, scrinfo, muselsl, exptdesign);
        
    elseif strcmp(sessinfo.taskName, 'AOdd')
        
        OddballMuse(sessinfo, scrinfo, muselsl, exptdesign)
        
    elseif strcmp(sessinfo.taskName, 'Brth')

        BreathCountMuse(sessinfo, scrinfo, muselsl, exptdesign);
        
    else
        sca
        fprintf('\n**** TASK NOT FOUND! TRY AGAIN ****\n')
    end
    
    if (sessinfo.eegConnect==1 || sessinfo.eegConnect==3) && ~strcmp(sessinfo.taskName, 'viewmuse')
        
        %muselsl.outlet.push_sample({['name',sessinfo.filename],'0'}, GetSecs);
        WaitSecs(0.5);
        muselsl.outlet.push_sample({'stop'}, GetSecs);
        WaitSecs(1);
        
        % delete outgoing marker stream and incoming EEG stream
        muselsl.outlet.delete
        muselsl.inlet.delete
        
    end
    
    
    WaitSecs(2); % wait 5 seconds before clearing screen
    ShowCursor;
    ListenChar;
    
    Screen('CloseAll')
    
    %end % if isempty
    
end % while alldone

end % function
