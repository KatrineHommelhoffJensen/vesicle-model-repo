function [mImageClean] = cleanVesicleImage(mImage)
    
    % Removes Inf and NaN
    
    mImageClean = mImage;
    
    if length(size(mImageClean)) ~= 2
        error('Can only be used on 2d images');
    end
    
    if sum(isinf(mImageClean(:))) > 0
        % Replace with closest non-inf value
        [rows, cols] = ind2sub(size(mImageClean), find(isinf(mImageClean)));
        for i=1:length(rows)
            if size(mImageClean, 1) > rows(i) && ~isinf(mImageClean(rows(i)+1, cols(i)))
                mImageClean(rows(i), cols(i)) = mImageClean(rows(i)+1, cols(i));
            elseif rows(i) > 1 && ~isinf(mImageClean(rows(i)-1, cols(i)))
                mImageClean(rows(i), cols(i)) = mImageClean(rows(i)-1, cols(i));
            elseif size(mImageClean, 2) > cols(i) && ~isinf(mImageClean(rows(i), cols(i)+1))
                mImageClean(rows(i), cols(i)) = mImageClean(rows(i), cols(i)+1);
            elseif cols(i) > 1 && ~isinf(mImageClean(rows(i), cols(i)-1))
                mImageClean(rows(i), cols(i)) = mImageClean(rows(i), cols(i)-1);
            else
                mImageClean(rows(i), cols(i)) = 0;
            end
        end
    end
    
    
    mImageClean(isnan(mImageClean(:))) = 0;
    
end