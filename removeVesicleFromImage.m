
% Handles subtraction of a vesicle structure from an image, including
% projecting onto the model components and merging the vesicle and
% background signal


% stVesicleModel: The model to be used for subtraction
% mPrincCompReg, mComponents: Model components

% mImBox: Boxed out image pixels from micrograph (not normalized!)
% mImWin: Vesicle signal window for boxed out image
% mImBGWin: Background signal window for boxed out image
% dImageMean, dStd: Normalization constants
% mImNormInterp: mImBox image intensity normalized and interpolated
% mImNormInterpWin: Vesicle signal window for interpolated image

% mImBoxSub: Returned vesicle subtracted image



function [mImBoxSub] = removeVesicleFromImage(stVesicleModel, iPrincCompReg, mImBox, mImWin, mImHardWin, mImHardBGWin, mImBoxNorm, mImNormInterp, mImNormInterpWin, mImNormInterpPOLWindowed, mVesXrelR, mVesYrelA, dVesRadius, dImageMean, dStd)
    
    if ~isValidVesicleImage(mImBoxNorm) 
        error('Invalid vesicle image');
    end
    if ~isValidVesicleBGImage(mImHardBGWin) 
        error('Invalid vesicle background image');
    end
        
    mImBGWin = abs(mImWin - 1);
    
    
    mImBoxSub = projectImageOnModel(stVesicleModel, iPrincCompReg, (mImBoxNorm.*mImWin), mImNormInterpPOLWindowed, 1, mVesXrelR, mVesYrelA, dVesRadius, 1, 1, mImBoxNorm, mImBox, mImWin, mImBGWin, mImHardWin, mImHardBGWin, dImageMean, dStd);
    

    mImBoxSub = reverseNormalizeVesicleImage(mImBoxSub, dImageMean, dStd);
    mImBoxSub = (mImBoxSub.*mImWin) +  (mImBox.*mImBGWin);
    
    
end

