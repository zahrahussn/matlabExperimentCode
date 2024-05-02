% fits logistic psychometric function to motion direction discrimination data obtained using
% Motion/BaselineTask.py, AdatationTask.py or ImageryTask.py
% Logistic function is fitted to an down/up motion response function spanning the two opposite directions
% (see: Winawer et al., 2010, A motion aftereffect from visual imagery of motion)
% Motion discrimination is assumed to be between up (90) and down (270)
% For baseline (no adaptation), returns threshold at given performance (e.g. 99%)
% For Adaptation and Imagery, a difference in bias between the two opposite adaptation directions is modeled

function [fit, thresholdUp,thresholdDown] = motionPsymetLogistic(fileName,fitBias,fitLapse)

if ~exist('fileName','var') || isempty(fileName)
  fileName = "aa_pilot1_baseline.csv";
end

thresholdPerf = 0.9;

try
  trials = readtable(fileName);
catch
  fprintf('\nCannot find file %s in folder %s\n\n',fileName, pwd);
  return;
end

fitAdaptation = true;
if ismember('adapt_direction',trials.Properties.VariableNames)
  dotDirection = trials.dot_direction;
  adaptDirection = trials.adapt_direction;
elseif ismember('imagery_direction',trials.Properties.VariableNames)
  dotDirection = trials.dot_direction;
  adaptDirection = trials.imagery_direction;
else
  dotDirection = trials.direction;
  adaptDirection = zeros(size(dotDirection)); % no adaptation
  fitAdaptation = false;
end

if ~exist('fitBias','var') || isempty(fitBias)
  fitBias = fitAdaptation; % by default, only fit the global bias for adaptation data (not for baseline)
end
if ~exist('fitLapse','var') || isempty(fitLapse)
  fitLapse = ~fitAdaptation; % by default do not fit the lapse parameter for (individual) adaptation data (as in Winawer et al., 2010)
end

% make a motion response function spanning the two opposite directions
signedCoherence = trials.coherence;
signedCoherence(dotDirection==270) = -signedCoherence(dotDirection==270); % coherence for "down" trials is negative
probUpResponse = trials.accuracy; % convert accuracy to probability of responding "up"
probUpResponse(dotDirection==270) = 1-probUpResponse(dotDirection==270);

%transform adaptation direction data
adaptDirection(adaptDirection==90) = 1; % 1 for up
adaptDirection(adaptDirection==270) = -1; % and -1 for down (and 0 otherwise)


% logistic function with an additional parameter for the asymptote (lapse rate)
scaledLogistic = @(x,p) p(3)/2 +  (1-p(3)) * 1./(1+exp(-(p(1) + p(2)*x)));

% inverse logistic function (without the additional lapse parameter)
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

% logistic function with an additional parameter for the asymptote (lapse rate) and a bias parameter due to adaptation
scaledLogistic = @(x,p,A) p(3)/2 +  (1-p(3)) * 1./(1+exp(-(p(1) + p(2)*x + p(4)*A)));

% inverse logistic function (without the additional lapse parameter)
invLogistic = @(y,p,A) (-p(1) + p(4)*A - log(1./y - 1))/p(2);
% derivation  of the inverse logistic function
% logistic = @(x,p) 1./ ( 1+ exp (-(p(1) + p(2)*x + p(4)*A)));
% y = 1./ ( 1+ exp (-(p(1) + p(2)*x + p(4)*A)))
% 1./y = 1+ exp (-(p(1) + p(2)*x + p(4)*A))
% 1./y - 1 = exp (-(p(1) + p(2)*x + p(4)*A))
% log(1./y - 1) = -(p(1) + p(2)*x + p(4)*A)
% log(1./y - 1) = -p(1) - p(2)*x + p(4)*A
% p(2)*x = -p(1) + p(4)*A - log(1./y - 1)
% x = (-p(1) + p(4)*A - log(1./y - 1))/p(2)

% Fit psychometric curve using maximum likelihood
upResponseTrials = probUpResponse==1;
downResponseTrials = probUpResponse==0;
fiterr = @(p) -sum(log( scaledLogistic( signedCoherence(upResponseTrials), p, adaptDirection(upResponseTrials)) )) -sum(log(1 - scaledLogistic( signedCoherence(downResponseTrials), p, adaptDirection(downResponseTrials))));

