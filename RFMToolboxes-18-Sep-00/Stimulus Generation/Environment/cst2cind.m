function cind = cst2cind( cst )% CST2CIND  Convert Weber contrasts to clut indices%% cind = cst2cind( cst )% 11-Nov-99 -- created (RFM)global CLUTcind=1+round( 255*(CLUT.bglum*(1+cst)-CLUT.minlum)/(CLUT.maxlum-CLUT.minlum) );return