function r = z( p )% Z  Inverse cumulative normal with mean=0.0, std=1.0 (as used in SDT)%% r = z( p )% 05-Oct-98 -- created (RFM)r=norminv(p,0,1);return