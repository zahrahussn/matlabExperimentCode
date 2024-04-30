function [data,constimrec,quitflag]=facethreshdisplay(cal,stimpix,displayrate,constimrec,mainscrs,thumbnail,facestim,exptdesign);
%
% function [data,constimrec]=facethreshdisplay(cal,stimpix,displayrate,constimrec,mainscrs,facestim,exptdesign);
%


MONTE_CARLO_SIM=0;

% initialize the random number generator
randn('state',sum(100*clock));

% for playing sounds using 'snd'
SND_RATE=8192;

% data matrix
data=zeros(1,10); % dm: col 1 is staircase ID(1-4); col 2 is target contrast; col 3 is nzvar; col 4 is response;

% These are the values for the response keys
key1 = abs('1'); % face 1
key2 = abs('2'); % face 2
key3 = abs('9'); % face 3
key4 = abs('0'); % face 4
escapekey = 27;

% This is the value for the space bar, which is used to start each trial.
spacebar=32;
deletekey=8;

% convert stimulus duration from seconds to frames
stimframes=round(displayrate*exptdesign.duration);
fixpntoffsetframes=round(displayrate*exptdesign.fixpntstimoffset);
if fixpntoffsetframes<1
	fixpntoffsetframes=1;
end;

% make sounds for feedback, etc.
introsnd=makesnd(600,.2,.6);
intervalsnd=makesnd(300,exptdesign.duration,.6);
corrsnd=makesnd(800,.09,.6);
wrongsnd=makesnd(200,.09,.7);

% calculate the max and min contrasts for this display
L = cal.lmaxminave;
cmax=(L(1)-L(3))/L(3);
cmin=(L(2)-L(3))/L(3);


dcLUT=0;	% the rgb value for DC is stored in LUT index 0 (zero-based); for matlab, it is stored in array position #1
fixrgb=[0 0 0];	% the RGB value for the fixation point
fixLUT=1;	% the rgb value is stored in LUT index 1 (zero-based); for matlab, it is stored in array position #2
wordLUT=2;	% the rgb value for the stimulus word is stored in LUT index 2;

% this makes an initial CLUT set to average luminance. In the calibration
% routine, average luminance is arbitrarily chosen as the luminance 
% of the pixel combination [160 160 160]. you can change this easily.
tempCLUT=ones(256,3)*160;

% this just stuffs a low-luminance value in the clut for text display.
% it will be overwritten later on.
tempCLUT(2,:)=[1 1 1];

% this is the screen upon which the image is to be displayexptdesign. 
defarg('mainscrs',0);

% this opens brainard's screen function. it is a wrapper
% around the original function that can set mutiple screens
% at once and sets unused screens to zero luminance.
[screens,rects] = openscreens(mainscrs,tempCLUT);
fixpnt=setrect(0,0,8,8);fixpnt=CenterRect(fixpnt,rects(1,:));
stimrect=setrect(0,0,stimpix,stimpix);
destrect=CenterRect(stimrect,rects(1,:));
boxrect=setrect(0,0,stimpix+8,stimpix+8);
boxrect=CenterRect(boxrect,rects(1,:));

% make rects for thumbnail images on response window
thumbsize=size(thumbnail(1).face);
thumbrect=setrect(0,0,thumbsize(2),thumbsize(1));
thumbdest=zeros(4,4);
for kk=1:exptdesign.numfaces
	thumbdest(kk,:)=CenterRect(thumbrect,rects(1,:));
end;

thumbdest(1,:)=offsetrect(thumbdest(1,:),round(-4*thumbsize(1)),round(-2*thumbsize(1)));
thumbdest(2,:)=offsetrect(thumbdest(2,:),round(-2*thumbsize(1)),round(-2*thumbsize(1)));
thumbdest(3,:)=offsetrect(thumbdest(3,:),round(0*thumbsize(1)),round(-2*thumbsize(1)));
thumbdest(4,:)=offsetrect(thumbdest(4,:),round(2*thumbsize(1)),round(-2*thumbsize(1)));
thumbdest(5,:)=offsetrect(thumbdest(5,:),round(4*thumbsize(1)),round(-2*thumbsize(1)));
thumbdest(6,:)=offsetrect(thumbdest(6,:),round(-4*thumbsize(1)),round(2*thumbsize(1)));
thumbdest(7,:)=offsetrect(thumbdest(7,:),round(-2*thumbsize(1)),round(2*thumbsize(1)));
thumbdest(8,:)=offsetrect(thumbdest(8,:),round(0*thumbsize(1)),round(2*thumbsize(1)));
thumbdest(9,:)=offsetrect(thumbdest(9,:),round(2*thumbsize(1)),round(2*thumbsize(1)));
thumbdest(10,:)=offsetrect(thumbdest(10,:),round(4*thumbsize(1)),round(2*thumbsize(1)));


