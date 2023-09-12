function y = genexp( x, varargin )% GENEXP  Generalized exponential% 04/05/98 - created (RFM)if nargin==2,	p=varargin{1};elseif nargin==5,	p=[ varargin{1} varargin{2} varargin{3} varargin{4} ];else	error('Invalid number of arguments');endy=p(1)+p(2)*exp(p(3)*(x-p(4)));return