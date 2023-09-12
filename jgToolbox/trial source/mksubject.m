function subject = mksubject( type, threshlev, threshval, spread )% MKSUBJECT  Initialize a Bernoulli model of a subject in a 2AFC task.%% subject = mksubject( type, threshlev, threshval, spread )% 28-Jan-98 -- created (RFM)% set psychometric function typeif (~strcmp(type,'norm')) & (~strcmp(type,'weibull')),	error(sprintf('Invalid subject type ''%s''',type));endsubject.type=type;% set parameters directlyif nargin==2,	subject.p1=threshlev(1);	subject.p2=threshlev(2);% set parameters from thresholdelse	if strcmp(subject.type,'norm'),		subject.p1=threshval-norminv(2*(threshlev-0.5),0,spread);	else		weiberr=inline(sprintf('( %f - weibullcdf( %f , x , %f ))^2', ...			2*(threshlev-0.5),threshval,spread));		subject.p1=fmin(weiberr,0,10*threshval);	end	subject.p2=spread;end% make inline psychometric functionsubject.psymet=inline(sprintf('0.5+0.5*%scdf(x,%f,%f)',subject.type,subject.p1,subject.p2));return