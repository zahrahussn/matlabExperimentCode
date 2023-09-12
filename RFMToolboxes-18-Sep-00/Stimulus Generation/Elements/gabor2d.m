function g = gabor2d( lambda, theta, phi, sigma, N )% GABOR2D  Generate a 2D Gabor patch%% g = gabor2d( lambda, theta, phi, sigma, N )% 02-Jul-98 -- created (RFM)defarg('theta',0);defarg('phi',0);defarg('sigma',lambda);defarg('N',6*sigma);sine=sine2d(N,lambda,theta,phi,0,1);gauss=gauss2d(N,sigma);gauss=gauss/max(max(gauss));g=sine.*gauss;return