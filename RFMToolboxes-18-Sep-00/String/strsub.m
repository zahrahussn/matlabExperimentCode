function newstr = strsub( str, oldchar, newchar )% STRSUB  Substitute one character for another in a string%% newstr = strsub( str, oldchar, newchar )% 08-Mar-99 -- created (RFM)newstr=str;newstr(find(newstr==oldchar))=newchar;return