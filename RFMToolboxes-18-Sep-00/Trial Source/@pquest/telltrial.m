function newsrc = telltrial( src, level, success )% TELLTRIAL  Report result of a trial to a pquest trial source%% newsrc = telltrial( src, level, success )% 28-Jan-98 -- created (RFM)% 27-Sep-98 -- made object-oriented (RFM)src.q=questupdate(src.q,log10(level),success);if questsd(src.q)<src.finalsd,	src.final=10^questmean(src.q);endnewsrc=src;return