function [latency]=flickergabor(nr,f,c,p,o,b,vblframes,theClut);%%%% make movie	t0=GetSecs; t1=GetSecs;	 % Initialize GetSecs and allocate memory for t0 & t1  	[window,wrect]=SCREEN(0,'OpenWindow',127);	nc=nr;	stimrect=SetRect(0,0,nc,nr);	%  newRect = SetRect(left,top,right,bottom);	destrect=stimrect;	destrect=CenterRect(destrect,wrect);	numstim=2;	for k0=1:numstim  		offscreen(k0)=SCREEN(window,'OpenOffscreenWindow',0,stimrect); % allocate memory for offscreen windows		temp=gabor(nr,f,c,p,o,b);		if (k0==2)			temp=temp.*-1;		end;		% temp=pixelimage(temp,m);		temp=round(127*temp+127);		SCREEN(offscreen(k0),'PutImage',temp);	end;	err=SCREEN(window,'SetClut',theClut);	oldval=screen(window,'Preference','WaitForVBLInterrupt',1);	GetSecs(t0);	alldone=0;	stim=1;	numframes=1;	if (vblframes<1) vblframes=1; end;	if (vblframes>100) vblframes=100; end;	while (alldone==0)  		SCREEN('CopyWindow',offscreen(1),window,stimrect,destrect);  		SCREEN(window,'WaitVBL',vblframes); 		SCREEN('CopyWindow',offscreen(2),window,stimrect,destrect);  		SCREEN(window,'WaitVBL',vblframes);		[alldone,t1]=KbCheck;	end;	latency=t1-t0;  	SCREEN('CloseAll'); return;%	loop1 = 'while (alldone==0);';%	loop2='SCREEN(''CopyWindow'',offscreen(stim),window,stimrect,destrect);';%	loop3='numframes=numframes+1;stim=mod(numframes,numstim)+1;SCREEN(window,''WaitVBL'',5);[alldone,t1]=KbCheck;end';%	loop=[loop1,loop2,loop3];%	Rush(loop,7);%	latency=t1-t0;% 	SCREEN('CloseAll');%	return;