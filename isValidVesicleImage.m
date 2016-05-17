function [isValid] = isValidVesicleImage(mImage)
    
    isValid = 0;
    if size(mImage, 1) > 1 && ~isnan(sum(mImage(:)))
        if ~(sum(mImage(1,:)) == 0 && sum(mImage(end,:)) == 0 && sum(mImage(:,1)) == 0 && sum(mImage(:,end)) == 0)
            isValid = 1;
        end
    end
    
end