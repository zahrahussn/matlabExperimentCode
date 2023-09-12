function pressed = wait( validkeys, mouseflag )% WAIT  Wait for user input%% pressed = wait( validkeys, mouseflag )% set default argumentsdefarg('validkeys',Inf);defarg('mouseflag',1);% set keyboard flagkeyflag=~isempty(validkeys);% check whether anything is being waited forif (~keyflag) & (~mouseflag),	error('Neither keyboard nor mouse input is flagged.');end% wait for an inputwhile 1,	% keyboard	if keyflag & charavail,		key=getchar;		if isinf(validkeys) | strchr(validkeys,key),			pressed=key;			break		end	end	% mouse	if mouseflag,		[ x y button ] = getmouse;		if button,			pressed='mouse';			break		end	endendreturn