% numwindows=3;
% offscrptrs=zeros(1,numwindows);
offscrptrs(1)=screen(mainscrs,'OpenOffscreenWindow',0,stimrect);	% offscreen window for face

% create the off-screen windows for thumbnail images
for kk=1:exptdesign.numfaces
	thumbnailptr(kk)=screen(mainscrs,'OpenOffscreenWindow',0,thumbrect);	% offscreen window for thumbnail image
 	screen(thumbnailptr(kk),'PutImage',thumbnail(kk).face); % store thumbnail face image in offscreen pixel map
end;

% These values work for Big Blue's monitor... They are hardware dependent!!!
% screen(screens(1),'Preference','WaitForVBLInterrupt',1);
% screen(screens(1),'Preference','SetClutWaitVBL',1);


% create a clut and load it
defaultCLUT=[0:255]'*[1 1 1];
defaultCLUT(1,:)=[160,160,160]; % DC value in index 1
defaultCLUT(2,:)=fixrgb; % value for the fixation point & text
screen(screens(1),'SetClut',defaultCLUT,0);
screen(screens(1),'FillRect',0); % this fills the screen with clut index 0, which is [160 160 160]

% start of the scan...
hidecursor; % this hides the mouse cursor

starttime=getsecs;

% light adapt
adaptpause(screens(1),rects(1,:),exptdesign.adaptseconds);

err=snd('Open'); % open the sound buffer
err=snd('Play',introsnd,SND_RATE); err=snd('Play',corrsnd,SND_RATE); err=snd('Play',wrongsnd,SND_RATE);

flushevents('keyDown'); % this flushes any key presses before this point.
flushmouse;
waitsecs(1);

screen(screens(1),'SetClut',defaultCLUT,0); % load clut
screen(screens(1),'FillRect',0); % clear the screen with average luminance
screen(screens(1),'FillOval',1,fixpnt); % draw fixation point

quitflag=0;
alldone=0;
curtrial=1;
while ((alldone==0)&(quitflag==0))
	stime=getsecs; % get the start time for this trial; we'll use this later
	curface=randomcondition(exptdesign.numfaces); % randomly select the faceID for this trial
	gotone=0;
	while (gotone==0)
		condID=randomcondition(exptdesign.numnz);
		if (~psyfuncfinished(constimrec(condID))) gotone=1; end;
	end;
	
	nzvar=constimrec(condID).appspec;	% noise variance
	[stim,nzseed]=noise2d(stimpix,nzvar,cmin,cmax,0);
	curStimVariance=constimGetValue(constimrec(condID)); % get the stimulus variance for the current method-of-constant-stimuli record
	tmpface=facestim(curface).face*sqrt(curStimVariance); % this formula works because the faces have a variance of 1
	stim=stim+tmpface;
		% this is the routine that makes a pixel image and a CLUT for display.
	% the first index in the clut is always reserved for average luminance.
	% remember that the routine expects the image in terms of *contrast*.
	[currimage,currCLUT]=makeimage(stim,cal,0);
	screen(offscrptrs(1),'PutImage',currimage); % store in offscreen pixel map
	gotime=stime+exptdesign.intertrial; % wait here
	
	while (getsecs<gotime) end;
	screen(screens(1),'WaitBlanking'); % wait 1 frame
	screen(screens(1),'FillOval',0,fixpnt); % erase fixation point
	screen(screens(1),'WaitBlanking',fixpntoffsetframes-1); % wait for the correct number of frames
	screen(screens(1),'SetClut',currCLUT,0); % write to clut and return 1 frame later
	screen(screens(1),'FrameRect',1,boxrect); % draw the stimulus box
	screen('CopyWindow',offscrptrs(1),screens(1),stimrect,destrect); % copy the image to the screen
	screen(screens(1),'WaitBlanking',stimframes); % wait for the correct number of frames
	screen(screens(1),'FillRect',0,destrect); % fill destrect with avg lum
	screen(screens(1),'FrameRect',0,boxrect); % erase the stimulus box
	stimofftime=getsecs;
	screen(screens(1),'WaitBlanking'); % wait 1 frame
	screen(screens(1),'SetClut',defaultCLUT,0);
	screen(screens(1),'FillOval',1,fixpnt); % draw fixation point


