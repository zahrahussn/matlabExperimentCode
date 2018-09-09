% ideal.m  Ideal observer for 1-of-10 letter detection

function pcorrect = ideal(sigcontrast,noisestd,ntrials)

% set the image size (dim x dim)
dim = 40;

% load the letters and resize them to (dim x dim) images
nletters = 10;
for i = 1:nletters
    letter{i} = imread(sprintf('letters/%s.tif','a'+(i-1)));  % load letter image
    letter{i} = (double(letter{i})-128)/127;                  % convert to range 0.0 - 1.0
%     letter{i} = imresize(letter{i},[ dim dim ],'nearest');    % resize letter to dim x dim
end

% make the blank signal
blank = zeros([ dim dim ]);

% set some parameters
if ~exist('sigcontrast','var') || isempty(sigcontrast)
  sigcontrast = 0.04;  % signal contrast
end
if ~exist('noisestd','var') || isempty(noisestd)
  noisestd = 0.15;     % noise standard deviation
end
if ~exist('ntrials','var') || isempty(ntrials)
  ntrials = 1000;      % number of trials
end
% run trials

for s = 1:length(noisestd)
  signal = NaN(ntrials,1);
  letteri = NaN(ntrials,1);
  prob_nosignal = NaN(ntrials,1);
  prob_signal = NaN(ntrials,1);
  response = NaN(ntrials,1);
  correct = NaN(ntrials,1);
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
      stim = stim + normrnd(0,noisestd(s),[ dim dim ]);

      % show an image of the stimulus every few trials to keep the humans occupied
  %     if mod(t,50) ==0, imagesc(stim); colormap gray;  drawnow; end

      % PART TWO -- CHOOSE A RESPONSE (pretending that we don't already know the right answer)

      % find the probability of this stimulus being generated on a no-signal trial (at each pixel)
      probNS =  normpdf( stim, blank, noisestd(s) );
      % find the probability of this stimulus being generated on a signal trial;
      % we do this by summing the probability of it being an image of each possible letter
      %first compute the probabilities for each pixel and each letter
      probS = NaN([size(stim) nletters]); %create a 3D array to put the pdfs of all 10 letters in it
      for i = 1:nletters
        probS(:,:,i)=normpdf( stim, sigcontrast*letter{i}, noisestd(s) );
      end
      
      %normalize output of normpdf before computing the products
      %(because they get too large or too small for small and large values of sigma respectively)
      normFactor = mean([probNS(:);probS(:)]); %take the mean of all pdf values
      probNS = probNS/normFactor;
      probS = probS/normFactor;
      
      %compute product of probabilities
      prob_nosignal(t) = prod(prod(probNS));
      prob_signal(t) = mean(prod(prod(probS)));
      
      % make a response according to the probabilities
      if prob_signal(t) > prob_nosignal(t)
          response(t) = 1;
      else
          response(t) = 0;
      end

      % record whether it was a correct response
      correct(t) = ( signal(t) == response(t) );

  end
      fprintf('%f %d %d %d %d\n',noisestd(s), nnz(~prob_signal), nnz(isinf(prob_signal)), nnz(~prob_nosignal), nnz(isinf(prob_nosignal)));

  % find proportion correct for the ideal observer
  pcorrect(s) = mean(correct);
end

figure;plot(noisestd,pcorrect);
