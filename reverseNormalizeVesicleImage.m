% REVERSENORMALIZEVESICLEIMAGE Undos vesicle image normalization according
% to a method specified by iVesImNormMethod 

function [mImage] = reverseNormalizeVesicleImage(mImageNorm, dImageMean, dStd)
 
    
        
        mImage = mImageNorm * dStd;
        mImage = mImage + dImageMean;
        
   
    
end