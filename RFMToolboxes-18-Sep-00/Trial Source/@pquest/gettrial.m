function [ newsrc, level, id ] = gettrial( src )% GETTRIAL  Poll a pquest trial source%% [ newsrc, level, id ] = gettrial( src )% 28-Jan-98 -- created (RFM)% 27-Sep-98 -- made object-oriented (RFM)id=src.id;if isdone(src),	level=NaN;else	src.trial=src.trial+1;	level=10^questmean(src.q);endnewsrc=src;return