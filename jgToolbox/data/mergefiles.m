function mergefiles(files,folder,newfile,newfolder)% function mergefiles%% concatenates an arbitrary number of files within a directory.% GUI interface allows user to change directories and select% files with the mouse if no arguments are passed. files is% a cell array.%% November 18, 1999  JMGdefarg('folder',pwd);if ~nargin,	[files,folder] = selectfiles('*','Select files to merge:');end% merge selected filesif iscell(files),	% new file name	if ~exist('newfile','var'),		[newfile,newfolder] = uiputfile(files{1},'Save merged files as:');	end		if ~exist('newfolder','var'),		newfolder = pwd;,	end		if newfile,		newid = fopen([newfolder,newfile],'w+');		for i = 1:length(files)			tempid = fopen([folder,files{i},':'],'r');			line = [];			line = fgets(tempid);			while line ~= -1				fprintf(newid,'%s',line);				line = fgets(tempid);			end			fclose(tempid);		end		fclose(newid);	endendreturn