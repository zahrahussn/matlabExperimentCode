function p = psymetweibull( x, alpha, beta, pmin, pmax )% PSYMETWEIBULL  Psychometric function base on modified Weibull cdf%% p = psymetweibull( x, alpha, beta, pmin, pmax )% 28/04/98 - created (RFM)defarg('pmin',0.5);defarg('pmax',1.0);p = pmin+(pmax-pmin)*weibullcdf(x,alpha,beta);return