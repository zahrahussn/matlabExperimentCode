function ld = readldset( ldset )% READLDSET  Read a line drawing set%% ld = readldset( ldset )% 08-Jun-99 -- created;  adapted from readtpfig.m% change directory, if requested[p,n,e]=fileparts(ldset);if ~isempty(p),	oldwd=pwd;	cd(p);end% read line drawingsi=1;while 1,	fname=sprintf('%s%d.txt',n,i);	if ~fileexist(fname),		break	end	ld{i}=dfread(fname,0,0);	i=i+1;end% return to initial directoryif ~isempty(p),	cd(oldwd);end% d=pwd;% cd('Goldie:Users:RFM Home:Line Drawing Toolbox:Drawings:');% for i=1:7,% 	fig{i}=dfread(sprintf('%s%d.txt',figset,i),0,0);% end% cd(d);return