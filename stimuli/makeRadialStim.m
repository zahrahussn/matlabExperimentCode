function makeRadialStim(radialHarmonics,radialAmplitudes,radialPhases)

imageDims = [256 256]; % size of the bitmap image in pixels
imageSize = [1.5 1.5]; % size of the image in degrees of visual angle
baseRadius = 0.5; % radius of the zeroth harmonic (base radius of the circle) in degrees of visual angle

if ~exist('radialHarmonics','var') || isempty(radialHarmonics)
  radialHarmonics = [2 3 4]; % harmonic numbers
end
if ~exist('radialAmplitudes','var') || isempty(radialAmplitudesDeg)
  radialAmplitudes = [10 10 20]; % amplitude of each harmonic as a precentage of the base radius
end
radialAmplitudesDeg = radialAmplitudes/100*baseRadius; % amplitude of each harmonic in degrees of visual angle
if ~exist('radialPhases','var') || isempty(radialPhases)
  radialPhases = [0 0 0]/180*pi; % phase of each harmonic in in degrees
end
radialPhasesRad = radialPhases/180*pi; % phase of each harmonic in radians

nHarmonics = length(radialHarmonics);
if length(radialAmplitudesDeg)~=nHarmonics || length(radialPhasesRad)~=nHarmonics
  fprintf('Harmonic amplitues and phases must have the same number of elements\n')
  return;
end

% anonymous function returning the radius as a function the polar angle phi
% (see eq. 1 in Wilson & Wilkinson (2002))
radius = @(phi) baseRadius;
for iHarm = 1:nHarmonics
  radius = @(phi) radius(phi) + radialAmplitudesDeg(iHarm)*cos(radialHarmonics(iHarm)*phi + pi - radialPhasesRad(iHarm)); % (added pi phase to replicate Wilson & Wilkinson (2002)'s Fig. 1)
end

% % plot contour as line plot
% nPoints = 100;
% phi = linspace(-pi,pi,nPoints);
% complexCoords = radius(phi).*exp(1i*phi);
% figure;
% plot(imag(complexCoords),real(complexCoords),'k','lineWidth',10);
% axis equal
% xlim([-1 1]*imageSize(1)/2);
% ylim([-1 1]*imageSize(2)/2);

% make bitmap image
imageCenter = imageDims/2+0.5;
sigma = 0.056; % bandpass space constant in degrees of visual angle (see eq. 2 in Wilson & Wilkinson (2002))
for x = 1:imageDims(1)
  for y = 1:imageDims(2)
    complexCoords = (y-imageCenter(2) + 1i*(x-imageCenter(1))) / min(imageDims/2) * min(imageSize/2);
    r = abs(complexCoords);
    phi = angle(complexCoords);
    % get contrast value at pixel using eq. 2 from Wilson & Wilkinson (2002)
    pixelValue(y,x) = (1 - 4*(r-radius(phi)).^2/sigma^2 + 4/3*(r - radius(phi)).^4/sigma^4 ) * exp(-(r-radius(phi)).^2/sigma^2);
  end
end

% display bitmap
figure('name',sprintf('Harmonics = %s   A = %s   phi = %s',mat2str(radialHarmonics),mat2str(radialAmplitudesDeg),mat2str(radialPhasesRad)));
imagesc(pixelValue,[-1 1]);
colormap('gray');
set(gca,'YDir','normal');
axis equal
xlim([1 imageDims(1)]);
ylim([1 imageDims(2)]);
colorbar;

% save bitmap
imwrite(flipud((pixelValue+1)/2),sprintf('radialStim_H%s_A%s_P%s.png',sprintf('-%d',radialHarmonics),sprintf('-%d',radialAmplitudes),sprintf('-%d',radialPhases)));
