% ideal.m  Ideal observer for 1-of-10 letter detection

clear; clc;

% set the image size (dim x dim)
dim = 40;

% load the letters and resize them to (dim x dim) images
nletters = 10;

for i = 1:nletters
    letter{i} = imread(sprintf('letters/%s.tif','a'+(i-1)));  % load letter image
    letter{i} = (double(letter{i})-128)/127;                  % convert to range 0.0 - 1.0
    letter{i} = imresize(letter{i},[ dim dim ],'nearest');    % resize letter to dim x dim
end

% make the blank signal
blank = zeros([ dim dim ]);

% set some parameters
sigcontrast = 0.04;  % signal contrast
noisestd = 0.1;     % noise standard deviation
ntrials = 1000;      % number of trials

% run trials
for t = 1:ntrials
    
    % PART ONE -- MAKE THE STIMULUS
    
    % decide whether to show a letter or a blank ( 50-50 chance; 0 = blank, 1 = letter )
    signal(t) = (rand<0.5);
    
    % choose the signal
    if signal(t)==1
        letteri(t) = ceil(rand*10);              % choose a random letter
        stim = sigcontrast*letter{letteri(t)};   % set it to the right contrast
    else
        letteri(t) = NaN;
        stim = blank;
    end
    
    % add the noise
    stim = stim + normrnd(0,noisestd,[ dim dim ]);
    
    % show an image of the stimulus every few trials to keep the humans occupied
     if mod(t,50) ==0, imagesc(stim); colormap gray;  drawnow; end
    
    % PART TWO -- CHOOSE A RESPONSE (pretending that we don't already know the right answer)
    
    % find the probability of this stimulus being generated on a no-signal trial
    prob_nosignal(t) = prod(prod( normpdf( stim, blank, noisestd ) ));
    
    % find the probability of this stimulus being generated on a signal trial;
    % we do this by summing the probability of it being an image of each possible letter
    prob_signal(t) = 0;
    for i = 1:nletters
        prob_signal(t) = prob_signal(t) + (1/nletters)*prod(prod( normpdf( stim, sigcontrast*letter{i}, noisestd ) ));
    end

    % make a response according to the probabilities
    if prob_signal(t) > prob_nosignal(t)
        response(t) = 1;
    else
        response(t) = 0;
    end
    
    % record whether it was a correct response
    correct(t) = ( signal(t) == response(t) );
    
end

% find proportion correct for the ideal observer
pcorrect = mean(correct)
