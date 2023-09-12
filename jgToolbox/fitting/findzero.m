function [ x0, i ] = findzero( fn, params, initlow, inithigh, tolerance )% FINDZERO  Find zero of a monotone decreasing function%% [ x0, i ] = findzero( fn, params, initlow, inithigh, tolerance )% 07-Sep-98 -- created (RFM)% set default argumentsdefarg('params',{});defarg('initlow',1);defarg('inithigh',100000000);defarg('tolerance',0.001);% set initial boundsL=initlow;H=inithigh;i=[ 0 0 0 ];% get lower boundwhile fn(L,params{:})<0,	L=L/2;	i(1)=i(1)+1;end% get higher x-value with y-value less than zerowhile fn(H,params{:})>0,	H=H*2;	i(2)=i(2)+1;end% find x-value with y-value within tolerance of zerofL=fn(L,params{:});fH=fn(H,params{:});while 1,	% interpolate linearly	M=L-fL*(H-L)/(fH-fL);	fM=fn(M,params{:});	if abs(fM)<tolerance,		break	elseif fM>0,		L=M;		fL=fM;	else		H=M;		fH=fM;	end	i(3)=i(3)+1;endx0=M;return