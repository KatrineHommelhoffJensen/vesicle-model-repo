% Creates a micrograph with 1's in pixels belonging to a vesicle, 0's otherwise. 

function [mBinaryVesicleMicrograph] = createBinaryVesicleMicrograph(iMicDim, dVesicleCntX, dVesicleCntY, dVesicleR, dBeta)
 
    iNrOfVesicles = length(dVesicleCntX);
    mBinaryVesicleMicrograph = zeros(iMicDim);
   
    for vesicleIdx = 1:iNrOfVesicles
        
        x = dVesicleCntX(vesicleIdx);
        y = dVesicleCntY(vesicleIdx);
        r = dVesicleR(vesicleIdx) * dBeta;
        
        % Box out image and make sure we don't exceed micrograph boundary
        xMin = max(floor(x - r), 1);
        xMax = min(ceil(x + r), iMicDim(1));
        yMin = max(floor(y - r), 1);
        yMax = min(ceil(y + r), iMicDim(2));
        
        
        % Notice: following Fred's conventions for vesicle center coord
        % Notice also: only transfer true pixels
        im = getVesiclePixelsInImage([length(yMin:yMax), length(xMin:xMax)], y-yMin+1, x-xMin+1, r);
        for i=1:size(im,1)
            for j=1:size(im,2)
                if im(i,j) > 0
                    mBinaryVesicleMicrograph(i+yMin-1, j+xMin-1) = 1;
                end
            end
        end
        
    end
    
end