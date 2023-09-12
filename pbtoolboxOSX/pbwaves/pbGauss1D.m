function gw=pbGauss1D(n,b,c);
%
% gw=pbGauss1D(n,b[,c]);
% Returns a 1D gaussian.
% n: number of rows (assumes the matrix is square; default == 128)
% b: parameter for gaussian's width (default == 1)
% c: offset of gaussian's center (default == round(n/2))
%
% Pattern is written to a 1D array with a coordinate system that goes from -0.5 to +0.5, with
% location <0,0> corresponding to the 0. The center of the
% matrix is location p = c or p=round(n/2)+1.
% The Gaussian is defined as Gauss(x) = exp(-pi*(x/(0.5*b))^2).
% The parameter b specifies the width, in image units, between the points at which the gaussian
% is 0.043. For example, if you want a gassian that drops to 0.043 at x values
% that are ±0.5 image units from the image's center, then you should pass a b value of 1.
%

defarg('n',128);
defarg('b',1);


b=b/2;	% we divide b by 2 because the matrix goes from -0.5 to +0.5, not -1 to +1
x=0:(n-1);
x=x./n;
x=x-0.5;
gw=exp(-pi*(x./b).^2);

return;
