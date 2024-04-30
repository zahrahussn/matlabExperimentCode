% fits logistic psychometric function to motion direction discrimination data
% obtained using Motion/BaselineTask.py, and returns threshold at given performance (e.g. 99%)
% Motion discrimination is assumed to be between up (90) and down (270)
% logistic function is fitted to an down/up motion response function spanning the two opposite direction

function [thresholdUp,thresholdDown,fit] = motionPsymetLogistic(fileName,fitBias,fitLapse)

if ~exist('fileName','var') || isempty(fileName)
  fileName = "aa_pilot1_baseline.csv";
end
if ~exist('fitBias','var') || isempty(fitBias)
  fitBias = false; % assume that there is no bias
end
if ~exist('fitLapse','var') || isempty(fitLapse)
  fitLapse = true; % assume that there is no bias
end

thresholdPerf = 0.9;

dat = readtable(fileName);
trials = [dat.coherence dat.accuracy dat.direction];

% make a motion response function spanning the two opposite directions
trials(trials(:,3)==270,1) = -trials(trials(:,3)==270,1); % coherence for "down" trials is negative 
trials(trials(:,3)==270,2) = 1-trials(trials(:,3)==270,2); % convert accuracy to probability of responding "up"

scaledLogistic = @(x,p) p(3)/2 +  (1-p(3)) * 1./(1+exp(-(p(1) + p(2)*x)));

invLogistic = @(y,p) (-p(1) - log(1./y - 1))/p(2);

% derivation  of the inverse logistic function
% logistic = @(x,p) 1./ ( 1+ exp (-(p(1) + p(2)*x)));
% y = 1./ ( 1+ exp (-(p(1) + p(2)*x)))
% 1./y = 1+ exp (-(p(1) + p(2)*x))
% 1./y - 1 = exp (-(p(1) + p(2)*x))
% log(1./y - 1) = -(p(1) + p(2)*x)
% log(1./y - 1) = -p(1) - p(2)*x
% p(2)*x = -p(1) - log(1./y - 1)
% x = (-p(1) - log(1./y - 1))/p(2)

% fit psychometric curve using maximum likelihood
fiterr = @(p) -sum(log( scaledLogistic( trials(trials(:,2)==1,1), p ) )) -sum(log(1 - scaledLogistic( trials(trials(:,2)==0,1), p)));

opt=optimset('Display','off', 'TolX',0.0001,'TolFun',0.000001, 'MaxFunEvals',1000);

lowerbound = [0 -inf 0];
upperbound = [0 inf 0];
if fitBias
  lowerbound(1) = -1;
  upperbound(1) = 1;
end
if fitLapse
  upperbound(3) = 1;
end

init = [ mean(trials(:,1).*(trials(:,2)))*5, 5, 0]; % some  empirical initial values
fit = fminsearchbnd(fiterr, init, lowerbound, upperbound, opt);

% calculate threshold
thresholdUp = invLogistic(thresholdPerf,fit);
thresholdDown = invLogistic(1-thresholdPerf,fit);


figure('name',sprintf('%s - %d%% threshold',fileName, thresholdPerf*100));
hAxis = axes;
hAxis.YLim = [0 1.05];
hold on;
x= -1:0.01:1;

% plot 0,0 axes
plot([-1; 1],0.5*ones(2,1),'k:')
plot(zeros(2,1),[0; 1],'k:')

% plot data for each direction in different colors
hAxis.YLim = [-0.05 1.05];
hold on;
c = 0;
for direction = [90 270]
  c=c+1;

  switch(direction)
    case 90
      colour = 'r';
    case 270
      colour = 'b';
  end

  thisTrials = trials(trials(:,3) == direction,:);
  empPsyMet = emppsymet(thisTrials);
  h(:,c) = errorbar(empPsyMet(:,1),empPsyMet(:,2),empPsyMet(:,4),[colour 'o']);

end

% plot model
plot(x,scaledLogistic(x,fit),'g','lineWidth',2);

% plot thresholds
thresholdUpPerfFit = thresholdPerf*(1-fit(3)) + fit(3)/2;
plot([-1;thresholdUp],thresholdUpPerfFit *ones(2,1),'g--');
plot(thresholdUp*ones(2,1),[-0.05 thresholdUpPerfFit],'g--');
text(thresholdUp,thresholdUpPerfFit-.04,sprintf('%.3f',thresholdUp),'FontSize',16);

thresholdDownPerfFit = (1-thresholdPerf)*(1-fit(3)) + fit(3)/2;
plot([-1;thresholdDown],thresholdDownPerfFit *ones(2,1),'g--');
plot(thresholdDown*ones(2,1),[-0.05 thresholdDownPerfFit],'g--');
text(thresholdDown,thresholdDownPerfFit+.04,sprintf('%.3f',thresholdDown),'HorizontalAlignment','right','FontSize',16);

legend(h(1,:),{'up','down'},'location','SouthEast')

ylabel('Probability of choosing ''Up''');
xlabel('Coherence');
