%CREATEVESINTERPABSOLUTEMESHGRIDS Function that uses relative meshgrids (R,
%A) and information about actual location and radius (vVesicleX, vVesicleY,
%vVesicleR) to create actual meshgrids to interpolate the given data: 
%
%   Parameters include:
%
%   'mToVesR', 'mToVesA'    Relative meshgrids
%
%   'vFromVesR', 'vFromVesX', 'vFromVesY': The list of radia, x-, and y
%                           center position of the vesicles 
%


function [Xabs, Yabs] = createVesInterpAbsoluteMeshGrids(dToVesRadius, mToVesR, mToVesA, vFromVesX, vFromVesY, vFromVesR, iVesShapeInterpMethod, dWallThickness)

    if iVesShapeInterpMethod == 1
        
        Xabs = vFromVesR.*mToVesR(:).*cos(mToVesA(:)) + vFromVesX;
        Yabs = vFromVesR.*mToVesR(:).*sin(mToVesA(:)) + vFromVesY;
        
    else
        
        RMidMax = dToVesRadius;
        RInMax = RMidMax - dWallThickness/2;
        %ROutMax = RMidMax + dWallThickness/2;
        vFromVesRIn = vFromVesR - dWallThickness/2;
        %vFromVesROut = vFromVesR + dWallThickness/2;
             
        % 1) pixels inside wall
        rPixInterval1 = (RMidMax/RInMax)*mToVesR(:).*vFromVesRIn;
        rPix = (mToVesR(:)<=(RInMax/RMidMax)).*rPixInterval1;
        % 2) pixels on wall
        rPixInterval2 = vFromVesRIn + (mToVesR(:).*RMidMax) - RInMax;
        rPix = rPix + (mToVesR(:)>(RInMax/RMidMax)).*rPixInterval2;
        % 3) pixels outside wall
        Xabs = rPix.*cos(mToVesA(:)) + vFromVesX;    
        Yabs = rPix.*sin(mToVesA(:)) + vFromVesY;
    end
    

    
    
end    
