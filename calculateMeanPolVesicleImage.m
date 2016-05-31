%CALCULATEMEANPOLVESICLEIMAGE Function that calculates and returns the mean
%vesicle from a set of vesicle images in the polar coordinates. The
%windowed, mean vesicle, mImMean, is returned along with the aligned
%vesicle image set mVesImageSetShiftAligned
%
%   Parameters include:
%
%   'stParameters'          Model parameters created in 'getParameters.m'
%
%   'mVesImageSet'          Stack of vesicle images 
%
%   'mVesImageWinSet'    Stack of windows for vesicle images
%

function [mImMean, mVesImageSetShiftAligned] = calculateMeanPolVesicleImage(stParameters, mVesImageSet, mVesImageWinSet)

    dRadiusInner = stParameters.dMaxR - stParameters.dWallThickness/2;

    mVesImageSetShiftAligned = [];
    
    mVesImageSetWindowed = mVesImageSet.*mVesImageWinSet;
    mImMean = mean(mVesImageSetWindowed, 3);
    

        
    if stParameters.iVesShapeInterpMethod == 2

        mVesImageSetShiftAligned = mVesImageSet;
        
        for itShift = 1:stParameters.iShiftIterations

            for iVesIdx = 1:size(mVesImageSet,3)
                [vShifts, mVesImageShiftAligned] = circshiftAlignVesicleImage(mVesImageSetShiftAligned(:,:,iVesIdx), mImMean, stParameters.iMaxShiftFrequencies, stParameters.iMaxShiftAmplitude, dRadiusInner,0);
              
                mVesImageSetShiftAligned(:,:,iVesIdx) = mVesImageShiftAligned;
            end
            
            mImMean = zeros(size(mImMean)); 

            for iVesIdx = 1:size(mVesImageSet,3)
                mImMean = mImMean + mVesImageSetShiftAligned(:,:,iVesIdx).*mVesImageWinSet(:,:,iVesIdx);%TODO TJEK
                
                if itShift == stParameters.iShiftIterations
                    % return windowed set
                    mVesImageSetShiftAligned(:,:,iVesIdx) = mVesImageSetShiftAligned(:,:,iVesIdx).*mVesImageWinSet(:,:,iVesIdx);
                end
            end
            mImMean = mImMean/size(mVesImageSet,3);
            
        end
        
    end
   
end