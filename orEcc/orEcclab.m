% orEcclab.m% Driver for the orientation/eccentricity experiments.%clear all; % clear the workspacestarttime=getsecs;randn('state',sum(100*clock)); % initialize the random number generatororEccparams; % initialize the parametersstartexperiment=0;while (startexperiment==0)	disp(' ');	disp('>>>>>>>>> ATTENTION <<<<<<<<<<');	disp(['Make sure that the viewing distance is ',num2str(vd),' cm.']);	disp(' ');	disp('******** ?? CHANGE CURRENT SETTINGS ?? ********');	disp(['1......ID       (',sidnum,')']);	disp(['2......GENDER   (',sgender,')']);	disp(['3......AGE      (',num2str(sage),')']);	disp(['4......GROUP    (',num2str(groupID),')']);  	disp(['5......COMMENT  (',scomment,')']); 	disp(['6......LOAD PREVIOUS SETTINGS']);	disp(['7......']);	disp(['8......']);	disp(['9......']);	disp(['b......Begin experiment']);	disp(['x......eXit experiment']);	tmpselect=lower(input('ENTER YOUR SELECTION >> ','s'));	switch tmpselect	case '1'		sidnum=[];		disp('');		while (isempty(sidnum))			sidnum=input('Subject ID: ','s');		end;		case '2'						sgender=[];		disp('');		while (isempty(sgender))			sgender=input('Gender: ','s');		end;		case '3'				sage=-1;		disp(' ');		while ((sage<1)|(sage>110))			sage=input('Subject''s age (1-110): ');		end;		case '4'			case '5'		scomment=[];		disp('');		while (isempty(scomment))			scomment=input('Comment: ','s');		end;			case '6'		load subjsettings;			case '7'		disp(' ');			case '8'		disp(' ');			case '9'		disp(' ');						case 'b'			startexperiment=1;			case 'x'		disp(' ');		yesno=input('Really exit (y/n)? ','s');		if (length(yesno)<1)|(lower(yesno)~='n')			return;		end;	end;end;save 'subjsettings' sidnum sgender sage groupID scomment; % save settings% do group-specific stuff here...% this loads the calibration file into memory% it is stored as a structure with lots of fields.% see the calibration routine and 'getddf' for more% details.disp('reading calibration file...');[cal] = getddf(calfile);%oldOn=fileshare(-3); % turn off filesharingstarttime=getsecs;[data,quitflag]=orEccthreshdisplay(cal,stimpix,displayrate,mainscrs,nzpattern,exptdesign);endtime=getsecs;oldOn=fileshare(oldOn); % re-set filesharingdisp(['Elapsed time = ',num2str((endtime-starttime)/60),' minutes']);if (quitflag) disp('The experiment was aborted by the subject.'); end;% close the screen and data file. this is a wrapper around brainard that closes % all of the active windows and any text data file that may have been% opened but not closed during the routine.closeall;	% compute average and SE of reverals for each staircase%for jj=1:exptdesign.numconds%	for kk=1:exptdesign.numnz%		[revthresh(jj,kk),revse(jj,kk)]=scReversalavg(screc(jj,kk),exptdesign.minreversals);%		if (scReversals(screc(jj,kk)) >= exptdesign.minreversals)%			disp(['location = ',num2str(jj),'; noise #',num2str(kk),'; threshold = ',num2str(revthresh(jj,kk)),'; se = ',num2str(revse(jj,kk))]);%		else%			disp(['location = ',num2str(jj),'; noise #',num2str(kk),'; Insufficient reversals to compute a threshold']);%		end;%	end;end;orEccwritefile; % write data files to diskcd(mainpath); % restore original path