opt=optimset('Display','off', 'TolX',0.0001,'TolFun',0.000001, 'MaxFunEvals',1000);

lowerbound = [0 -inf 0 0];
upperbound = [0 inf 0 0];
if fitBias
  lowerbound(1) = -1;
  upperbound(1) = 1;
end
if fitLapse
  upperbound(3) = 1;
end
if fitAdaptation
  lowerbound(4) = -inf;
  upperbound(4) = inf;
end

init = [ mean(signedCoherence.*(probUpResponse))*5, 5, 0, 0]; % some  empirical initial values
fit = fminsearchbnd(fiterr, init, lowerbound, upperbound, opt);

% Plot empirical and fitted psychometric functions
titleString = fileName;
if ~fitAdaptation
  titleString = sprintf('%s - %d%% threshold',titleString, thresholdPerf*100);
end
figure('name',titleString);
hAxis = axes;
hAxis.YLim = [0 1.05];
hold on;
x= -1:0.01:1;

% plot 0,0 axes
plot([-1; 1],0.5*ones(2,1),'k:')
plot(zeros(2,1),[0; 1],'k:')

% plot data for each dot direction/adaptation direction in different colors/styles
hAxis.YLim = [-0.05 1.05];
hold on;
c = 0;
adaptDirs = unique(adaptDirection);
markers = 'ox';
styles = '-:';
for iAdapt = 1:length(adaptDirs)
  for direction = [90 270]
    c=c+1;
  
    switch(direction)
      case 90
        colour = 'r';
      case 270
        colour = 'b';
    end
    
    whichTrials = dotDirection == direction & adaptDirection == adaptDirs(iAdapt);
    empPsyMet = emppsymet([signedCoherence(whichTrials) probUpResponse(whichTrials)]);
    h(:,c) = errorbar(empPsyMet(:,1),empPsyMet(:,2),empPsyMet(:,4),[colour markers(iAdapt) styles(iAdapt)]);

  end

  % plot model
  plot(x,scaledLogistic(x,fit,adaptDirs(iAdapt)),['g' styles(iAdapt)],'lineWidth',2);

end

if fitAdaptation
  thresholdUp = [];
  thresholdDown = [];
else
  % calculate threshold
  thresholdUp = invLogistic(thresholdPerf,fit,0);
  thresholdDown = invLogistic(1-thresholdPerf,fit,0);
  
  % plot thresholds
  thresholdUpPerfFit = thresholdPerf*(1-fit(3)) + fit(3)/2;
  plot([-1;thresholdUp],thresholdUpPerfFit *ones(2,1),'g--');
  plot(thresholdUp*ones(2,1),[-0.05 thresholdUpPerfFit],'g--');
  text(thresholdUp,thresholdUpPerfFit-.04,sprintf('%.3f',thresholdUp),'FontSize',16);
  
  thresholdDownPerfFit = (1-thresholdPerf)*(1-fit(3)) + fit(3)/2;
  plot([-1;thresholdDown],thresholdDownPerfFit *ones(2,1),'g--');
  plot(thresholdDown*ones(2,1),[-0.05 thresholdDownPerfFit],'g--');
  text(thresholdDown,thresholdDownPerfFit+.04,sprintf('%.3f',thresholdDown),'HorizontalAlignment','right','FontSize',16);
end

if fitAdaptation
  legend(h(1,:),{'up - adapt up','down - adapt up','up - adapt down','down - adapt down'},'location','SouthEast')
else
  legend(h(1,:),{'up','down'},'location','SouthEast')
end

titleString = sprintf('Slope \\beta = %.1f',fit(2));
if fitLapse
  titleString = sprintf('%s, Lapse \\delta = %.2f',titleString, fit(3)/2);
end
if fitBias
  titleString = sprintf('Bias \\alpha = %.2f, %s',fit(1), titleString);
end
if fitAdaptation
  titleString = sprintf('%s, Adaptation bias \\gamma = %.2f',titleString, fit(4));
end
title(titleString,'interpreter','tex');

ylabel('Probability of choosing ''Up''');
xlabel('Coherence');
