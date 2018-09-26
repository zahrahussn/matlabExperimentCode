
 lowguess=[0.000009, 0.00012];
 medguess=[2*0.000009, 2*0.00012];
 highguess=[4*0.000009, 4*0.00012];

 for kk=1:2
%         tmp=thresholdguess(kk)/sqrt(10);
%         values(kk,:)=logspace(log10(tmp),log10(10*tmp),numvalues); % set (n=numvalues) of log-spaced values centered on thresholdguess
        tmp=lowguess(kk);
        highval=log10(tmp)+log10(sqrt(8)); % default 50 
        lowval=log10(tmp)-log10(sqrt(2)); % lowval raised from sqrt(15) to sqrt(5), oct 23, 2013 zh; sqrt2 nov 11, 2013
        lowvals(kk,:)=logspace(lowval,highval,7);
 end 
        
  for kk=1:2
        tmp=medguess(kk);
        highval=log10(tmp)+log10(sqrt(8)); % default 50 
        lowval=log10(tmp)-log10(sqrt(2)); % lowval raised from sqrt(15) to sqrt(5), oct 23, 2013 zh; sqrt2 nov 11, 2013
        medvals(kk,:)=logspace(lowval,highval,7);
  end 
        
  for kk=1:2
        tmp=highguess(kk);
        highval=log10(tmp)+log10(sqrt(8)); % default 50 
        lowval=log10(tmp)-log10(sqrt(2)); % lowval raised from sqrt(15) to sqrt(5), oct 23, 2013 zh; sqrt2 nov 11, 2013
        highvals(kk,:)=logspace(lowval,highval,7);
  end
 
  
  figure; % low noise level
  plot(lowvals(1,:), lowvals(1,:), 'k.-') % unity line
  hold on
  plot(lowvals(1,:), medvals(1,:), 'r.-') % low vs. med
  plot(lowvals(1,:), highvals(1,:), 'g.-') % low vs. high
  
   figure; % high noise level
  plot(lowvals(2,:), lowvals(2,:), 'k.-') % unity line
  hold on
  plot(lowvals(2,:), medvals(2,:), 'r.-') % low vs. med
  plot(lowvals(2,:), highvals(2,:), 'g.-') % low vs. high
  