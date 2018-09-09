% ideal.m  Ideal observer for 1-of-10 texture detection

clear; clc;

% set the image size (dim x dim)
dim = 60;

% load the textures and resize them to (dim x dim) images
nletters = 10;
load NoiseStruct1
for i = 1:nletters
    letter{i} = eval(['images.nz', num2str(i)]);  % rename textures to fit with this code
    letter{i} = letter{i}*sqrt(1/var(letter{i}(:))); % set to variance of 1
    letter{i} = imresize(letter{i},[ dim dim ],'nearest');    % resize letter to dim x dim
end

% make the blank signal
blank = zeros([ dim dim ]);

% set some parameters

%thresholdguess=[3*0.0001, 0.0008, 0.0075]; % identification guesses
thresholdguess=0.00002; % detection guess for noise var = 0.01
nvar=[0.001 0.01 0.1];     % identfication noise variances; only 0.01 used for detection expt
%nvar=0.01;
numnz=length(nvar);
values=zeros(numnz,7);


% get range of contrasts used in detection task
for kk=1:numnz
	tmp=thresholdguess;
	highval=log10(tmp)+log10(sqrt(50)); 
	lowval=log10(tmp)-log10(sqrt(15));
  %  cvalues(kk,1)=0;
	cvalues(kk,:)=logspace(lowval,highval,7); % set (n=numvalues) of log-spaced values centered on thresholdguess
    
end;


ntrials = 1000;      % number of trials
correct = zeros(1000,length(cvalues),3);

% run trials
figure;
for n = 1:length(nvar)
    for c = 1:length(cvalues(n,:))
        for t = 1:ntrials
            % PART ONE -- MAKE THE STIMULUS
            
            % decide whether to show a letter or a blank ( 50-50 chance; 0 = blank, 1 = letter )
            signal(t,c,n) = (rand<0.5);
    
            % choose the signal
            if signal(t,c,n)==1
                letteri(t,c,n) = ceil(rand*10);              % choose a random letter
                stim = sqrt(cvalues(n,c))*letter{letteri(t,c,n)};   % set it to the right contrast
            else
                    letteri(t,c,n) = NaN;
                    stim = blank;
            end
                    % add the noise
                     stim = stim + normrnd(0,sqrt(nvar(n)),[ dim dim ]);
    
                    % show an image of the stimulus every few trials to keep the humans occupied
                   % if mod(t,50) ==0, imagesc(stim); colormap gray;  drawnow; end
    
                    % PART TWO -- CHOOSE A RESPONSE (pretending that we don't already know the right answer)
    
                     % find the probability of this stimulus being generated on a no-signal trial
                       %prob_nosignal(t, c, n) = prod(prod( normpdf( stim, blank, sqrt(nvar(n)) ) ));
                       probNS =  normpdf( stim, blank, sqrt(nvar(n) ));
    
                    % find the probability of this stimulus being generated on a signal trial;
                    % we do this by summing the probability of it being an image of each possible letter
                    prob_signal(t, c, n) = 0;
                    probS = NaN([size(stim) nletters]);
                    
                    for i = 1:nletters
                       % prob_signal(t, c, n) = prob_signal(t) + (1/nletters)*prod(prod( normpdf( stim, sqrt(cvalues(n,c))*letter{i}, sqrt(nvar(n)) ) ));
                        probS(:,:,i) = normpdf( stim, sqrt(cvalues(n,c))*letter{i}, sqrt(nvar(n)) ) ;
                    end
                    
                    %normalize output of normpdf before computing the products because they get too large or too small for small and large values of sigma respectively)
                    normFactor = mean([probNS(:);probS(:)]); %take the mean of all pdf values
                    probNS = probNS/normFactor;
                    probS = probS/normFactor;
      
                    %compute product of probabilities
                    prob_nosignal(t,c,n) = prod(prod(probNS));
                    prob_signal(t,c,n) = mean(prod(prod(probS)));
                    
       
                    % make a response according to the probabilities
                    if prob_signal(t, c, n) > prob_nosignal(t, c, n)
                        response(t,c,n) = 1;
                    else
                        response(t,c,n) = 0;
                    end

                    % record whether it was a correct response
                    correct(t,c,n) = ( signal(t,c,n) == response(t,c,n) );
                   
        end
    end
end


% find proportion correct for the ideal observer
pcorrect = mean(correct)
figure;
set(gcf,'DefaultAxesColorOrder',[0 0 0;0 0 1;1 0 0]);
plot(cvalues(1,:),squeeze(pcorrect)','.-');
legend('nvar = 0.001', 'nvar = 0.01', 'nvar = 0.1');



for n = 1:numnz
    for c = 1:length(cvalues)
        pfa(n,c)=mean(response(signal(:,c,n)==0,c,n))
        if pfa(n,c)==0, pfa(n,c) = 0.0001; else pfa(n,c)=pfa(n,c); end;
        phit(n,c) = mean(response(signal(:,c,n)==1,c,n));
        if phit(n,c)==1, phit(n,c) = 0.9999; else phit(n,c)=phit(n,c); end;
        dprime(n,c) = norminv(phit(n,c)) - norminv(pfa(n,c));
    end
end



% plot ideal and human dprime
texdprime;
figure;
set(gcf,'DefaultAxesColorOrder',[0 0 0;0 0 1;1 0 0; 0,1,0]);
semilogx(cvalues(1,:),squeeze(dprime(2,:))','.-', 'MarkerSize', 18);
hold on
semilogx(cvalues(1,:), mean(dprimeData(:,2:8,1)), 'g.-', 'MarkerSize', 18);
hold on
semilogx(cvalues(1,:), mean(dprimeData(:,2:8,2)), 'g.--', 'MarkerSize', 18);
legend('nvar = 0.001', 'nvar = 0.01', 'nvar = 0.1', 'human day 1, nvar = 0.01', 'human day 2, nvar = 0.01');
xlabel('Contrast (rms)')
ylabel('dprime')


% plot ratio of human to ideal dprime (squared)

figure;
plot(cvalues(1,2:7), (dprime(2,2:7)./mean(dprimeData(:,3:8,1))).^2, 'k.-', 'MarkerSize', 18);
hold on
plot(cvalues(1,2:7), (dprime(2,2:7)./mean(dprimeData(:,3:8,2))).^2, 'k.--', 'MarkerSize', 18);
ylim([0,16])
legend('day 1', 'day 2'); 
xlabel('Contrast (rms)');
ylabel('Efficiency');


% calculate ideal threshold (at each noise level)
idealdat=zeros(7000,2,3);
for n=1:3
    idealdat(:,1,n)=reshape(repmat(cvalues(1,:),1000,1), numel(cvalues(1,:))*1000,1);
    idealdat(:,2,n)=reshape(correct(:,:,n), 7000,1);
  %  [thresh, beta]=fitpsymet(idealdat(:,:,n));
end





