function err=writeMOBS_DataCSV(eRec)
  err = 0;
  if nargin < 1
    fprintf('Missing eRecord.\n');
    err = -1;
    return;
  endif
  curPath = pwd;
  cd(eRec.dataPath);
  trialdata = eRec.trialdata;
  [nr,nc] = size(trialdata);
  nzCondition = eRec.params.noiseCondition;
  extNzVar = eRec.params.extNzVariance;
  ucID = eRec.params.uncertaintyID;
  dayNumber = eRec.params.dayNum;
  dateString = eRec.params.today;
  timeString = eRec.params.curTime;
  sID = eRec.params.subjID;
  fname = eRec.csvname;
  fid = fopen(fname,'w');
  if (fid < 0)
    err = -2;
    fprintf('Error opening file.\n');
  else
    fprintf('Writing data to file %s\n',fname);
  endif;
  
% eRec.trialdata(curTrial,:) = [curTrial,observation,curTexID,curTexSD,curTargInterval,correct,qflag];

  txt = 'sID,date,time,nzType,nzVar,day,condition,trial,observation,textureID,texContSD,stimInterval,correct,qflag\n';
  fprintf(fid,txt); % write header for CSV file
  for kk=1:nr
  txt = sprintf('%s,%s,%s,%s,%f,%i,%s,%i,%i,%i,%f,%i,%i,%i\n',sID,dateString,timeString,nzCondition,extNzVar,dayNumber,ucID,trialdata(kk,:));
  fprintf(fid,txt); % write to file
  end

  err = fclose(fid);
  cd(curPath);
  
endfunction
