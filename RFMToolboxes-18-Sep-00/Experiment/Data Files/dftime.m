function tlist = dftime( fname )% DFTIME  Print or return times of sessions in a datafile%% tlist = dftime( fname )% 17-May-99 -- created (RFM)% read filed=dfread(fname);n=size(d,2);% step through sessionsfor i=1:n,	eval(d{i}.cmd);	if nargout==0,		fprintf(1,'%s\n',TIME);	else		t{i}=TIME;	endendreturn