% 	if (MONTE_CARLO_SIM == 1)
% 		salpha=[0.00001,0.0015,0.003]; sbeta=2; sgamma=0.25; sdelta=0.01;
% 		r=simcorrect(curStimVariance,salpha(condID),sbeta,sgamma,sdelta);
% 		if (r==1)
% 			response=curface;
% 		else
% 			response=curface+1;
% 		end;	
% 		rlatency=getsecs-stimofftime;
% 	else
		% draw thumbnail images
		for kk=1:exptdesign.numfaces
			screen('CopyWindow',thumbnailptr(kk),screens(1),thumbrect,thumbdest(kk,:)); % copy the image to the screen
		end;	

		flushevents('keyDown');
		flushevents('mouseDown');
		flushevents('mouseUp');
		% center the mouse on the fixation point
		theX=fixpnt(rectleft)+round(rectwidth(fixpnt)/2);
		theY=fixpnt(recttop)+round(rectheight(fixpnt)/2);
		while 1
			SetMouse(theX,theY);
			[checkX,checkY] = GetMouse;
			if (checkX==theX) & (checkY==theY)
				break;
			end
		end
		showcursor(0); gotresponse=0; response=0;
		while (gotresponse==0)
			[isavail,eventType]=eventavail('mouseDown','mouseUp');
			if (isavail)
				[clicks,x,y]=getclicks(screens(1));
				for kk=1:exptdesign.numfaces
					if (isinrect(x,y,thumbdest(kk,:)))
						gotresponse=1; response=kk;
					end; % if
				end; % for
			end; % if
			
			if charavail
				resp=abs(lower(getchar));
				if (resp==escapekey)
					gotresponse=1;
					quitflag=1;
				end; % if (resp==escapekey)
			end; %if charavail
		end; % while
		hidecursor; % this hides the mouse cursor

		if quitflag==1 break; end;
		
% 		resp = 'y';
% 		while abs(resp)~= key1 & abs(resp)~=key2 & abs(resp)~=key3 & abs(resp)~=key4 & abs(resp)~=escapekey
% 			resp = lower(getchar);
% 		end
		
		rlatency=getsecs-stimofftime;
		
% 		switch abs(resp)
% 			case key1
% 				response=1;
% 			case key2
% 				response=2;
% 			case key3
% 				response=3;
% 			case key4
% 				response=4;
% 			case escapekey
% 				quitflag=1;
% 				break;
% 			otherwise
% 				response=0;
% 		end;
		% erase thumbnail images
		for kk=1:exptdesign.numfaces
			screen(screens(1),'FillRect',0,thumbdest(kk,:)); % fill destrect with avg lum
		end;
		screen(screens(1),'SetClut',defaultCLUT,0); % restore clut
% 	end; % if MONTE_CARLO_SIM == 1... else...
	
	if (response > 0)
		correct=(response==curface);
		constimrec(condID)=psyfuncUpdate(constimrec(condID),correct); % update the constant stimuli data structure
		if correct
			% sound(corrsnd);
			err=snd('Play',corrsnd,SND_RATE);
		else
			% sound(wrongsnd);
			err=snd('Play',wrongsnd,SND_RATE);
		end;
	end; % if (response > 0) & (condID>0)
	
	if (response>0)
		data(curtrial,:)=[curtrial,condID,nzvar,curStimVariance,curface,response,correct,rlatency,nzseed']; % update data matrix
		curtrial=curtrial+1; % increment trial counter
	end; % if (response > 0)

% END OF TRIAL...
	tmpdone=1;
	for kk=1:exptdesign.numnz
		if ~psyfuncfinished(constimrec(kk))
			tmpdone=0;
			break;
		end;
	end;
	alldone=tmpdone;
end; % while ((alldone==0)&(quitflag==0))

err=snd('Close'); % close the sound buffer here

showcursor(0);
closeall;	% close the screen and data file. this is a wrapper around brainard that closes 
% all of the active windows and any text data file that may have been
% opened but not closed during the routine.
% sound(introsnd);

return;
