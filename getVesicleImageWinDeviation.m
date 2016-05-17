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
    
%     if iVesImNormMethod == 2
%         
%         % Standard Deviation (mean based)
%         
%         mImageBGWin = mImage.*mImageBGWindow;
%         dImageBGMean = sum(mImageBGWin(:))/sum(mImageBGWindow(:));
%         
%         mImageNorm = mImageWindow.*(mImage - dImageBGMean).^2;
%         dDev = sqrt(sum(mImageNorm(:))/sum(mImageWindow(:)));
%         dBGMean = dImageBGMean;
%         
%     elseif iVesImNormMethod == 3
        
        % Median Absolute Deviation
        
        mImageBGWin = mImage.*mImageBGWindow;
        mImageBGValues = mImageBGWin(find(mImageBGWin ~= 0));
        dImageBGMedian = median(mImageBGValues(:));
        
        mImageWin = mImage.*mImageWindow;
        mImageWinValues = mImageWin(find(mImageWin ~= 0));
        dDev = median(abs(mImageWinValues(:) - dImageBGMedian));
        dBGMean = dImageBGMedian;        
        
%     elseif iVesImNormMethod == 4
        
        % A mixed SD/MAD with different approach for vesicle and background
        % signal
        
%         % DOES NOT WORK
%         
%         mImageBGWin = mImage.*mImageBGWindow;
%         mImageBGValues = mImageBGWin(find(mImageBGWin ~= 0));
%         dImageBGMedian = median(mImageBGValues(:));
%         
%         if sum(mImageWindow(:) - mImageBGWindow(:)) == 0
%             
%             % background signal deviation (MAD)
%             
%             mImageWin = mImage.*mImageWindow;
%             mImageWinValues = mImageWin(find(mImageWin ~= 0));
%             dDev = median(abs(mImageWinValues(:) - dImageBGMedian));
%             dDev = dDev * 1.4826; % to compare with vesicle signal
%             dBGMean = dImageBGMedian;
%             
%         else
%             
%             % vesicle signal deviation (SD-MAD)
%             
%             mImageNorm = mImageWindow.*(mImage - dImageBGMedian).^2;
%             dDev = sqrt(sum(mImageNorm(:))/sum(mImageWindow(:)));
%             dBGMean = dImageBGMedian;
%             
%         end



%         mImageBGWin = mImage.*mImageBGWindow;
%         mImageBGValues = mImageBGWin(find(mImageBGWin ~= 0));
%         dImageBGMedian = median(mImageBGValues(:));
%         
%         mImageWin = mImage.*mImageWindow;
%         mImageWinValues = mImageWin(find(mImageWin ~= 0));
%         dDev = mean(abs(mImageWinValues(:) - dImageBGMedian));
%         dBGMean = dImageBGMedian;

        % TEST: MAD based but micrographs have been shifted into positive
        % space first...
        
%         mImageBGWin = mImage.*mImageBGWindow;
%         mImageBGValues = mImageBGWin(find(mImageBGWin ~= 0));
%         dImageBGMedian = median(mImageBGValues(:));
%         
%         mImageWin = mImage.*mImageWindow;
%         mImageWinValues = mImageWin(find(mImageWin ~= 0));
%         dDev = median(abs(mImageWinValues(:) - dImageBGMedian));
%         dBGMean = dImageBGMedian; 
%         
%          
%         
%     else
%         error('Invalid iVesImNormMethod');
%     end
    
end