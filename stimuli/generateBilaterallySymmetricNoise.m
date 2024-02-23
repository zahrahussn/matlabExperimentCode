
% Function to generate bilaterally symmetric noise texture
function noiseTexture = generateBilaterallySymmetricNoise(imageSize, frequencyCutoff)
    % Generate random phase angles
    phaseAngles = rand(imageSize, imageSize) * 2 * pi;
    
    % Set high-frequency components to zero
    [X, Y] = meshgrid(1:imageSize, 1:imageSize);
    highFrequencyMask = sqrt((X - imageSize/2).^2 + (Y - imageSize/2).^2) > frequencyCutoff*imageSize/2;
    phaseAngles(highFrequencyMask) = 0;
    
    % Generate noise texture from phase angles
    noiseTexture = ifft2(exp(1i * phaseAngles), 'symmetric');
end

