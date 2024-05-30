% fits logistic psychometric function to motion direction discrimination data obtained using
% Motion/BaselineTask.py, AdaptationTask.py or ImageryTask.py
% Logistic function is fitted to an down/up motion response function spanning the two opposite directions
% (see: Winawer et al., 2010, A motion aftereffect from visual imagery of motion)
% Motion discrimination is assumed to be between up (90) and down (270)
% For baseline (no adaptation), returns threshold at given performance (e.g. 99%)
% For Adaptation and Imagery, a difference in bias between the two opposite adaptation directions is modeled

function [fit, thresholdUp,thresholdDown] = motionPsymetLogistic(inputCsvFileNames,fitBias,fitLapse)

thresholdPerf = 0.9;
nFilesExport = 5; % number of input files above which a group csv is exported

if ~exist('inputCsvFileNames','var') || isempty(inputCsvFileNames)
inputCsvFileNames = {};
  [inputCsvFile,inputCsvFilePath] = uigetfile('*.csv','Select data file(s)','MultiSelect','on');
  if isnumeric(inputCsvFile)
    inputCsvFileNames = {};
  elseif ischar(inputCsvFile)
    inputCsvFileNames = [inputCsvFileNames {fullfile(inputCsvFilePath,inputCsvFile)}];
  else
    for iFile = 1:length(inputCsvFile)
      inputCsvFileNames = [inputCsvFileNames {fullfile(inputCsvFilePath,inputCsvFile{iFile})}];
    end
  end
elseif ischar(inputCsvFileNames)
  inputCsvFilePath = fileparts(inputCsvFileNames);
  inputCsvFileNames = {inputCsvFileNames};
end
if isempty(inputCsvFileNames)
  return;
end
nFiles = length(inputCsvFileNames);
plotFigure = nFiles<=4;

