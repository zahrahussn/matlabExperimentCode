function b = isdone( src )% ISDONE  Flags whether a UDTR trial source has expired%% b = isdone( src )%% 0 = not expired, 1 = expired% 04-Oct-99 -- created at PJB's suggestion (RFM)b=(src.nreversals>=src.maxreversals);return