
% Uses relative meshgrids (R, A) and information about actual location
% and radius (vVesicleX, vVesicleY, vVesicleR) to create actual meshgrids
% to interpolate the given data: 

% * R, A: relative meshgrids, can be both in Cartesian (XrelR, YrelA) and
% Polar coordinates (Rrel, Arel), output from createVesInterpRelativeMeshGrids()
% * dRadiusMeshgrid: the radius used to build the meshgrids
% * vVesicleR, vVesicleX, vVesicleY: The list of radia, x-, and y center
% position of the vesicle or vesicles in an image, later to be interpolated
% from via interpolateImagePixels()


function [Xabs, Yabs] = createVesInterpAbsoluteMeshGrids(dToVesRadius, mToVesR, mToVesA, vFromVesX, vFromVesY, vFromVesR, iVesShapeInterpMethod, dWallThickness)

    if iVesShapeInterpMethod == 1
        
        %Xabs = r(IDX(:)).*R(:).*cos(A(:)) + x(IDX(:));
        %Yabs = r(IDX(:)).*R(:).*sin(A(:)) + y(IDX(:));
        
        Xabs = vFromVesR.*mToVesR(:).*cos(mToVesA(:)) + vFromVesX;
        Yabs = vFromVesR.*mToVesR(:).*sin(mToVesA(:)) + vFromVesY;
        
    elseif iVesShapeInterpMethod == 2 || iVesShapeInterpMethod == 3  || iVesShapeInterpMethod == 4

%         RMidMax = dRadiusMeshgrid;
%         RInMax = RMidMax - dWallThickness/2;
%         RInIDX = r(IDX(:)) - dWallThickness/2;
%         
%         rPixInterval1 = (RMidMax/RInMax) * R(:) .* RInIDX;
%         rPixInterval2 = RInIDX+R(:).*RMidMax-RInMax;
%         rPix = (R(:)<=(RInMax/RMidMax)).*rPixInterval1+(R(:)>(RInMax/RMidMax)).*rPixInterval2;
% 
%         Xabs = rPix.*cos(A(:))+x(IDX(:));    
%         Yabs = rPix.*sin(A(:))+y(IDX(:));
        
        RMidMax = dToVesRadius;
        RInMax = RMidMax - dWallThickness/2;
        ROutMax = RMidMax + dWallThickness/2;
        vFromVesRIn = vFromVesR - dWallThickness/2;
        vFromVesROut = vFromVesR + dWallThickness/2;
        

        % New: Make 3 pixel intervals, example:
        % Pixel positions in ToVes: [1, RInMax, RMidMax, ROutMax, 205] = [1, 32.5, 60, 87.5, 205]
        % Relative position in ToVes: [0, RInMax/RMidMax, 1, ROutMax/RMidMax, 1.7] = [0, 0.54, 1, 1.46, 1.7]
        
        
        % 1) pixels inside wall
        % In rPixInterval1, if we pick out relative value [0 to 0.54], it
        % will contain the scaling of pixel [1 to vFromVesRIn]
        rPixInterval1 = (RMidMax/RInMax)*mToVesR(:).*vFromVesRIn;
        rPix = (mToVesR(:)<=(RInMax/RMidMax)).*rPixInterval1;
        % 2) pixels on wall
        rPixInterval2 = vFromVesRIn + (mToVesR(:).*RMidMax) - RInMax;
        rPix = rPix + (mToVesR(:)>(RInMax/RMidMax)).*rPixInterval2;
        %rPix = rPix + (mToVesR(:)>(RInMax/RMidMax) & mToVesR(:)<=(ROutMax/RMidMax)).*rPixInterval2;
        % 3) pixels outside wall
        % In rPixInterval3, if we pick out relative value [1.46 to 1.7], it
        % will contain the scaling of pixel [vFromVesROut to 1.7*vFromVesR]
        %rPixInterval3 = (RMidMax/ROutMax)*mToVesR(:).*vFromVesROut;
        %rPix = rPix + (mToVesR(:)>(ROutMax/RMidMax)).*rPixInterval3;

        Xabs = rPix.*cos(mToVesA(:)) + vFromVesX;    
        Yabs = rPix.*sin(mToVesA(:)) + vFromVesY;
    else
        error('Invalid shape interpolation method!');
    end
    

    
    
end    
