function fitp = fit( fitfn, data, init, method, options )% FIT  Fit parameters of a function to data%% fitp = fit( fitfn, data, init, method, options )% 23-Apr-98 - created (RFM)% set default argumentsdefarg('method','ss');defarg('options','');% check size of data matrix;  transpose if necessary% s=size(data);% if s(2)~=2,% 	if s(1)==2,% 		data=data';% 	else% %		error('Data matrix size must be 2xn or nx2');% 	end% end% switch order of arguments in fitting functionargs=argnames(fitfn);switchfn=inline(formula(fitfn),args{2},args{1});switch method,	% minimize sum-of-squares error	case 'ss',		% construct and minimize sum-of-squares error function		errfn=inline(sprintf('sum( ( (%s) - (yval) ).^2 )',formula(switchfn)),args{2},args{1},'yval');		fitp = fmins(errfn,init,options,[],data(:,1),data(:,2));			% minimize weighted sum-of-squares error	% *** is this correct? ***	case 'wss',		% construct and minimize weighted sum-of-squares error function		errfn=inline(sprintf('sum( ( ( (%s) - (yval) )./se ).^2 )',formula(switchfn)),args{2},args{1},'yval','se');		fitp = fmins(errfn,init,options,[],data(:,1),data(:,2),data(:,3));			% maximum-likelihood fit	case 'ml',		% construct and minimize negative log likelihood error function		errfn=inline(sprintf('-sum(log( %s ))',formula(switchfn)),args{2},args{1});		fitp = fmins(errfn,init,options,[],data);			otherwise,		error(sprintf('Invalid method ''%s''',method));		endreturn