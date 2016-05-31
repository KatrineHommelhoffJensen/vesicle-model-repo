
% Interpolates pixel values from image mImOrig to image mImInterpStack
% according to the absolute meshgrids mInterpX and mInterpY. 
% Used for both micrographs and vesicle images.

function [mImInterpStack] = interpolateImagePixels(mImOrig, mInterpX, mInterpY)

    % mInterpX and mInterpY meshgrid based interpolation structures such 
    % that the following pixel values are equivalent:
    % * mImInterpStack(x, y, n)  
    % * mImOrig(mInterpX(x, y, n), mInterpY(x, y, n))
    
    mImInterpStack = interp2(mImOrig, mInterpX, mInterpY, 'bicubic'); 
    mImInterpStack(isnan(mImInterpStack(:))) = 0;
    


end    
