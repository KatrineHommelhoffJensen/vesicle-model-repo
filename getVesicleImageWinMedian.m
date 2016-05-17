

function [dWinMedian] = getVesicleImageWinMedian(mImage, mImageWindow, bHardWin)
     
    mImageWin = mImage.*mImageWindow;
    
    if bHardWin
        mImageWinValues = mImageWin(find(mImageWin ~= 0));
        dWinMedian = median(mImageWinValues(:));
    end
    
    % TODO: soft window
        
end