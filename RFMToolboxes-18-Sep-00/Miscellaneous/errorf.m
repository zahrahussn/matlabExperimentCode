function errorf( format, varargin )% ERRORF  Error message, formatted like sprintf%% errorf( format, arg1, ... )% 02-Jul-98 -- created (RFM)feval('error',sprintf(format,varargin{:}));return