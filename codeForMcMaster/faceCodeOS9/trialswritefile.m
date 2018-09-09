cd(matdatadir);dt=dir; tmp=size(dt); kk=tmp(1);found=1;k=1;while found	matfname=['grp',num2str(groupID),'_trials','_ID',sidnum,'_N',num2str(k)];	testname=[matfname,'.mat'];	tmp=0;	for n=1:kk		tmp(n)=strcmp(lower(testname),lower(dt(n).name));	end;	found=max(tmp);	k=k+1;end;thedate=date;clear images facestim thumbnail; % we don't need these any more, so delete 'emsave(matfname); % save everything else to a mat filedisp(['workspace stored in file ',testname]);cd(mainpath);cd(textdatadir);textfname=['grp',num2str(groupID),'_trials','_ID',sidnum];testname=[textfname,'.txt'];datafilename=testname;fid=fopen(datafilename,'a');count=fprintf(fid,'%s\n',['Date: ',thedate]);count=fprintf(fid,'%s\n',['File: ',datafilename]);count=fprintf(fid,'%s\n',['Experiment: ',exptname]);count=fprintf(fid,'%s\n',['Subject ID: ',sidnum]);count=fprintf(fid,'%s\n',['Gender: ',sgender]);count=fprintf(fid,'%s\n',['Age: ',num2str(sage)]);count=fprintf(fid,'%s\n',['Group ',num2str(groupID),':',num2str(trialspervalue(groupID)),' trials per contrast level']);count=fprintf(fid,'%s\n',['Comment: ',scomment]);count=fprintf(fid,'%s\n',['Calibration File: ',calfile]);count=fprintf(fid,'%s\n',['Avg Luminance: ',num2str(cal.lmaxminave(3))]);count=fprintf(fid,'%s\n',['Display Frame Rate (Hz): ',num2str(displayrate)]);count=fprintf(fid,'%s \t %s \t %s\n','Display Size (pixels): ',['Width: ',num2str(scrinfo.width)],['Height: ',num2str(scrinfo.height)]);count=fprintf(fid,'%s\n',['Display set to ',num2str(scrinfo.pixelSize),' bits per pixel']);count=fprintf(fid,'%s\n',['Stimulus duration (sec): ',num2str(exptdesign.duration)]);count=fprintf(fid,'%s\n',['Time between fixation point offset and stimulus onset (sec): ',num2str(exptdesign.fixpntstimoffset)]);count=fprintf(fid,'%s\n',['Inter-trial interval (sec):',num2str(exptdesign.intertrial)]);count=fprintf(fid,'%s\n',['Light Adaptation Duration (sec):',num2str(exptdesign.adaptseconds)]);count=fprintf(fid,'%s\n',['Viewing distance (cm):',num2str(exptdesign.viewingdistcm)]);count=fprintf(fid,'%s\n\n',['Matlab workspace stored in file: ',matfname]);count=fprintf(fid,'%s\n',['Data were fit with a weibull function: Gamma = ',num2str(psygamma),'; Delta = ',num2str(psydelta)]);count=fprintf(fid,'%s\n',['Identification threshold was defined as the ',num2str(thresholdlevel*100),'% correct point on the psychometric function.']);count=fprintf(fid,'%s \t %s \t %s \t %s \n','Ext. Noise Var.','Stim. Threshold Var.','Alpha','Beta');for kk=1:exptdesign.numnz	if (goodestimate(kk))		count=fprintf(fid,'%8.6f\t %8.6f\t %8.6f\t %8.6f\n',constimrec(kk).appspec,threshold(kk),alpha(kk),beta(kk));	else		count=fprintf(fid,'%8.6f\t %s\n',constimrec(kk).appspec,'insufficient trials to determine threshold');	end;end;count=fprintf(fid,'%s \t %s \n','Face ID: ','Name');for kk=1:exptdesign.numfaces	count=fprintf(fid,'%s\t %s\n',num2str(kk),char(facenames(kk)));end;count=fprintf(fid,'\n%s\n',['DATA']);count=fprintf(fid,'%s \t %s \t %s \t %s \t %s \t %s \t %s \t %s \n','trial #','conditionID','nz var','face var','stim ID','response','correct','RT(sec)');[numtrials,tmp0]=size(data);for kk=1:numtrials fprintf(fid,'%i \t %i \t %8.6f \t %8.6f \t %i \t %i \t %6.2f \t %i\n',data(kk,1:8)); endfclose(fid);cd(mainpath);disp(['data stored in text file ',datafilename]);