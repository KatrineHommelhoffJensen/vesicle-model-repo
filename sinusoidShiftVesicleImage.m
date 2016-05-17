function [mShiftedVesImage] = sinusoidShiftVesicleImage(mVesImage, mgVesImageRadius, mgVesImageAngle, vRInner, mAmplitudes, iCurFreqIdx)
    
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
    
    %TEST display curve
%     vShiftsSinusoid = zeros(R,1);
%     for iRowIdx=1:R
%          for f = 1:iCurFreqIdx
%              vShiftsSinusoid(iRowIdx) = vShiftsSinusoid(iRowIdx) + mAmplitudes(f,1)*sin(2*pi*iRowIdx*f/R) + mAmplitudes(f,2)*cos(2*pi*iRowIdx*f/R);
%          end
%      end
%      %vShifts = round(vShiftsSinusoid);
%      figure; hold on;ylim([-60 60]);view([90 90]);axis off;plot(-vShiftsSinusoid(:), 'b-');
    
end
