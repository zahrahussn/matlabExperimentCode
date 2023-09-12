function defarg( arg, val )% DEFARG  Assign a default value to an argument.%% defarg( arg, val )%     - <arg> is the string name of the argument%     - <val> is the value to be assigned to <arg> if it doesn't exist%% e.g., defarg( 'arg1', -1 )%       defarg( 'arg2', 'none' )% 18-Feb-98 -- created (RFM)% 20-Feb-98 -- added ability to handle fields of structures (RFM)% 10-Dec-98 -- replaced evalin with assignin, at suggestion of CPT (RFM)% This could be cleaned up a lot.p=strchr(arg,'.');if p==0,	if evalin('caller',sprintf('exist(''%s'',''var'')',arg))==0,		assignin('caller',arg,val);	endelse	f1=arg(1:p-1);	f2=arg(p+1:end);	baseexists=evalin('caller',sprintf('exist(''%s'',''var'')',f1));	if baseexists,		fieldexists=evalin('caller',sprintf('isfield(%s,''%s'')',f1,f2));	else		fieldexists=0;	end	if ~( baseexists & fieldexists ),		if ischar(val),			evalin('caller',sprintf('%s=''%s'';',arg,val));		else			evalin('caller',sprintf('%s=%f;',arg,val));		end	endendreturn% STRCHR  Find first occurrence of a character in a stringfunction pos = strchr( str, chr )p=find(str==chr(1));if isempty(p),	pos=0;else	pos=p(1);endreturn