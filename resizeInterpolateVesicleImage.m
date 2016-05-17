
% Resizes vesicle image while respecting interpolation rules tied to the 
% shape interpolation method iVesShapeInterpMethod  

function [mImInterp] = resizeInterpolateVesicleImage(iVesShapeInterpMethod, dWallThickness, mImOrig, dOrigR, dOrigCntX, dOrigCntY, mVesXrelR, mVesYrelA, dInterpR)

    [Xabs, Yabs] = createVesInterpAbsoluteMeshGrids(dInterpR, mVesXrelR, mVesYrelA, dOrigCntX, dOrigCntY, dOrigR, iVesShapeInterpMethod, dWallThickness);
    Xabs = reshape(Xabs, size(mVesXrelR,1), size(mVesXrelR,2));
    Yabs = reshape(Yabs, size(mVesXrelR,1), size(mVesXrelR,2));
    mImInterp = interpolateImagePixels(mImOrig, Xabs, Yabs);

%     if iVesShapeInterpMethod == 1
%         
%         
%         %iDestSize = size(mVesXrelR,1);
%         %mImInterp = imresize(mImOrig, [iDestSize iDestSize], 'bicubic');
%         
%         % We interpolate the image mComp to the size/radius according to
%         % the meshgrids mVesXrelR, mVesYrelA
%         Xabs = dOrigR.*mVesXrelR(:).*cos(mVesYrelA(:)) + dOrigCntX;
%         Yabs = dOrigR.*mVesXrelR(:).*sin(mVesYrelA(:)) + dOrigCntY;
%         Xabs = reshape(Xabs, size(mVesXrelR,1), size(mVesXrelR,2));
%         Yabs = reshape(Yabs, size(mVesXrelR,1), size(mVesXrelR,2));
%         mImInterp = interpolateImagePixels(mImOrig, Xabs, Yabs);
%         
%         [Xabs, Yabs] = createVesInterpAbsoluteMeshGrids(dInterpR, mVesXrelR, mVesYrelA, dOrigCntX, dOrigCntY, dOrigR, iVesShapeInterpMethod, dWallThickness);
%         Xabs = reshape(Xabs, size(mVesXrelR,1), size(mVesXrelR,2));
%         Yabs = reshape(Yabs, size(mVesXrelR,1), size(mVesXrelR,2));
%         mImInterp2 = interpolateImagePixels(mImOrig, Xabs, Yabs);
%         
%         if sum(mImInterp(:)-mImInterp2(:)) ~= 0
%             error('Error in interpolation');
%         end
%         
%     elseif iVesShapeInterpMethod == 2
% 
%         
%         
%     else
%         error('Invalid shape interpolation method!');
%     end
    
end    
