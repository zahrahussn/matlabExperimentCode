function [oldtype,oldcreator] = filetype(filename,type,creator)% FILETYPE  Get and change file type and creator of a Macintosh file.%%   [OLDTYPE,OLDCREATOR] = FILETYPE(FILENAME,TYPE,CREATOR) gets the Macintosh%         file type and creator of the FILENAME, and changes them to TYPE and%         CREATOR (if supplied and not empty).  FILENAME may be a string or a%         string matrix (in which case each row is DEBLANK'ed and used as a%         filename).%%   The number of rows in TYPE and CREATOR, if supplied and not empty, must%   be one or the same as the number of rows in FILENAME.%% Copyright (c)1995-97, Erik A. Johnson <johnsone@uiuc.edu>, 3/23/97% Included in the Psychophysics Toolbox with permission of the author.