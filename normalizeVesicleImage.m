% NORMALIZEVESICLEIMAGE Normalizes a vesicle image according to a method
% specified by iVesImNormMethod 
% Output:
% mImageNorm: The normalized image
% dImageMean: The mean or median, that has been subtracted
% dStd: The variance, which has been divided
% dStdNoise: An estimate of the background noise, which is to be used for
% error boundary estimation on the model error surfaces

function [mImageNorm, dImageMean, dStd, dStdNoise] = normalizeVesicleImage(mImage, mImageVesWindow, mImageBGWindow, bFinalWindowing)
 
    
        % Mean based local image normalization
        
        % Subtracts the background noise and normalizes the standard
        % deviation of the vesicle signal
        
        if nargin < 4
            error('Missing background window');
        end
        
        

        [dStd, dImageMean] = getVesicleImageWinDeviation(mImage, mImageVesWindow, mImageBGWindow);
        [dStdNoise] = getVesicleImageWinDeviation(mImage, mImageBGWindow, mImageBGWindow);
        
            
            if bFinalWindowing
                % Result is a windowed image
                mImageNorm = mImageVesWindow.*(mImage - dImageMean)/dStd;
            else
                mImageNorm = (mImage - dImageMean)/dStd;
            end


    
end