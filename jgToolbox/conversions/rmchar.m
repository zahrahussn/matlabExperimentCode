function t = rmchar(s,c)% function rmchar(s,c)%% removes the character in C from the string S% % March 18 2000  JMGt = s(find(s~=c));return;