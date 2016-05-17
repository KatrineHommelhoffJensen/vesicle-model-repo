function [isValid] = isValidVesicleBGImage(mImage)
    
    isValid = 0;
    if size(mImage, 1) > 1 && ~isnan(sum(mImage(:))) && sum(mImage(:)) > 20
        isValid = 1;
    end
    
end