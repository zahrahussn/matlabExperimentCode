function [reel] = mkphzmovie1d(durationms,framert,sz,cpi,cps,deg,svar)defarg('durationms',500);defarg('framert',67);defarg('sz',64);defarg('cpi',6);defarg('cpw',3);defarg('cps',2);defarg('deg',0);defarg('svar',.01);% calculate phase anglesframes = round(framert*(durationms/1000));phz = linspace(0,360*cps*(durationms/1000),frames);for i = 1:frames	%reel(:,:,i) = scalearb(dogabor(cpi,cpw,sz,deg,phz(i)),-1,1);	reel(:,:,i) = scalearb(dosinimage(cpi,sz,deg,phz(i)),-1,1);	reel(:,:,i) = reel(:,:,i)*sqrt(svar/stdm(reel(:,:,i))^2);endreturn