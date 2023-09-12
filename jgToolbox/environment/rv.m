function rv(file,folderorfile)% function rv(file,folderorfile)%% Use with jg: jg rv <folderorfile>% General Use: rv <masterfile> <folderorfile>%% Opens the finder folder containing the folder or file% specified. if the string passed is a shortcut, the corresponding% folder is opened. if the string passed is a file on the search% path or in the current path the folder containing it is opened.% if no string is passed the working folder is opened.%% July 4, 1998  JMG U of T Vision Lab% choose the switch file 'jg.m' if no file is passedif nargin < 1	file = 'jg.m';endmd = pwd;fiderror = 1;if exist('folderorfile') 		if ~isempty(folderorfile)		% get the paths from the shortcut		if exist(folderorfile,'file') == 2			found = 1;		else			casestr = '			case ''';			gostr = ''', godir = ''';			eval([file(1:2),' env;']);			fid = fopen(file,'r+');			str = folderorfile;			found = 0;			if fid ~= -1				while ~feof(fid) & ~found					temp = fgetl(fid);					if length(temp) >= length([casestr,str])						if temp(1:length([casestr,str])) == [casestr,str] 							folderorfile = temp(length([casestr,str,gostr])+1:end-2);							found = 1;									end					end				end				fclose(fid);			else				printstr('There was a problem opening the main file.');				printstr('Make sure it is not already open (e.g., being edited).');				fiderror = 0;			end		end	else		folderorfile = md;		found = 1;	end	else	folderorfile = md;	found = 1;endcd(md);% reveal the file or folder if path was foundif found	areveal(folderorfile);elseif fiderror	printstr('File/Directory not found.');endprintstr(md);return