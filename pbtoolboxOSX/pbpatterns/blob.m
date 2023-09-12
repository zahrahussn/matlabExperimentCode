function theImage=blob(nr,bx,by,o,dx,dy);
%
% function theImage=blob(nr,bx,by,o,dx,dy);
% Returns a 2D gaussian blob
% nr: number of rows (assumes the matrix is square; default == 128)
% bx: parameter for gaussian's width in the x direction (default == 1)
% by: parameter for gaussian's width in the y direction (default == 1)
% o: pattern orientation. Horizontal and vertical correspond to 0 deg and 90 deg, respectively
% (e.g., positive orientations are counterclockwise rotations from horizontal).
%
% Pattern is written to a square 2D matrix with a coordinate system that goes from -0.5 to +0.5, with
% location <0,0> corresponding to the center of the matrix. The center of the
% matrix is location <p1,p2>, where p1 = round(nr/2)+1 and p2 = round(nr/2)+1.
% The 1D Gaussian is defined as Gauss(x) = exp(-pi*(x/b)^2).
% The parameter b specifies the width, in image units, between the points at which the gaussian
% is 0.043. For example, if you want a gassian that drops to 0.043 at x values
% that are ±0.5 image units from the image's center, then you should pass a b value of 1.
%

% first, create an x,y grid that spans from -0.5 to +0.5

defarg('nr',256);
defarg('bx',1);
defarg('by',1);
defarg('o',0);
defarg('dx',0);
defarg('dy',0);
nc=nr;
[x,y]=meshgrid(0:(nc-1),0:(nr-1));
x=x./nc; x=x-0.5; x=x-dx;
y=y./nr; y=y-0.5; y=y-dy;

% now, draw the blob
bx=bx/2;	% we divide b by 2 because the matrix goes from -0.5 to +0.5, not -1 to +1
by=by/2;	% we divide b by 2 because the matrix goes from -0.5 to +0.5, not -1 to +1

angle=-o*pi/180;
nx=x*cos(angle)+y*sin(angle);
ny=-x*sin(angle)+y*cos(angle);

theImage=exp(-pi*(nx./bx).^2).*exp(-pi*(ny./by).^2);
return;
