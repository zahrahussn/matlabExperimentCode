function intticks( varargin )% INTTICKS  Use integer ticks along a graph axis% check for argumentsif nargin==0,	error('No arguments');end% use integer ticks on each axis specifiedfor i=1:nargin,	ax=upper(varargin{i});	lim = get(gca,sprintf('%sLim',ax));	set(gca,sprintf('%sTick',ax),floor(lim(1)):ceil(lim(2)));endreturn