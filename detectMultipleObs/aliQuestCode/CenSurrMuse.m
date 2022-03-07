%  % Modified for 150 trials, break every 50 trials, 3 sec intertrial interval.
%  Center Surround behavioural experiment
% Written by ER. 2010.
%
% modified by AH 2019 -- 40 trials of small and 40 trials of large, both
% high contrast only. Blocked.

function CenSurrMuse(sessinfo, scrinfo, muselsl, exptdesign)

EXPTSTART = GetSecs;

% unravel structures to raw vars
tmp = fields(sessinfo);
for ii=1:length(tmp)
    eval([tmp{ii},'=sessinfo.',tmp{ii},';']);
end

tmp = fields(scrinfo);
for ii=1:length(tmp)
    eval([tmp{ii},'=scrinfo.',tmp{ii},';']);
end
window=w;

if eegConnect>0
    tmp = fields(muselsl);
    for ii=1:length(tmp)
        eval([tmp{ii},'=muselsl.',tmp{ii},';']);
    end
end

tmp = fields(exptdesign);
for ii=1:length(tmp)
    eval([tmp{ii},'=exptdesign.',tmp{ii},';']);
end


% exptdesign.stimduration=0.150; % stimulus duration (sec)
params.timing.fixPntOffset = 0.5; % fixation offset (sec)
params.timing.intertrial = 1.5; % inter-trial duration (sec)
params.timing.adaptseconds = 3; % light adaptation time (sec) before 1st staircase
params.timing.adaptreduction = 0.33;% reduce adaptation time by this factor on 2nd and subsequent staircases
params.timing.stimOffRespOn = 0.25;

%practice
%params.practice.numtrials = 5; %is set to 0 for 
params.practice.duration = 1; % duration means repetitions..AH thinks

%other
params.usefeedback = 1;
params.playintervalsounds = 0; % if 1, then each stimulus interval is marked by a tone

params.motionDirection = 'LeftRight';

%% set up params... brought in from CenSurrParamsV2 script
params.stimulus.sizes = [1 4];  % deg visual angle 1 4 1 4
params.stimulus.sizespix = round(params.stimulus.sizes./scrinfo.degperpixel);
% params.stimulus.size2SD_4Ys = [1.87 2.50 1.87 2.50];  % mean values from 2IFC PSE results from 4 younger subjects.  Will be used as standard. 
% params.stimulus.gaussSD_standard = params.stimulus.sizespix./params.stimulus.size2SD_4Ys;  % SIZES of Gauss SD in pixels.  
%params.stimulus.gaussSD = [params.stimulus.gaussSD_standard]; %diameter of each grating 
% will use the Betts et al., 2009 and Zhuang et al 2016 definition of size
% size was defined as two standard deviations (2sigma) of the Gaussian envelope.
params.stimulus.gaussSD_standard = params.stimulus.sizespix/2;
params.stimulus.gaussSD = [params.stimulus.gaussSD_standard]; %

params.stimulus.sfcpd = 1; % sp. frequencies

params.stimulus.eccenDeg = 0;
params.stimulus.eccPixels = round(params.stimulus.eccenDeg/scrinfo.degperpixel); % stimulus distance from fixation point (in pixels)

params.stimulus.contrast = [0.85 0.85]; % contrasts  0.05 0.05 0.85 0.85

gratingTypes = {'SmallHigh','LargeHigh'}; % 'SmallLow','LargeLow','SmallHigh','LargeHigh'

% params.stimulus.avgLum = 42; % rough value from Betts et al 2005
params.stimulus.maxContrast = 1;
params.stimulus.speeddps = 2; % degree drifting grating
params.stimulus.speedpps = (params.stimulus.speeddps/scrinfo.degperpixel);   %pix/sec

params.conditions = [params.stimulus.sizes; params.stimulus.gaussSD_standard; params.stimulus.contrast]'; % make this a matrix with constrast in col 1, size in col 2
params.numconds = size(params.conditions,1); %size(params.conditions,1); % 1 * 1 * 3 = 3 conditions
params.stimorder = randperm(params.numconds); % these may get divided into two sessions. 

