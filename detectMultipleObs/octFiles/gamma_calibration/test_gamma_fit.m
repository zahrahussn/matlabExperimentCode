gFunc = @(g,p)(p.^g(1));
val	= linspace(0,1,9);
lum = [0.3588,2.031,6.791,15.31,28,45.37,67.68,95.57,128.9];
lumNorm = lum - lum(1);
lumNorm = lumNorm/max(lumNorm(:));
gInit = 2.0;
[gammaEst,R,J,covb,mse] = nlinfit(val,lumNorm,gFunc,gInit);
gammaEst



