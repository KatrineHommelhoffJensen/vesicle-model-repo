%SINUSOIDSHIFTVESICLEIMAGE Function that shifts polar coordinate vesicle
%image mVesImage horisontally, according the the sinusoidal curve specified
%in mAmplitudes, and returns the result in mShiftedVesImage.
%
%   Parameters include:
%
%   'mVesImage'             Vesicle image to be shifted
%
%   'mgVesImageRadius'      Meshgrid for radius in interpolated image
%
%   'mgVesImageAngle'       Meshgrid for angle in interpolated image
%
%   'vRInner'               Vesicle image inner radius
%
%   'mAmplitudes'           Sinusoidal curve for the horisontal shifts
%
         

function [mShiftedVesImage] = sinusoidShiftVesicleImage(mVesImage, mgVesImageRadius, mgVesImageAngle, vRInner, mAmplitudes)
    
    iCurFreqIdx = size(mAmplitudes, 1);

    modifiedRadius = zeros(size(mgVesImageRadius));
    R = size(mVesImage,1);
    mShift = zeros(size(mVesImage,1), iCurFreqIdx);
    for f = 1:iCurFreqIdx
        mShift(:,f) = mAmplitudes(f, 1)*sin(2*pi*((1:size(mVesImage,1))')*f/R)+...
                          mAmplitudes(f, 2)*cos(2*pi*((1:size(mVesImage,1))')*f/R);
    end
    totalShift = sum(mShift,2)*ones(1,size(mVesImage,2));                   
    modifiedRadius(:,1:vRInner) = mgVesImageRadius(:,1:vRInner).*(vRInner-totalShift(:,1:vRInner))/vRInner;
    modifiedRadius(:,(vRInner+1):end) = mgVesImageRadius(:,(vRInner+1):end) -totalShift(:,(vRInner+1):end);
    mShiftedVesImage = reshape(interp2(mVesImage, modifiedRadius(:), mgVesImageAngle(:),'linear',0),size(mVesImage));

end