params.stimulus.sizedeg = params.conditions(params.stimorder,1); % stimulus Diameters in degrees, in order of presentation
params.stimulus.gaussSD  = params.conditions(params.stimorder,2);
params.stimulus.contrast = params.conditions(params.stimorder,3); % stim contrast, in order of presentation

switch params.motionDirection
    case 'UpDown'
        params.stimulus.angle = 90; % angles, in degrees, of stimuli (counter clockwise from horizontal)
    case 'LeftRight'
        params.stimulus.angle = 0;
end
params.stimulus.sfcpp = params.stimulus.sfcpd*scrinfo.degperpixel; 			% stimulus sf in cy/pixel
params.stimulus.phase = 90;		% is be randomized on every trial

%params.ntrials = 50;

params.nEzTrials = 5;
params.nScTrials = 40;
params.nTrials = params.nEzTrials + params.nScTrials;
params.ScOrEz = [ones(params.nEzTrials, 1); zeros(params.nScTrials,1)];


%% set up staircases

params.procedure = 'Quest+'; % 'Quest+'
screc = [];
switch params.procedure 
    case 'interleaved'
        sc.maxtrials = 65; 
        sc.maxreversals = 50; % 50,  staircase ends after maxtrials OR maxreversals is reached
        sc.minreversals = 4; % won't compute average of reversals (for threshold) unless the staircase has at least this number of reversals
        sc.lastnrevs = 4; % compute threshold from last 4 reversals

        sc.minlevel = 1; % min number frames
        sc.maxlevel = 0.500*scrinfo.framerate; % max number of frames... ~ 1
        sc.range = sc.maxlevel-sc.minlevel;
        sc.stepsize = 1; %steps of 1 frame
        sc.stimrange = linspace(sc.minlevel,sc.maxlevel,sc.maxlevel/sc.stepsize);
        % contraststepsize=stimrange(2)/stimrange(1); % staircase stepsize in log units
        sc.firststep = 5; % moves 5 frames up or down
        sc.steparray = [3,1]; % subsequent step sizes (2/20, 1/20, of a log unit)
        sc.switchafterRevnum = [3,6]; % change step size after reversals 3, & 6
        % we are going to use 2 inter-leaved staircases for each condition
        sc.downcount = [2,4]; % one will follow the 2-down/1-up rule; other follows 4-down/1-up rule
        sc.tg = round(0.25*scrinfo.framerate); % an initial guess for each condition

        for kk = 1:params.numconds
           for jj = 1:length(sc.downcount)
               screc(kk,jj) = scInit(sc.downcount(jj),sc.stimrange,sc.tg,sc.maxtrials,sc.maxreversals,sc.firststep,sc.steparray,sc.switchafterRevnum);
           end % for jj
        end % for kk
        
    case 'Quest+'
        
        %% set-up staircase (questplus)... new values following simulations. 
        sc.beta = linspace(1,10,5); % estimate slope of psychometric function % increased to 10 here. 
        sc.gamma = 0.5; % chance (lower asymptote of psychometric fit
        sc.delta = 0:0.02:0.10; % free lapse rate for upper asymptote
        sc.min = 2; % minimum is 2 because this is a motion stimulus. 
        sc.max = round(0.5*scrinfo.framerate); % half framerate = half second
        sc.stepsize = 1; % frames. 
%        sc.steps = sc.max / sc.stepsize;
        sc.stimrange_frames = sc.min:sc.stepsize:sc.max;  % allowing all frame levels b/c thresholds will vary a lot.. and in any case only gives us 40 levels, which is OK. 
        sc.stimrange = contrast2db(sc.min:sc.stepsize:sc.max);

        sc.nsteps = length(sc.stimrange);
%        sc.steps = 41; %sc.max / sc.stepsize;
 %       sc.stimrange = linspace(contrast2db(sc.min), contrast2db(sc.max), sc.steps); % log spaced durations. 
  %      sc.stimrange = contrast2db(unique(round(db2contrast(sc.stimrange)))); % stim dur limited by frame #, so must get rid of non-unique values after rounding to integers.

        
        psiParamsDomain = { sc.stimrange, sc.beta, sc.gamma, sc.delta };

        params.sc = sc;
        
        nTrials = params.nScTrials + params.nEzTrials; % per staircase (i.e., per block) % THIS nTrials var is not being used
        % this nTrials is just for staircase... stops each staircase after nTrials
        for nn = 1:params.numconds % same as numblocks bc size is blocked
            scQP{nn}.param = qpParams( ...
                'nOutcomes', 2, ...
                'stimParamsDomainList', { sc.stimrange }, ...
                'psiParamsDomainList', psiParamsDomain, ...
                'stopRule', 'nTrials', ...
                'verbose', true );
            scQP{nn}.questData = qpInitialize(scQP{nn}.param);
            scQP{nn}.condition = gratingTypes{nn};
            scQP{nn}.ezcond = max(sc.stimrange);
            scQP{nn}.eztrials = params.nEzTrials;
            scQP{nn}.sctrials = params.nScTrials;
            scQP{nn}.ScOrEz = params.ScOrEz; % first 5 trials are easy. 
        end
                
end

if eegConnect==1
    % fill this out
    museflags.blockid = {'blockStart_small_highC', 'blockStart_large_highC'; ...
                        'blockStop_small_highC', 'blockStop_large_highC'};
    museflags.e1_trial = 'trialstart';%1; % fixation onset: beginning of trial
    museflags.e2_stim = {'stim_smallHighLeft','stim_largeHighLeft'; ...
                        'stim_smallHighRight','stim_largeHighRight'};
    museflags.e3_resp = {'resp_inc','resp_cor'}; %[6 7]; % response registered.. 6=correct, 7=incorrect
    
    % arrange flags in the proper randomized order
    museflags.blockid = museflags.blockid(:,params.stimorder);
    museflags.e2_stim = museflags.e2_stim(:,params.stimorder);

else
    museflags = [];
end

%%
disp(['Make sure that the viewing distance is ',num2str(scrinfo.viewingdistcm),' cm.']);
% we'll store some data in these variables

alldata=[];                         % data from each trial

etime = zeros(1,params.numconds);

%Screen('CloseAll');
%keyboard


% this runs each condition in a separate block.
alldata=[];
for nn=1:params.numconds
        starttime=GetSecs;
        params.curBlock=nn;
        
        %screc = sc.screc(nn,:);
        
        if nn==1
            params.practice.numtrials = 5; %is set to 0 for 
        else
            params.practice.numtrials = 0; %is set to 0 for 
        end
        
        if eegConnect==1
            muselsl.outlet.push_sample({museflags.blockid{1,nn}}, starttime);
        end
        
        if strcmp(params.procedure, 'interleaved')
              
            [data,screc(nn,:),params,quitflag]=CenSurrDisplay(sessinfo, scrinfo, muselsl, exptdesign, params, museflags, screc(nn,:));
            
            %sc.screc(nn,:) = screc;
            
        elseif strcmp(params.procedure, 'Quest+')
            % insert another CenSurrDisplay call
            
            [data,scQP{nn},params,quitflag]=CenSurrDisplay(sessinfo, scrinfo, muselsl, exptdesign, params, museflags, scQP{nn});
                        
        end
        
        
        endtime=GetSecs;
        etime(nn)=(endtime-starttime)/60;
        disp(['Elapsed time = ',num2str(etime(nn)),' minutes']);
        alldata = [alldata; data];
        
        sessinfo.taskDurationMin = (GetSecs - EXPTSTART)/60;
        
        %save([dataPath, filename],'alldata','quitflag','params', 'exptdesign', 'scrinfo', 'sessinfo', 'museflags', 'scQP');
        save([dataPath, filename]);
        
        if eegConnect==1
            muselsl.outlet.push_sample({museflags.blockid{2,nn}}, endtime);
        end
        

        if (quitflag) 
            disp('The experiment was aborted by the subject.'); 
            break
        end

end

sessinfo.taskDurationMin = (GetSecs - EXPTSTART)/60;

%save([dataPath, filename],'alldata','quitflag','params', 'exptdesign', 'scrinfo', 'sessinfo', 'museflags', 'scQP');
save([dataPath, filename]);


%CenSurrWriteFile; % write data files to disk
%cd(mainpath); % restore original path
%ShowCursor;
