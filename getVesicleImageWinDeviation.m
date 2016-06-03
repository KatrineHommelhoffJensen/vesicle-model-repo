%GETVESICLEIMAGEWINDEVIATION Fnction that calculates the Median Absolute
%Deviation in a vesicle image, area specified by a window 

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