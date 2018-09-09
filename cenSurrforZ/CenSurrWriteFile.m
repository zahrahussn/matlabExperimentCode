% Last Update:  July 19, 2007/ er   - Made it look really nice.
% data(curtrial,:)=[exptdesign.curCondition,curContrast,curtrial,numblank,scID,curStimLevel,respLocation,targLoc(curtrial),correct]; 

cd(matdatadir);
dt=dir; tmp=size(dt); kk=tmp(1);  % kk = number of files in mat data folder
found=1;
k=1;
while found
	matfname=['grp',num2str(groupID),'_',exptname,'_ID',sidnum, '_S', ssession, '_N', num2str(k)];
	testname=[matfname,'.mat'];
	tmp=0;
	for n=1:kk
		tmp(n)=strcmp(lower(testname),lower(dt(n).name));
	end;
	found=max(tmp);
	k=k+1;
end;
thedate=date;
save(matfname); % save everything to a mat file
disp(['workspace stored in file ',testname]);
cd(mainpath);

cd(textdatadir);
textfname=['grp',num2str(groupID),'_',exptname,'_ID',sidnum];
testname=[textfname,'.txt'];
datafilename=testname;

fid=fopen(datafilename,'a');
count=fprintf(fid,'\n%s\n',['Date: ',thedate]);
count=fprintf(fid,'%s\n',['File: ',datafilename]);
count=fprintf(fid,'%s\n',['Experiment: ',exptname]);
count=fprintf(fid,'%s\n',['Subject ID: ',sidnum]);
count=fprintf(fid,'%s\n',['Gender: ',sgender]);
count=fprintf(fid,'%s\n',['Age: ',num2str(sage)]);
count=fprintf(fid,'%s\n',['Group ',num2str(groupID)]);
count=fprintf(fid,'%s\n',['Comment: ',scomment]);
count=fprintf(fid,'%s\n',['Vertical or horizontal: ',smovement]);
% if(calinfo.usebitsbox==0)
%     count=fprintf(fid,'%s\n',['Calibration File: ',calinfo.calfile]);
%     count=fprintf(fid,'%s\n',['Avg Luminance: ',num2str(cal.lmaxminave(3))]);
% end;

