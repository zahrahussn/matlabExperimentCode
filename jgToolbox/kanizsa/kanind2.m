function kmat = kanind2( radiusP, alpha, ringp )% KANIND2  Make a Kanisza inducer%% kmat = kanind2 ( radiusP, alpha, ringp )% 02-Jun-99 -- created (RFM)% set default parametersdefarg('radiusP',50);defarg('alpha',0);defarg('ringp',1);% make coordinate matrixN=radiusP;v=ones(2*N+1,1)*(-N:N);xy=v+sqrt(-1)*rot90(v,1);xy=xy*exp(-sqrt(-1)*deg2rad(alpha));% initialize image matrixkmat=zeros(size(xy));% draw circlekmat(find(abs(xy)<=(radiusP+0.5)))=1;f=find((abs(xy)>(radiusP-0.5))&(abs(xy)<(radiusP+0.5)));kmat(f)=1-(abs(xy(f))-(radiusP-0.5));% clip circlekmat(find( (real(xy)>=-1) & (imag(xy)<=1) & (abs(xy)<=(ringp*(radiusP+0.5))) ))=0;% add vertical rampf=find( (real(xy)>=-1) & (real(xy)<=1) );kmat(f)=max(kmat(f),0.5-0.5*(real(xy(f))));% add horizontal rampf=find( (imag(xy)>=-1) & (imag(xy)<=1) );kmat(f)=max(kmat(f),0.5+0.5*(imag(xy(f))));return