function store( obj, varargin )% STORE  Store tagged data%% store( obj, tag1, tag2, ... )%% See also FETCH.% 08-Jun-99 -- created (RFM)global STOREMEMif (nargin==1) & isstr(obj) & (strcmp(lower(obj),'clear')==1),	clear global STOREMEM	returnendif isempty(STOREMEM),	STOREMEM.n=0;endSTOREMEM.n=STOREMEM.n+1;STOREMEM.list{STOREMEM.n}.id=varargin;STOREMEM.list{STOREMEM.n}.obj=obj;return