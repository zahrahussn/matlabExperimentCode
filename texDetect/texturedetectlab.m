% texturedetectlab.m% Driver for the trials/learning experiments.%clear all; % clear the workspacestarttime=getsecs;randn('state',sum(100*clock)); % initialize the random number generatortexturedetectparams; % initialize the parametersstartexperiment=0;while (startexperiment==0)	disp(' ');	disp('>>>>>>>>> ATTENTION <<<<<<<<<<');	disp(['Make sure that the viewing distance is ',num2str(vd),' cm.']);	disp(' ');	disp('******** ?? CHANGE CURRENT SETTINGS ?? ********');	disp(['1......ID       (',sidnum,')']);	disp(['2......GENDER   (',sgender,')']);	disp(['3......AGE      (',num2str(sage),')']);	if (groupID>0)&(groupID<=length(trialspervalue)) 		disp(['4......GROUP    (TRIALS = ',num2str(trialspervalue(groupID)),' per contrast level)']);	else		disp(['4......GROUP    (** NO GROUP SPECIFIED ***)']);	end;  	disp(['5......COMMENT  (',scomment,')']); 	disp(['6......LOAD PREVIOUS SETTINGS']);% 	if (ed.usespace)% 		disp(['7......AUTO-TRIAL START IS OFF']);% 	else% 		disp(['7......AUTO-TRIAL START IS ON']);% 	end;	disp(['7......']);	disp(['8......']);	disp(['9......']);	if (groupID>0)&(groupID<=length(trialspervalue))		disp(['b......Begin experiment']);	else		disp(['b......cannot begin experiment until a group is selected']);	end;	disp(['x......eXit experiment']);	tmpselect=lower(input('ENTER YOUR SELECTION >> ','s'));	switch tmpselect	case '1'		sidnum=[];		disp('');		while (isempty(sidnum))			sidnum=input('Subject ID: ','s');		end;		case '2'						sgender=[];		disp('');		while (isempty(sgender))			sgender=input('Gender: ','s');		end;		case '3'				sage=-1;		disp(' ');		while ((sage<1)|(sage>110))			sage=input('Subject''s age (1-110): ');		end;		case '4'		groupID=-1; tmp=-1;		disp('Select Group:');		while (groupID<0)			for kk=1:length(trialspervalue)				disp([num2str(kk),'.....',num2str(trialspervalue(kk)),' trials per contrast level']);			end; % for					tmp=input('Group >> ');			if (tmp>0)&(tmp<=length(trialspervalue))				groupID=tmp;			end; % if			end; % while			case '5'		scomment=[];		disp('');		while (isempty(scomment))			scomment=input('Comment: ','s');		end;			case '6'		load subjsettings;			case '7'		disp(' ');			case '8'		disp(' ');			case '9'		disp(' ');						case 'b'			startexperiment=((groupID>0)&(groupID<=length(trialspervalue)));			case 'x'		disp(' ');		yesno=input('Really exit (y/n)? ','s');		if (length(yesno)<1)|(lower(yesno)~='n')			return;		end;	end;end;save 'subjsettings' sidnum sgender sage groupID scomment; % save settings% do group-specific stuff here:for kk=1:exptdesign.numnz	constimrec(kk).maxtrials=trialspervalue(tmp); % set number of trials per stimulus valueend; % for% this loads the calibration file into memory% it is stored as a structure with lots of fields.% see the calibration routine and 'getddf' for more% details.disp('reading calibration file...');[cal] = getddf(calfile);oldOn=fileshare(-3); % turn off filesharingstarttime=getsecs;[data,constimrec,quitflag]=texturedetectthreshdisplay(cal,stimpix,displayrate,constimrec,mainscrs,thumbnail,facestim,exptdesign);endtime=getsecs;oldOn=fileshare(oldOn); % re-set filesharingdisp(['Elapsed time = ',num2str((endtime-starttime)/60),' minutes']);if (quitflag) disp('The experiment was aborted by the subject.'); end;% close the screen and data file. this is a wrapper around brainard that closes % all of the active windows and any text data file that may have been% opened but not closed during the routine.closeall;	% fit psychometric functions to the data from each external-noise conditionalpha=zeros(1,numnz); beta=zeros(1,numnz); threshold=zeros(1,numnz); goodestimate=zeros(1,numnz);for kk=1:numnz	if (sum(constimrec(kk).trialcount)>=mintrialforthreshold)		tmpdata=constimrec(kk).trialdata;		[alpha(kk),beta(kk)]=fitpsymet(tmpdata,'weibull',[thresholdguess(kk),psybeta],psygamma,psydelta);		threshold(kk)=getthresh(thresholdlevel,'weibull',[alpha(kk),beta(kk)],psygamma,psydelta);		disp(['condition ',num2str(kk),'; alpha = ',num2str(alpha(kk)),'; beta = ',num2str(beta(kk)),'; ',num2str(thresholdlevel*100),'% correct threshold = ',num2str(threshold(kk))]);		goodestimate(kk)=1;		else		disp(['condition ',num2str(kk),': not enough trials to compute threshold']);	end;end;	% ar1=scReversalavg(sc(1),6);% [alpha1,beta1]=fitpsymet(sc(1).trialdata,'weibull',[ar1,2],gamma,delta);% ar2=scReversalavg(sc(2),6);% [alpha2,beta2]=fitpsymet(sc(2).trialdata,'weibull',[ar2,2],gamma,delta);% threshold(1)=getthresh(thresholdlevel,'weibull',[alpha1,beta1],gamma,delta);% threshold(2)=getthresh(thresholdlevel,'weibull',[alpha2,beta2],gamma,delta);texturedetectwritefile; % write data files to diskcd(mainpath); % restore original path