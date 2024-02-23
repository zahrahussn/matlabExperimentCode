% Function to apply phase shift to an image
function shiftedImage = applyPhaseShift(image, phaseShiftAmount)
    % Compute the Fourier transform of the image
    imageFft = fftshift(fft2(image));

    % Compute smoothly varying phase shift
    phaseShift = linspace(0, phaseShiftAmount, cols);
    phaseShiftMatrix = repmat(phaseShift, rows, 1);
    
    % Apply phase shift to one half
    shiftedImage = image .* exp(1i * phaseShiftMatrix); 
    
%     Apply phase shift
%     [rows, cols] = size(image);
%     [X, Y] = meshgrid(1:cols, 1:rows);
%     phaseShift = exp(1i * phaseShiftAmount * (X - cols/2));
%     shiftedImageFft = imageFft .* phaseShift;
    
    % Compute the inverse Fourier transform
    shiftedImage = real(ifft2(ifftshift(shiftedImageFft)));
end