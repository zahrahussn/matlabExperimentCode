function kmat = kanind( radiusP, alpha, ringp )% KANIND  Make a Kanisza inducer%% kmat = kanind ( radiusP, alpha, ringp )% 02-Jun-99 -- created (RFM)% 22-Sep-99 -- length of ramp made into an internal variable, <ramplen>;%              size of ramp maintained at [ -1, 1 ] (RFM)% 22-Sep-99 -- error fixed:  (abs(xy)<=((1-ringp)*(radiusP+0.5)) term was not%              used in quadrant clipping before today (RFM)% set default parametersdefarg('radiusP',50);defarg('alpha',30);defarg('ringp',.1);% make coordinate matrixN=radiusP;v=ones(2*N+1,1)*(-N:N);xy=v+sqrt(-1)*rot90(v,1);xy=xy*exp(-sqrt(-1)*deg2rad(alpha));% initialize image matrixkmat=zeros(size(xy));% draw anti-aliased circlekmat(find(abs(xy)<=(radiusP-0.5)))=1;f=find((abs(xy)>(radiusP-0.5))&(abs(xy)<(radiusP+0.5)));kmat(f)=1-(abs(xy(f))-(radiusP-0.5));ramplen=1;% clip fourth quadrant out of circleb=(1-ringp)*(radiusP+0.5);q=(real(xy)>=-ramplen) & (imag(xy)<=ramplen) & (abs(xy)<=b);kmat(find( q ))=0;% (radiusP+0.5) is a small kludge;  should be radiusPif ringp>0,	f=find( q & (abs(xy)>=b-1) );	kmat(f)=0.5+0.5*(abs(xy(f))-(b-0.5));end% add vertical rampf=find( (real(xy)>=-ramplen) & (real(xy)<=ramplen) & (abs(xy)<(radiusP-0.5)) );kmat(f)=max( kmat(f), 0.5-(0.5*real(xy(f))/ramplen) );% add horizontal rampf=find( (imag(xy)>=-ramplen) & (imag(xy)<=ramplen) & (abs(xy)<(radiusP-0.5)) );kmat(f)=max( kmat(f), 0.5+(0.5*imag(xy(f))/ramplen) );return