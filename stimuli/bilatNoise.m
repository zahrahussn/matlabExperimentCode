% Define parameters
width = 256; % Width of the image
height = 256; % Height of the image
cycles_per_image = 2 + rand() * 2; % Randomly select cycles per image between 2 and 4
cutoff_frequency = cycles_per_image / max(width, height); % Calculate cutoff frequency
%cutoff_frequency = 0.1; % Cutoff frequency for bandlimited noise

% Generate bandlimited noise
[X, Y] = meshgrid(linspace(-1, 1, width), linspace(-1, 1, height));
radius = sqrt(X.^2 + Y.^2);
bandlimited_noise = ifft2(fftshift(randn(height, width)) .* (radius <= cutoff_frequency));

% Ensure the noise is real-valued
bandlimited_noise = real(bandlimited_noise);

% Create bilaterally symmetric noise patch
symmetric_noise = (bandlimited_noise + flipud(bandlimited_noise)) / 2;

% Display the original and symmetric noise patches
figure;
subplot(1, 2, 1);
imshow(bandlimited_noise, []);
title('Original Bandlimited Noise');
subplot(1, 2, 2);
imshow(symmetric_noise, []);
title('Bilaterally Symmetric Noise');