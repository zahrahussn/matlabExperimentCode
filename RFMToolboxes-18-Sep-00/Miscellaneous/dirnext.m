function f = dirnext( filter )% DIRNEXT  Step through files in a directory%% f = dirnext( filter )% 29-Oct-99 -- created (RFM)global DIR% start new listif nargin>=1,	DIR.filelist=dir(filter);	DIR.filei=0;end% get next file on listif DIR.filei>=size(DIR.filelist,1),	f='';else	DIR.filei=DIR.filei+1;	f=DIR.filelist(DIR.filei).name;endreturn