
% test range of contrast values
  defarg('numvalues',7); % # of stimulus levels (i.e., contrast variance) used in each condition
    numContrast = numvalues;
    defarg('stepsperlogunit',10);
    % defarg('thresholdguess',[0.00001,0.0015,0.003]);
    % defarg('thresholdguess',3*nv/40); % these seem to be about right
    thresholdguess=[0.00002, 0.00012]; %  high noise guess 0.0002 for subject fm, lowered for andy

    for kk=1:numnz
%         tmp=thresholdguess(kk)/sqrt(10);
%         values(kk,:)=logspace(log10(tmp),log10(10*tmp),numvalues); % set (n=numvalues) of log-spaced values centered on thresholdguess
%         constimrec(kk)=constimInit(values(kk,:),trialspervalue(1)); % init the constantstimulus struct
%         constimrec(kk).appspec=nv(kk);	% attached noise variance to app-specific field
        tmp=thresholdguess(kk);
        highvalorig=log10(tmp)+log10(sqrt(15));
        highval=log10(tmp)+log10(sqrt(4)); % default 50; 15 for 2013 experiments   
        lowval=log10(tmp)-log10(sqrt(2)); % lowval raised from sqrt(15) to sqrt(5), oct 23, 2013 zh; sqrt2 nov 11, 2013
        
        valorig(kk,:)=logspace(lowval,highvalorig,numvalues); % set (n=numvalues) of log-spaced values centered on thresholdguess
        valuesorig(kk,:)=[0,0,0,0,0,0,0,valorig(kk,:)] %added 0-contrast values for the yes/no task.
      
        val(kk,:)=logspace(lowval,highval,numvalues); % set (n=numvalues) of log-spaced values centered on thresholdguess
        values(kk,:)=[0,0,0,0,0,0,0,val(kk,:)] %added 0-contrast values for the yes/no task.
      
        
    end;

figure;
plot(valuesorig(1,:), valuesorig(1,:), 'k.-')
hold on
plot(valuesorig(1,:), values(1,:), 'r.-')

figure;
plot(valuesorig(2,:), valuesorig(2,:), 'k.-')
hold on
plot(valuesorig(2,:), values(2,:), 'b.-')

