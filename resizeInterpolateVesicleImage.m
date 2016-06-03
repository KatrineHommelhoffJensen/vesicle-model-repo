% RESIZEINTERPOLATEVESICLEIMAGE Resizes vesicle image while respecting
% interpolation rules tied to the shape interpolation method
% iVesShapeInterpMethod   

function [mImInterp] = resizeInterpolateVesicleImage(iVesShapeInterpMethod, dWallThickness, mImOrig, dOrigR, dOrigCntX, dOrigCntY, mVesXrelR, mVesYrelA, dInterpR)

    [Xabs, Yabs] = createVesInterpAbsoluteMeshGrids(dInterpR, mVesXrelR, mVesYrelA, dOrigCntX, dOrigCntY, dOrigR, iVesShapeInterpMethod, dWallThickness);
    Xabs = reshape(Xabs, size(mVesXrelR,1), size(mVesXrelR,2));
    Yabs = reshape(Yabs, size(mVesXrelR,1), size(mVesXrelR,2));
    mImInterp = interpolateImagePixels(mImOrig, Xabs, Yabs);
    
end    
