function [variance,pixarea] = nsd2var(density,screensz,res,vd)% function [variance,pixarea] = nsd2var(density,screensz,res,vd)%% computes the contrast variance of a gaussian noise of a given% spectral density and size.%% parameters:%% density-    the spectral density the noise field% screensz-   a 2 element vector containing the width and %			  height of the screen, respectievely, in cm. %			  (i.e., [width height]).% res-		  a 2 element vector containing the width and %			  height of the screen, respectievely, in pixels. %			  (i.e., [width height]).% vd-		  the viewing distance, in cm.%% output:%% variance-    the spectral density of the noise, in degrees^2.% pixarea-    the area of a single pixel, in degrees^2.if nargin == 4		pixarea = (visang(vd,pix2cm(1,screensz,res)))^2;	%density = variance/(1/pixarea);	variance = density/pixarea;else	error('not enough parameters sent.');endreturn;