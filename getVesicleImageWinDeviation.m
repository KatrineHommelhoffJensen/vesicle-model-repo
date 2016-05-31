% Returns the deviation of the image inside the window

% mImage: image to be investigated
% iVesImNormMethod: normalization method
% mImageWindow: inside which the image values should be inspected
% mImageBGWindow: background values (could be equal to mImageWindow)


function [dDev, dBGMean] = getVesicleImageWinDeviation(mImage, mImageWindow, mImageBGWindow)
    
    if ~isValidVesicleImage(mImage)
        error('Image invalid'); 
    end
    
    if ~isValidVesicleBGImage(mImageBGWindow)
        error('BG image invalid');
    end
    

        
    % Median Absolute Deviation

    mImageBGWin = mImage.*mImageBGWindow;
    mImageBGValues = mImageBGWin(find(mImageBGWin ~= 0));
    dImageBGMedian = median(mImageBGValues(:));

    mImageWin = mImage.*mImageWindow;
    mImageWinValues = mImageWin(find(mImageWin ~= 0));
    dDev = median(abs(mImageWinValues(:) - dImageBGMedian));
    dBGMean = dImageBGMedian;        
        

end