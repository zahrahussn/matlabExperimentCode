function del(file)% function del(file)%% Shortcut for 'delete'.% if no arguments are passed,% a dialog box appears that prompts % user to choose a file.if nargin == 0	[file,folder] = uigetfile('*.*','Delete File');	if file		delete([folder,file]);	end	else	delete(file);endreturn;