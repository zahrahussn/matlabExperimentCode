function theImage=grating(nr,f,c,p,o);% this function is begin phase out... call pbGrating instead% theImage=grating(numrows,freq, contrast, phase,orientation);% Returns a sine wave grating. The grating is specified by% frequency (c/image), contrast, phase (deg), and orientation (deg). The phase is defined% relative to the center of the pattern. Horizontal and vertical correspond to 0 deg% and 90 deg, respectively (e.g., positive orientations are counterclockwise rotations% from horizontal).% first, create an x,y grid that spans from -0.5 to +0.5theImage=pbGrating(nr,f,c,p,o);%nc=nr;%[x,y]=meshgrid(0:(nc-1),0:(nr-1));%x=x./nc; x=x-0.5;%y=y./nr; y=y-0.5;%%% now, draw the grating%p=p*pi/180;%angle=o*pi/180;%f=f*2*pi;%a=sin(angle)*f;%b=cos(angle)*f;%theImage=c*cos((a*x)+(b*y)-p);%%return;