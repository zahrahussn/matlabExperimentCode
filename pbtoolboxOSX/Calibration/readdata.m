function data = readdata( fname, folder)% READDATA  Read data and execute commands embedded in a data file%% data = readdata( fname, folder)%% if folder is provided, the working directory is used.% if file is not in working directory or in the specified% folder, matlab's search path is searched. if it is not% on the path, the function is terminated.% execute tagged commandsif ~exist('folder','var')	folder = pwd;endoldpath=pwd;cd(folder);fid = fopen(fname,'r');% fid = fopen([folder,fname],'r');% if the file opening was not successful,% look in matlab search path for it% quit if it still is not thereif fid == -1	eval(['folder=which(',QuoteString(fname),');']);	if isempty(folder)		return;	else		folder = folder(1:end-length(fname));		fid = fopen([folder,fname],'r');	endendwhile feof(fid)==0,	line = fgets(fid);	if size(line,2)>=3,		if (line(1)=='%') & (line(3)=='*'),			evalin('caller',line(4:size(line,2)));		end	endendfclose(fid);% try to load ascii data file;  return if empty % (some files may contain only commands )data=[ 1 ];% eval('load([folder,fname],''-ascii'')','data=[];');eval('load(fname,''-ascii'')','data=[];');if isempty(data)==1,	returnend% assign data from file to return argumentperiod=findstr(fname,'.');if isempty(period)==0,	fname=fname(1:period-1);end[ path stem ] = fileparts(fname);eval( sprintf('data=%s;',stem) );cd(oldpath);return