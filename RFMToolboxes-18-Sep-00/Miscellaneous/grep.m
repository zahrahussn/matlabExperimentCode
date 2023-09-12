function FindStringsHere(dirs,theString)% FindStringsHere([theDir],theString)%% Driver script to find all instances of a string in .m files% in a directory.%% If argument theDir is omitted, the folder is taken to be the% current working directory (see pwd).%% 5/15/96  dhb  Wrote it.% 5/15/96  dgp  Cosmetic changes.% 6/24/96  dhb  Wrote as function.disp(sprintf('Looking for string: %s',theString));theFiles = dir(dirs);for i = 1:size(theFiles,1);	file=theFiles(i).name;%	fprintf(1,'%s\n',file);		fsif(file,theString);%	endendreturntheFiles = GetFilenames(theDir,'.h');for i = 1:size(theFiles,1);	fprintf(1,'%s\n',deblank(theFiles(i,:)));	if (~strcmp('ChangeStringsHere.m',deblank(theFiles(i,:))) & ...		  ~strcmp('FindStringsHere.m',deblank(theFiles(i,:))))		fsif(theFiles(i,:),theString);	endend