cFile = 0;
for iFile = 1:nFiles
  try
    trials = readtable(inputCsvFileNames{iFile});
    cFile = cFile + 1;
  catch
    fprintf('\nCould not find file %s in folder %s\n',inputCsvFileNames{iFile}, inputCsvFilePath);
    continue;
  end

  % attempt to parse information from file name
  [~,fileName] = fileparts(inputCsvFileNames{iFile});
  fileInfo = split(fileName,'_');
  if iscell(fileInfo) && length(fileInfo)==3 && length(fileInfo{2})==4
    id{cFile} = fileInfo{1};
    day(cFile) = str2double(fileInfo{2}(4));
    task{cFile} = fileInfo{3};
  else
    if nFiles > nFilesExport
      fprintf('\nCould not parse info from file %s\n',inputCsvFileNames{iFile});
    end
    id{cFile} = 'unknown';
    day(cFile) = NaN;
    task{cFile} = 'unknown';
  end
  
  fitAdaptation = true;
  if ismember('adapt_direction',trials.Properties.VariableNames)
    dotDirection = trials.dot_direction;
    adaptDirection = trials.adapt_direction;
    %transform adaptation direction data
    adaptDirection(adaptDirection==90) = 1; % 1 for up
    adaptDirection(adaptDirection==270) = -1; % and -1 for down (and 0 otherwise)
    imageryCondition = 'Adaptation';
  elseif ismember('imagery_direction',trials.Properties.VariableNames)
    dotDirection = trials.dot_direction;
    %transform adaptation direction data
    adaptDirection = ones(size(dotDirection)); % 1 for up
    adaptDirection(ismember(trials.imagery_direction,'down')) = -1; % -1 for down
    imageryCondition = 'Imagery';
  else
    dotDirection = trials.direction;
    adaptDirection = zeros(size(dotDirection)); % no adaptation
    fitAdaptation = false;
    imageryCondition = 'Baseline';
  end
  if ~strcmpi(task{cFile},'unknown') && ~strcmpi(imageryCondition,task{cFile})
    keyboard; % mismatch between file name and information contained in file
  end
  
  if exist('fitBias','var') && ~isempty(fitBias)
    thisFitBias = fitBias;
  else
    thisFitBias = fitAdaptation; % by default, only fit the global bias for adaptation data (not for baseline)
  end
  if exist('fitLapse','var') && ~isempty(fitLapse)
    thisFitLapse = fitLapse;
  else
    thisFitLapse = ~fitAdaptation; % by default do not fit the lapse parameter for (individual) adaptation data (as in Winawer et al., 2010)
  end
  
  % make a motion response function spanning the two opposite directions
  signedCoherence = trials.coherence;
  signedCoherence(dotDirection==270) = -signedCoherence(dotDirection==270); % coherence for "down" trials is negative
  probUpResponse = trials.accuracy; % convert accuracy to probability of responding "up"
  probUpResponse(dotDirection==270) = 1-probUpResponse(dotDirection==270);
  
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
  if thisFitBias
    lowerbound(1) = -inf;
    upperbound(1) = inf;
  end
  if thisFitLapse
    upperbound(3) = 1;
  end
  if fitAdaptation
    lowerbound(4) = -inf;
    upperbound(4) = inf;
  end
  
  init = [ mean(signedCoherence.*(probUpResponse))*5, 5, 0, 0]; % some  empirical initial values
  fit = fminsearchbnd(fiterr, init, lowerbound, upperbound, opt);
  alpha_bias(cFile) = fit(1);
  beta_slope(cFile) = fit(2);
  delta_lapse(cFile) = fit(3);
  gamma_bias(cFile) = fit(4);
  
  % Plot empirical and fitted psychometric functions
  if plotFigure
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
    adaptDirs = unique(adaptDirection);
    markers = 'ox';
    styles = '-:';
    colours = 'rb';
    for iAdapt = 1:length(adaptDirs)
      for direction = [90 270]
        
        whichTrials = dotDirection == direction & adaptDirection == adaptDirs(iAdapt);
        empPsyMet = emppsymet([signedCoherence(whichTrials) probUpResponse(whichTrials)]);
        errorbar(empPsyMet(:,1),empPsyMet(:,2),empPsyMet(:,4),[colours(iAdapt) markers(iAdapt) styles(iAdapt)]);
        
      end
      
      % plot model
      h(iAdapt) = plot(x,scaledLogistic(x,fit,adaptDirs(iAdapt)),[colours(iAdapt) styles(iAdapt)],'lineWidth',2);
      
    end
  end

  if fitAdaptation
    thresholdUp(cFile) = NaN;
    thresholdDown(cFile) = NaN;
  else
    % calculate threshold
    thresholdUp(cFile) = invLogistic(thresholdPerf,fit,0);
    thresholdDown(cFile) = invLogistic(1-thresholdPerf,fit,0);
    
    % plot thresholds
    thresholdUpPerfFit = thresholdPerf*(1-delta_lapse(cFile)) + delta_lapse(cFile)/2;
    if plotFigure
      plot([-1;thresholdUp(cFile)],thresholdUpPerfFit *ones(2,1),'g--');
      plot(thresholdUp(cFile)*ones(2,1),[-0.05 thresholdUpPerfFit],'g--');
      text(thresholdUp(cFile),thresholdUpPerfFit-.04,sprintf('%.3f',thresholdUp(cFile)),'FontSize',16);
    end

    thresholdDownPerfFit = (1-thresholdPerf)*(1-delta_lapse(cFile)) + delta_lapse(cFile)/2;
    if plotFigure
      plot([-1;thresholdDown(cFile)],thresholdDownPerfFit *ones(2,1),'g--');
      plot(thresholdDown(cFile)*ones(2,1),[-0.05 thresholdDownPerfFit],'g--');
      text(thresholdDown(cFile),thresholdDownPerfFit+.04,sprintf('%.3f',thresholdDown(cFile)),'HorizontalAlignment','right','FontSize',16);
    end
  end
  
  if plotFigure
    if fitAdaptation
      legend(h,{[imageryCondition ' up'],[imageryCondition ' down']},'location','SouthEast')
    end
    
    titleString = sprintf('Slope \\beta = %.1f',beta_slope(cFile));
    if thisFitLapse
      titleString = sprintf('%s, Lapse \\delta = %.2f',titleString, delta_lapse(cFile)/2);
    end
    if thisFitBias
      titleString = sprintf('Bias \\alpha = %.2f, %s',alpha_bias(cFile), titleString);
    end
    if fitAdaptation
      titleString = sprintf('%s, %s bias \\gamma = %.2f',titleString, imageryCondition, gamma_bias(cFile));
    end
    title(titleString,'interpreter','tex');
    
    ylabel('Probability of choosing ''Up''');
    xlabel('Coherence');
  end
end

if nFiles > nFilesExport
  if ~exist('outputCsvFileName','var') || isempty(outputCsvFileName)
    [outputCsvFileName,outputCsvFilePath] = uiputfile('*.csv','Enter CSV filename to save');
    if isnumeric(outputCsvFileName)
      return;
    end
    outputCsvFileName = fullfile(outputCsvFilePath,outputCsvFileName);
  end
  
  % data need to be in column vectors to table function to give the correct column names
  id = id';
  day = day';
  task = task';
  threshold= thresholdUp';
  alpha_bias = alpha_bias';
  beta_slope = beta_slope';
  delta_lapse = delta_lapse';
  gamma_bias = gamma_bias';
  T = table(id,day,task,threshold,alpha_bias,beta_slope,delta_lapse,gamma_bias);
  writetable(T,outputCsvFileName,'Delimiter',',','WriteRowNames',true);
  fprintf('Wrote %s\n',outputCsvFileName);
end

