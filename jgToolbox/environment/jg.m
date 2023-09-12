function jg( varargin )% function jg( varargin )%% Changes directories based upon shortcuts.% Also move, delete, copy, rename, reveal files, copy files, make folders,% save paths, and set paths from the finder using shortcuts.%% Typical use:  jg <shortcutname>  switches the working path to the % path specified by <shortcutname>. these are stored in the body of% this function. non-existent shortcuts produce an error message.% new shortcuts may be added by using the 'ap' command. pre-existing% shortcuts may be removed by using the 'rm' command (see below for% a list of initial commands). each shortcut name must be unique.%% Optional initial commands:% ap	-	 append a new shortcut. 	Use: jg ap <shortcutname> <path> (default is current path)% cp	-	 copy a file.    			Use: jg cp <sourcefile> <sourcelocation> <newlocation>% dl	-	 delete a file or folder	Use: jg dl <fileorfoldername>% md	-	 make a directory (slow)	Use: jg md <foldername> <location> % mv	-	 move a file.    			Use: jg mv <sourcefile> <sourcelocation> <newlocation>% rm	-	 remove a shortcut.			Use: jg rm <shortcutname>% rn	-	 rename a file.				Use: jg rn <oldname> <newname> <location>% rv	-	 reveal a file/folder.		Use: jg rv <folderorfile> (default is current folder) % savep -	 save a path for later use  Use: jg savep <pathname>% setp  -    set a saved path			Use: jg setp  <pathname> % ?		-	 list shortcut(s).			Use: jg ?  <shortcutname> (jg ? for all shortcuts)%% See 'ap.m','rm.m','cp.m','mv.m','rn.m','rv.m','md.m','dl.m','short.m','savepath.m',% and 'setpath.m' for more details.%% June 25, 1998: JMG added append and remove functions.% July 3, 1998:  JMG added copy, move, and rename functions.% July 4, 1998:  JMG added reveal function% July 5, 1998:  JMG added short (?) function% July 6, 1998:	 JMG made general so only the name of this file needs to be changed%				 to make a new shortcut file. To make a different file (e.g.,'rm'%				 instead of 'jg'), simply change the name of this file. The path to%				 the place where the file is stored is made automatically, and is%				 given the shortcut name 'env'.% July 7, 1998:  JMG added function to make directories. Hopefully will make a%				 compiled version soon to speed things up.% July 14-17 1998: fixed up md command; added short command; added savep and setp commands.% the name of the master file (this file) and it's pathmainfile = [mfilename,'.m'];eval(['mainpath=which(',quotestring(mainfile),');']);mainpath = mainpath(1:end-length(mainfile));% default argumentsdefarg('where','env');if strcmp(where,'..'),	cd ..	prinstr(pwd);	returnend% constants for appending & removing paths, copying files, moving files, and renaming filesapstring = 'ap';rmstring = 'rm';mvstring = 'mv';cpstring = 'cp';rnstring = 'rn';rvstring = 'rv';dlstring = 'dl';mdstring = 'md';shortstring = '?';savepathstring= 'savep';setpathstring = 'setp';firstarg = 1;modify = 0;% check for an initial commandif ~isempty(varargin)		% append shrotcut	if max(size(varargin{firstarg})) == max(size(apstring))			if (varargin{firstarg} == apstring & nargin > 1)			eval([apstring,' ',mainfile,' ',varargin{2}]);			modify = 1;		end		end	% remove shortcut	if max(size(varargin{firstarg})) == max(size(apstring))		if (varargin{firstarg} == rmstring & nargin > 1)			eval([rmstring,' ',mainfile,' ',varargin{2}]);			modify = 1;		end	end	% move file	if max(size(varargin{firstarg})) == max(size(mvstring))		if (varargin{firstarg} == mvstring & nargin > 3)			eval([mvstring,' ',mainfile,' ',varargin{2},' ',varargin{3},' ',varargin{4}]);			modify = 1;		end	end	% copy file	if max(size(varargin{firstarg})) == max(size(cpstring))		if (varargin{firstarg} == cpstring & nargin > 3)			eval([cpstring,' ',mainfile,' ',varargin{2},' ',varargin{3},' ',varargin{4}]);			modify = 1;		end	end	% rename file	if max(size(varargin{firstarg})) == max(size(rnstring))		if (varargin{firstarg} == rnstring & nargin > 3)			eval([rnstring,' ',mainfile,' ',varargin{2},' ',varargin{3},' ',varargin{4}]);			modify = 1;		elseif (varargin{firstarg} == rnstring & nargin > 2)			eval([rnstring,' ',mainfile,' ',varargin{2},' ',varargin{3}]);			modify = 1;				end	end	% reveal a file or folder from the finder	if max(size(varargin{firstarg})) == max(size(rvstring))		if (varargin{firstarg} == rvstring & nargin > 1)			eval([rvstring,' ',mainfile,' ',varargin{2}]);			modify = 1;		elseif varargin{firstarg} == rvstring			eval([rvstring,' ',mainfile]);			modify = 1;				end	end	% delete a file	if max(size(varargin{firstarg})) == max(size(dlstring))		if (varargin{firstarg} == dlstring & nargin > 2)			eval([dlstring,' ',mainfile,' ',varargin{2},' ',varargin{3}]);			modify = 1;		elseif (varargin{firstarg} == dlstring & nargin > 1)			eval([dlstring,' ',mainfile,' ',varargin{2}]);			modify = 1;				end	end	% make a folder (uses applescript; slow)	if max(size(varargin{firstarg})) == max(size(mdstring))		if (varargin{firstarg} == mdstring & nargin > 2)			eval([mdstring,' ',mainfile,' ',varargin{2},' ',varargin{3}]);			modify = 1;		elseif (varargin{firstarg} == mdstring & nargin > 1)			eval([mdstring,' ',mainfile,' ',varargin{2}]);			modify = 1;				end	end	% show shortcuts in command window	if max(size(varargin{firstarg})) == max(size(shortstring))		if (varargin{firstarg} == shortstring & nargin > 1)			eval(['short ',mainfile,' ',mainfile,' ',varargin{2}]);			modify = 1;		elseif varargin{firstarg} == shortstring			eval(['short ',mainfile]);			modify = 1;				end	end	% save a path	if max(size(varargin{firstarg})) == max(size(savepathstring))		if (varargin{firstarg}==savepathstring & nargin > 1)			eval(['savepath ',mainfile,' ',varargin{2}]);			modify = 1;				end	end	% set the path	if max(size(varargin{firstarg})) == max(size(setpathstring))		if (varargin{firstarg} == setpathstring & nargin > 1)			eval(['setpath ',mainfile,' ',varargin{2}]);			modify = 1;				end	end	% interacts with version 5.2	% cf;else	varargin = cell(1);	varargin{firstarg} = 'env';end	% change directoriesif ~modify	for i=firstarg:nargin,		where=varargin{i};			godir=[];				if strcmp(lower(where),'env')			 godir = mainpath;		else			 			switch lower(where)						% **do not change the position of the strings below**			% appended paths			case 'recog', godir = 'Hendrix:MATLAB 5.2.1:jg toolbox:environment:';			case 'zahra', godir = 'Hendrix:Users:zahra:zh:';			case 'consen', godir = 'Renior:Users:Aaron:Matlab Files:ConSenDat:';			case 'cmghome', godir = 'Renior:Users:Carl:';						end			end			% output mulitiple alternatives for ambiguous case		if (isempty(godir)) & (where(end)~=':'),			f=dir([ where '*']);			num=size(f,1);			if num==1,				godir=f.name;			elseif num>1,				for i=1:num,					fprintf(1,'%s\n',f(i).name);				end				return			end		end			% print the deafult path or error message		if isempty(godir),			ok=1;			eval('cd(where)','ok=0;');			if ok,				fprintf(1,'%s\n',pwd);			else				fprintf(1,'No match found.\n');			end		elseif ~exist(godir,'dir'),			fprintf(1,'Not a directory:  %s\n',godir);		else			cd(godir);		end	end	% echo the current path	printstr(pwd);endreturn                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    