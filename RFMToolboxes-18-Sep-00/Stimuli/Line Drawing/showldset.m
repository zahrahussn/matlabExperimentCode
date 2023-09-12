function showldset( figset )% SHOWLDSET  Show a line drawing set%% showldset( figset )% 08-Jun-99 -- created;  adapted from tpshow.m (RFM)% set default argumentsdefarg('figset','a');% stimulus characteristicsviewdistanceM=0.57;       % viewing distancebglum=20;                 % background luminancefiglum=40;                % figure luminancefigsizeD=10.0;            % figure sizefigthickD=0.1;            % figure line thickness% configure stimulus generation librarysetconfig('viewdistance',viewdistanceM);setconfig('bgcind',0);setconfig('fgcind',128);% calculate derived stimulus characteristicsfigsizeP=deg2pixel(figsizeD);figthickP=deg2pixel(figthickD,0);framesizeP=ceil(1.4*sqrt(2)*figsizeP);% load figure set from diskfiglist=readldset(figset);fign=size(figlist,2);% load key codesload keys% open stimulus windowhidecursor;[ winID, winRect ]=openwin(bglum);figcind=lum2cind(figlum);screen(winID,'TextSize',20);% create moviereel=initmovie( winID, 2, framesizeP*[ 1 1 ] );screen(reel.frameID(1),'DrawLine',0,1,1,2,2);   % required;  don't ask why% show stimulifignum=1;theta=0;while 1,	% draw and show stimulus	drawld(reel.frameID(1),figlist{fignum},figsizeP,figthickP,theta,figcind);	cls(winID);	playframes( reel, 1, 1 );	screen(winID,'DrawText',sprintf('Figure %d  (theta=%d)',fignum,theta),20,30,figcind);	% get key	oldfignum=fignum;	key=getvalidkey([ KEY_UPARROW KEY_DOWNARROW KEY_LEFTARROW KEY_RIGHTARROW 'q' ]);	switch key,		case KEY_UPARROW,     fignum=max(fignum-1,1);		case KEY_DOWNARROW,   fignum=min(fignum+1,fign);		case KEY_LEFTARROW,   theta=degmod(theta+10);		case KEY_RIGHTARROW,  theta=degmod(theta-10);		case 'q', break;	end	if fignum~=oldfignum,		theta=0;	endend% shut downscreen('CloseAll');showcursor;return