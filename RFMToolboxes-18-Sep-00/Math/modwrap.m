function y = modwrap( x, mmin, mmax )% MODWRAP  Modulus%% y = modwrap( x, mmin, mmax )% 09-Feb-99 -- created (RFM)y=mod(x-mmin,mmax-mmin+1)+mmin;return