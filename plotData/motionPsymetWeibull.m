% fits Weibull psychometric function to motion direction discrimination data
% obtained using Motion/BaselineTask.py, and returns threshold at given performance (e.g. 99%)
% Motion discrimination is assumed to be between up (90) and down (270)
% Up/down are fitted together (averaged) or separately

function [threshold3,threshold,fit3,fit] = motionPsymetWeibull(fileName)

if ~exist('fileName','var') || isempty(fileName)
  fileName = "aa_pilot1_baseline.csv";
end
thresholdPerf = 0.99;

dat = readtable(fileName);
trials = [dat.coherence dat.accuracy dat.direction];

scaledWeibull3params = @(x,p) (0.5 - p(3)) * weibullcdf(x,p(1),p(2));

% data for both directions together

% fit psychometric curve using maximum likelihood (?)
fiterr3 = @(p) -sum(log( 0.5 + scaledWeibull3params( trials(trials(:,2)==1,1), p ) )) -sum(log( 0.5 - scaledWeibull3params( trials(trials(:,2)==0,1), p) ));

opt=optimset('Display','off', 'TolX',0.0001,'TolFun',0.000001, 'MaxFunEvals',1000);
lowerbound = [-inf -inf 0];
upperbound = [inf inf 1];

init3 = [ mean(trials(:,1)), 2, 0];
fit3 =fminsearchbnd(fiterr3, init3, lowerbound, upperbound, opt);


figure('name',sprintf('%s - %d%% threshold',fileName, thresholdPerf*100));
hAxis = subplot(1,2,1);
empPsyMet = emppsymet(trials);
% plotpsymet(empPsyMet);
errorbar(empPsyMet(:,1),empPsyMet(:,2),empPsyMet(:,4),'ko');
hAxis.YLim = [0 1.05];
hold on;
x= 0:0.01:1;
plot(x,0.5+scaledWeibull3params(x,fit3),'g','lineWidth',2);

threshold3 = weibullinv(thresholdPerf,fit3(1),fit3(2));
thresholdPerfFit3 = 0.5 + thresholdPerf*(0.5-fit3(3));
plot([0;threshold3],thresholdPerfFit3 *ones(2,1),'g--');
plot(threshold3*ones(2,1),[0 thresholdPerfFit3],'g--');

text(threshold3,thresholdPerfFit3-.03,sprintf('%.3f',threshold3),'color','g');

ylabel('Accuracy');
xlabel('Coherence');


% data for each direction separately
hAxis = subplot(1,2,2);
hAxis.YLim = [0 1.05];
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

  fiterr{c} = @(p) -sum(log( 0.5 + scaledWeibull3params( thisTrials(thisTrials(:,2)==1,1), p ) )) -sum(log( 0.5 - scaledWeibull3params( thisTrials(thisTrials(:,2)==0,1), p) ));

  init(c,:) = [ mean(thisTrials(thisTrials(:,2)==1,1)), 2, 0];
  fit(c,:) = fminsearchbnd(fiterr{c}, init(c,:), lowerbound, upperbound, opt);
  
  empPsyMet = emppsymet(thisTrials);
  errorbar(empPsyMet(:,1),empPsyMet(:,2),empPsyMet(:,4),[colour 'o']);

  h(c) = plot(x,0.5+scaledWeibull3params(x,fit(c,:)),colour,'lineWidth',2);


  threshold(c) = weibullinv(thresholdPerf,fit(c,1),fit(c,2));
  thresholdPerfFit(c) = 0.5 + thresholdPerf*(0.5-fit(c,3));
  plot([0;threshold(c)],thresholdPerfFit(c) *ones(2,1),[colour ':']);
  plot(threshold(c)*ones(2,1),[0 thresholdPerfFit(c)],[colour ':']);

  text(threshold(c),thresholdPerfFit(c)-.03,sprintf('%.3f',threshold(c)),'color',colour);

end

legend(h,{'up','down'},'location','SouthEast')
ylabel('Accuracy');
xlabel('Coherence');

