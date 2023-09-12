function [x0,y0] = fplot(fun,lims,arg3,arg4,arg5)%FPLOT  Plot function.%   FPLOT(FUN,LIMS) plots the function specified by the string FUN%   between the x-axis limits specified by LIMS = [XMIN XMAX].  Using%   LIMS = [XMIN XMAX YMIN YMAX] also controls the y-axis limits.  FUN%   must be the name of an M-file function or a string with variable x%   that may be passed to EVAL, such as 'sin(x)', 'diric(x,10)' or%   '[sin(x),cos(x)]'.  The function FUN(x) must return a row vector for%   each element of vector x.  For example, if FUN returns%   [f1(x),f2(x),f3(x)] then for input [x1;x2] the function should%   return the matrix%%       f1(x1) f2(x1) f3(x1)%       f1(x2) f2(x2) f3(x2)%   %   FPLOT(FUN,LIMS,TOL) with TOL < 1 specifies the relative error%   tolerance. The default TOL is 2e-3, i.e. 0.2 percent accuracy.%   FPLOT(FUN,LIMS,N) with N >= 1 plots the function with a minimum of%   N+1 points.  The default N is 1.  The maximum step size is%   restricted to be (1/N)*(XMAX-XMIN).%   FPLOT(FUN,LIMS,'LineSpec') plots with the given line specification.%   FPLOT(FUN,LIMS,...) accepts combinations of the optional arguments%   TOL, N, and 'LineSpec', in any order.%   %   [X,Y] = FPLOT(FUN,LIMS,...) returns X and Y such that Y = FUN(X).%   No plot is drawn on the screen.%%   Examples:%       subplot(2,2,1), fplot('humps',[0 1])%       subplot(2,2,2), fplot('abs(exp(-j*x*(0:9))*ones(10,1))',[0 2*pi])%       subplot(2,2,3), fplot('[tan(x),sin(x),cos(x)]',2*pi*[-1 1 -1 1])%       subplot(2,2,4), fplot('sin(1 ./ x)', [0.01 0.1],1e-3)%%   The FPLOT function begins with a minimum step of size (XMAX-XMIN)*TOL.%   The step size is subsequently doubled whenever the relative error%   between the linearly predicted value and the actual function value is%   less than TOL.  The maximum number of x steps is (1/TOL)+1.%% MODIFIED VERSION% Handle to plot is returned when one return argument is requested. (RFM)%   Mark W. Reichelt 6-2-93%   Copyright (c) 1984-97 by The MathWorks, Inc.%   $Revision: 5.8 $  $Date: 1997/04/08 06:45:59 $error(nargchk(2,5,nargin));if isstr(fun) & any(fun<48), fun = inline(fun); endmarker = '-';tol = 2e-3;N = 1;if nargin >= 3  if isstr(arg3)    marker = arg3;  elseif arg3 < 1    tol = arg3;  else    N = arg3;  endendif nargin >= 4  if isstr(arg4)    marker = arg4;  elseif arg4 < 1    tol = arg4;  else    N = arg4;  endendif nargin == 5  if isstr(arg5)    marker = arg5;  elseif arg5 < 1    tol = arg5;  else    N = arg5;  endend% compute the x duration and minimum and maximum x stepxmin = min(lims(1:2)); xmax = max(lims(1:2));maxstep = (xmax - xmin) / N;minstep = min(maxstep,(xmax - xmin) * tol);tri= minstep;% compute the first two pointsx = xmin; y = feval(fun,x);xx = x;x = xmin+minstep; y(2,:) = feval(fun,x);xx(2) = x;% compute a constant ytol if y limits are givenif length(lims) == 4  ymin = min(lims(3:4)); ymax = max(lims(3:4));  ylims = 1;else  J = find(isfinite(y));  if isempty(J)    ymin = 0; ymax = 0;  else    ymin = min(y(J)); ymax = max(y(J));  end  ylims = 0;endytol = (ymax - ymin) * tol;I = 2;while xx(I) < xmax  I = I+1;  tri = min(maxstep,min(2*tri, xmax-xx(I-1)));  x = xx(I-1) + tri;  y(I,:) = feval(fun,x);  ylin = y(I-1,:) + (x-xx(I-1)) * (y(I-1,:)-y(I-2,:)) / (xx(I-1)-xx(I-2));  while any(abs(y(I,:) - ylin) > ytol) & (tri> minstep)    tri= max(minstep,0.5*tri);    x = xx(I-1) + tri;    y(I,:) = feval(fun,x);    ylin = y(I-1,:) + (x-xx(I-1)) * (y(I-1,:)-y(I-2,:)) / (xx(I-1)-xx(I-2));  end  if ~ylims    J = find(isfinite(y(I,:)));    if ~isempty(J)      ymin = min(ymin,min(y(I,J))); ymax = max(ymax,max(y(I,J)));      ytol = (ymax - ymin) * tol;    end  end  xx(I) = x;end%if nargout == 0%  plot(xx,y,marker)% Following two lines substituted so that handle to plot is returned.% 23-Apr-98 - RFMif nargout<2,  x0=plot(xx,y,marker);  set(gca,'XLim',[xmin xmax]);  if ylims    set(gca,'YLim',[ymin ymax]);  endelse  x0 = xx.'; y0 = y;end