% Define parameters
imageSize = 256; % Size of the image
frequencyCutoff = 0.1; % Frequency cutoff for bandlimited noise
phaseShiftAmount = 0.5; % Amount of phase shift (in radians)

% Generate bilaterally symmetric noise texture
noiseTexture = generateBilaterallySymmetricNoise(imageSize, frequencyCutoff);

% Split the texture into left and right halves
leftHalf = noiseTexture(:, 1:imageSize/2);
rightHalf = noiseTexture(:, (imageSize/2 + 1):end);

% Apply phase shift to the right half
rightHalfShifted = applyPhaseShift(rightHalf, phaseShiftAmount);

% Combine the halves
combinedTexture = [leftHalf, rightHalfShifted];

% Display the original and modified textures
figure;
subplot(1, 2, 1);
imshow(noiseTexture);
title('Original Texture');
subplot(1, 2, 2);
imshow(combinedTexture);
title('Modified Texture');