count=fprintf(fid,'%s\n\n',['Matlab workspace stored in file: ',matfname]);
% 
% count=fprintf(fid,'%s\n\n', 'DISPLAY PARAMETERS');
% count=fprintf(fid,'%s\n',['Display Frame Rate (Hz): ',num2str(scrinfo.framerate)]);
% count=fprintf(fid,'%s \t %s \t %s\n','Display Size (pixels): ',['Width: ',num2str(scrinfo.width)],['Height: ',num2str(scrinfo.height)]);
% count=fprintf(fid,'%s\n',['Assumed pixel density (pixels/cm):',num2str(exptdesign.pixpercm)]);
% count=fprintf(fid,'%s\n',['Display set to ',num2str(scrinfo.pixelsize),' bits per pixel']);
% 
% count=fprintf(fid,'%s\n\n','TIMING PARAMETERS');
% count=fprintf(fid,'%s\n',['Light Adaptation Duration (sec):',num2str(exptdesign.adaptseconds)]);
% count=fprintf(fid,'%s\n',['Light adaptation duration was reduced to 20 secs on 2nd & subsequent staircases.']);
% count=fprintf(fid,'%s\n',['Maximum Stimulus duration (frames): ',num2str(exptdesign.maxstimframes)]);
% count=fprintf(fid,'%s\n',['Minimum Stimulus duration (frames): ',num2str(minlevel)]);
% count=fprintf(fid,'%s\n',['Mask duration (sec): ',num2str(exptdesign.maskduration)]);
% if (exptdesign.usespace==0)
% 	count=fprintf(fid,'%s\n',['Inter-trial interval (sec):',num2str(exptdesign.intertrial)]);
% end;
% 
% count=fprintf(fid,'\n%s\n\n','STIMULUS PARAMETERS');
% count=fprintf(fid,'%s\n',['Viewing distance (cm):',num2str(exptdesign.viewingdistcm)]);
% count=fprintf(fid,'%s\n',['Stimulus Eccentricity (pixels): ',num2str(stimparams.stimEccenDeg)]);
% count=fprintf(fid,'%s\n',['Stimulus spatial frequency(cycles per image):',num2str(stimparams.sf)]);
% count=fprintf(fid,'%s\n',['Stimulus spatial frequency(cycles per deg):',num2str(stimparams.sfcydeg)]);
% count=fprintf(fid,'%s\n',['Stimulus phase(deg; cosine is 0 deg):',num2str(stimparams.phase(1)),'and alternating between',num2str(stimparams.phase(1)),'and',num2str(stimparams.phase(1)+180),'in the phase condition']);
% count=fprintf(fid,'%s\n',['Width of gabor array (pixels):',num2str(stimparams.pixelwidth)]);
% count=fprintf(fid,'%s\n',['Width of gabor array (cm):',num2str(stimparams.widthcm)]);
% count=fprintf(fid,'%s\n',['Width of gabor array (deg):',num2str(stimparams.widthdeg)]);
% count=fprintf(fid,'%s\n',['C was composed of :',num2str(length(stimparams.angles))]);
% count=fprintf(fid,'%s\n',['Gap size (number of elements):',num2str(stimparams.gapSize)]);
% count=fprintf(fid,'%s\n',['Target locations were :',num2str(stimparams.targets)]);
% count=fprintf(fid,'%s\n',['angles, in degrees, of stimuli (counter clockwise from horizontal)',num2str(stimparams.angles)]);
% for i = 1:exptdesign.numconds
% 
% count=fprintf(fid,'\n%s\t %c\n',['Conditions order:', exptdesign.conditions{i}]);
% end
% if (stimparams.usecirclecue==1)
% 	count=fprintf(fid,'%s\n',['A circular cue surrounded the stimulus on each interval.']);
%  else
%  	count=fprintf(fid,'%s\n',['No circular cue surrounded the stimuli.']);	
%  end;
% if (exptdesign.playintervalsounds==1)
% 	count=fprintf(fid,'%s\n',['Stimulus intervals were marked by tones.']);
% else
% 	count=fprintf(fid,'%s\n',['Stimulus intervals were NOT marked by tones.']);
% end;
% count=fprintf(fid,'%s\n',['Stimulus Contrast for each block: ',num2str(stimparams.contrast)]);
% 
% 
% count=fprintf(fid,'%s\n',['Spacing of grid in pixels:',num2str(stimparams.spacing)]);
% count=fprintf(fid,'%s\n',['Grid width in pixels:',num2str(stimparams.gridwidth)]);
% count=fprintf(fid,'%s\n',['The grid center was jittered by a normal distribution with sd in pixels of:',num2str(stimparams.gridjitter)]);
% count=fprintf(fid,'%s\n',['The C center was jittered by a normal distribution with sd in pixels of:',num2str(stimparams.cjitter)]);
% count=fprintf(fid,'%s\n',['Minimum distance between gabor element centers (pixels):',num2str(stimparams.critdist)]);
% count=fprintf(fid,'%s\n','Each noise gabor was displaced from the ideal grid coordinate using a normal distribution with sd = 4 pixels');
% count=fprintf(fid,'%s\n',['All gabors were pasted into an array of size :',num2str(stimparams.arraysize)]); 
% count=fprintf(fid,'%s\n',['Texture was centered at coordinates: ', num2str(stimparams.arrayCenter)]);
% 
% 
% count=fprintf(fid,'\n%s\n\n','STAIRCASE PARAMETERS');
% count=fprintf(fid,'%s\n',['Minimum reversals needed for threshold: ',num2str(minreversals)]);
% count=fprintf(fid,'%s\n',['Initial staircase step size was' , num2str(firststep), ' followed by ', num2str(steparray)]);
% count=fprintf(fid,'%s\n',['Staircase step size changed immediately after reversals ',num2str(switchafterRevnum),'.']);
% count=fprintf(fid,'%s\n',['Staircase was 1-up, ',num2str(downcount),'-down']);
% count=fprintf(fid,'%s\n',['Initial threshold guesses were ',num2str(thresholdguess),'and ',num2str(2*thresholdguess)]);
% count=fprintf(fid,'%s\n','Staircase records recorded in screc(block#,cond#,sc#)');
% % 
% 
count=fprintf(fid,'\n%s\n',['DATA']);
%         data(curtrial, :) = [curContrast  curSFcpd cursizedeg gaussSD dir respLocation scID curDuration correct];
count=fprintf(fid,'%s\t %s\t %s\t %s\t %s\t %s\t   %s\t %s\t  %s\n', 'contrast','sp freq','size (Deg)', 'gaussSD','dir','resp','scID', 'curDur', 'correct');
        
[numtrials, numcols]=size(alldata);
for kk=1:numtrials fprintf(fid,'%2.3f\t %2.3f\t %i\t %2.3f\t %i\t %i\t %i\t %2.3f\t %i\n',alldata(kk, :)); end;

fprintf(fid, '\n\n\n')
fclose(fid);

cd(mainpath);
disp(['data stored in text file ',datafilename]);

