function theImage=randchecks(nr,numdots,c,b);%%%	if (nr<1)		disp('illegal value for # rows!');	end;	if (numdots<1)		disp('illegal value for # of dots!');	end;	nc=nr;	theImage=b+zeros(nr,nc);	numpoints=nr*nc;	[xloc,yloc]=randcoords(nr,nc,numdots);	dotloc=xy21d(xloc,yloc,nc);	%dotloc=1+floor(numpoints*rand(1,numdots));	thedots=c+zeros(1,numdots);	theImage(dotloc)=thedots;	xloc=xloc+4;	xloc=1+mod(xloc,nc);	yloc=yloc+4;	yloc=1+mod(yloc,nr);	dotloc=xy21d(xloc,yloc,nc);	theImage(dotloc)=theImage(dotloc)+thedots;		return;		