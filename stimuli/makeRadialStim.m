function pixelValue=makeRadialStim(radialHarmonics,radialAmplitudes,radialPhases, writeBitmap, axisHandle, contourStyle, texture)
imageDims = [256 256]; % size of the bitmap image in pixels
imageSize = [1.75 1.75]; % size of the image in degrees of visual angle
baseRadius = 0.5; % radius of the zeroth harmonic (base radius of the circle) in degrees of visual angle

% harmonic numbers
if ~exist('radialHarmonics','var') || isempty(radialHarmonics)
  radialHarmonics = [2 5]; % these defaults replicate the bottom right stimulus of Fig. 1 in Wilson & Wilkinson (2002)
  radialHarmonics = [2 3 4]; % nice stylized butterfly
end
% amplitude of each harmonic as a precentage of the base radius
if ~exist('radialAmplitudes','var') || isempty(radialAmplitudes)
  radialAmplitudes = [10 3]; % these defaults replicate the bottom right stimulus of Fig. 1 in Wilson & Wilkinson (2002)
  radialAmplitudes = [10 10 20]; % nice stylized butterfly
end
radialAmplitudesDeg = radialAmplitudes/100*baseRadius; % amplitude of each harmonic in degrees of visual angle
% phase of each harmonic in in degrees
if ~exist('radialPhases','var') || isempty(radialPhases)
  radialPhases = [0 180+30]; % these defaults replicate the bottom right stimulus of Fig. 1 in Wilson & Wilkinson (2002) (the second harmonic component of all stimuli in this figure is always shifted by 180 degrees relative to the first component)
  radialPhases = [180 180 180]; % nice stylized butterfly
end
radialPhasesRad = radialPhases/180*pi; % phase of each harmonic in radians
if ~exist('writeBitmap','var') || isempty(writeBitmap)
  writeBitmap = false; % do not write out bitmap image by default
end
if ~exist('contourStyle','var') || isempty(contourStyle)
  contourStyle = 'bandpass'; % style of the contour, either 'bandpass' (as in Wilkinson & Wilson, 2002) or 'raisedCosine' (a smooth black line)
end
if ~exist('texture','var') || isempty(texture)
  texture = false; % whether to add a texture within the contour
end

nHarmonics = length(radialHarmonics);
if length(radialAmplitudesDeg)~=nHarmonics || length(radialPhasesRad)~=nHarmonics
  fprintf('Harmonic amplitues and phases must have the same number of elements\n')
  return;
end

% anonymous function returning the radius as a function the polar angle phi
% (see eq. 1 in Wilson & Wilkinson (2002))
radius = @(phi) baseRadius;
for iHarm = 1:nHarmonics
  radius = @(phi) radius(phi) + radialAmplitudesDeg(iHarm)*cos(radialHarmonics(iHarm)* (phi - pi/2) + radialPhasesRad(iHarm));
  % (subtract pi/2 phase to replicate Wilson & Wilkinson (2002)'s convention that 0 phase corresponds to upper vertical)
end

% plot contour as line plot
% nPoints = 100;
% phi = linspace(-pi,pi,nPoints);
% complexCoords = radius(phi).*exp(1i*phi);
% if ~exist("axisHandle",'var')
%     figure('name',sprintf('Harmonics = %s   A = %s   phi = %s',mat2str(radialHarmonics),mat2str(radialAmplitudes),mat2str(radialPhases)));
%     axisHandle=axes;
% end
% plot(axisHandle,real(complexCoords),imag(complexCoords),'k','lineWidth',4);
% axis equal
% xlim([-1 1]*imageSize(1)/2);
% ylim([-1 1]*imageSize(2)/2);

% make bitmap image
imageCenter = imageDims/2+0.5;
sigma = 0.056; % bandpass space constant in degrees of visual angle (see eq. 2 in Wilson & Wilkinson (2002))
beta = 0.5; % beta parameter for raised cosine (0 = cosine, 1 = square) (for raised cosines, sigma is the width parameter)
pixelValue = zeros(imageDims);
mask = zeros(imageDims);
for x = 1:imageDims(1)
  for y = 1:imageDims(2)
    complexCoords = (x-imageCenter(1) + 1i*(y-imageCenter(2))) / min(imageDims/2) * min(imageSize/2);
    r = abs(complexCoords);
    phi = angle(complexCoords);
    
    switch(contourStyle)
      case 'bandpass'
        % get contrast value at pixel using eq. 2 from Wilson & Wilkinson (2002)
        pixelValue(y,x) = (1 - 4*(r-radius(phi)).^2/sigma^2 + 4/3*(r - radius(phi)).^4/sigma^4 ) * exp(-(r-radius(phi)).^2/sigma^2);
        % (x coordinates correspond to matrix colums going from left to right and
        %  y coordinates correspond to matrix rows going from top to bottom)
      case 'raisedCosine'
        % use raised cosine
        switch(discretize( abs(r-radius(phi)), [-inf (1-beta)/2*sigma (1+beta)/2*sigma inf] ))
          case 1
            pixelValue(y,x) = -1;
          case 2
            pixelValue(y,x) = -0.5 * (1 + cos( pi/beta/sigma * (abs(r-radius(phi)) - (1-beta)/2*sigma) ) ); % raised cosine formula taken from wikipedia, where sigma = 1/T
          case 3
            pixelValue(y,x) = 0;
        end
    end

    if texture && r < radius(phi)
      mask(y,x) = 1;
    end

  end
end

if texture
  images = makebpnoise_symmetric([],1,10,12,false); % get texture bitmap
  pixelValue = max(min( mask.*images.nz1  + pixelValue , 1),-1); % , mask texture, and overlay contour on top of texture (there's a better way to do transparency, but this will do for now)
end

% display bitmap
if ~exist("axisHandle",'var') || isempty(axisHandle)
    figure('name',sprintf('Harmonics = %s   A = %s   phi = %s',mat2str(radialHarmonics),mat2str(radialAmplitudes),mat2str(radialPhases)));
    axisHandle=axes;
end
imagesc(axisHandle,pixelValue,[-1 1]);
colormap('gray');
set(axisHandle,'YDir','normal'); % this will display the image with increasing matrix rows going from bottom to top
axis equal
xlim([1 imageDims(1)]);
ylim([1 imageDims(2)]);
colorbar;

if writeBitmap % save bitmap
  % because the matrix has been filled from top to bottom for the y coordinates, we flip the rows)
  imwrite(flipud((pixelValue+1)/2),sprintf('radialStim_H%s_A%s_P%s.png',sprintf('-%d',radialHarmonics),sprintf('-%d',radialAmplitudes),sprintf('-%d',radialPhases)));
end
