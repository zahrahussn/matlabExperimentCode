function mat = circ2daa_2( radiusP, ramplen, n, centreij )% CIRCD2DAA  Make an anti-aliased circle matrix%% mat = circ2daa( radiusP, ramplen, n, centreij )% 18-Oct-99 -- created;  adapted from kanind.m (RFM)% set default parametersdefarg('radiusP',50);defarg('ramplen',1);defarg('n',2*radiusP+1+ramplen);defarg('centreij',(floor(n/2)+1)*[ 1 1 ]);% initialize image and get coordinate matricesmat=ones(n);[i,j]=matij(mat,centreij);r=sqrt(i.^2+j.^2);% draw anti-aliased circlemat(find(r<=(radiusP-(ramplen/2))))=0; if ramplen>0, 	f=find((r>(radiusP-(ramplen/2)))&(r<=(radiusP+(ramplen/2)))); 	mat(f)=0.5+0.5*(1/(ramplen/2))*(r(f)-radiusP); endreturn