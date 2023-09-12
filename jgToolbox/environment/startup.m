function startup()% jg local;% % if 0 % %jg setp marr;% % adds main environment path for JG.% jgloc = 'Ernst:Applications (Mac OS 9):MATLAB 5.2.1:Toolbox:JMG:jg toolbox:Environment:';% p = path;% if isempty(findstr(p,jgloc))% 	path(path,jgloc);% 	%disp(['added to path:  ''',jgloc,'''.']);% end% % dopath = input('set jg path <ernst>? (y/n; default y)  ','s');% if ~strcmp(lower(dopath),'n')% 	eval(['jg setp ernst;']);% end% endtime = clock;
% Call Psychtoolbox-3 specific startup function:
if exist('PsychStartup'), PsychStartup; end;

