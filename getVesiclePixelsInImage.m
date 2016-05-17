% Creates an image with 1's in pixels belonging to a vesicle, 0's otherwise.
% Defines which pixels belong to a vesicle, given its floating point
% center and radius in the image.
% A pixel belongs to the vesicle if the center point is within radius.

function [mBinaryVesicleImage] = getVesiclePixelsInImage(iImDim, dVesicleCntX, dVesicleCntY, dVesicleR)
 
    mBinaryVesicleImage = zeros(iImDim);
   
    for xIdx = 1:iImDim(1)
        for yIdx = 1:iImDim(2)
            if distPointPoint([dVesicleCntX, dVesicleCntY], [xIdx-0.5, yIdx-0.5]) <= dVesicleR
                mBinaryVesicleImage(xIdx, yIdx) = 1;
            end
        end
    end
        
    
end