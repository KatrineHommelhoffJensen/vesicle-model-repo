
function [Xabs, Yabs, mVesicleImWinStackInterp, mVesicleImBGWinStackInterp, Rabs] = createVesInterpAbsoluteMeshGridsForMic(sProfileType, vVesicleCntX, vVesicleCntY, vVesicleR, stParameters, mMicrographBinaryVesicles)
    iNrOfVesicles = length(vVesicleR);

    mVesicleImBGWinStackInterp = [];
    Rabs = [];
    
    if strcmp(sProfileType, 'CAR')
        
        % Cartesian coordinates
        
        [Xrel, Yrel, IDX, XrelR, YrelA] = createVesInterpRelativeMeshGrids(sProfileType, stParameters.dMaxR, stParameters.dMaxRR, iNrOfVesicles);
        
        [Xabs, Yabs] = createVesInterpAbsoluteMeshGrids(stParameters.dMaxR, XrelR, YrelA, vVesicleCntX(IDX(:)), vVesicleCntY(IDX(:)), vVesicleR(IDX(:)), stParameters.iVesShapeInterpMethod, stParameters.dWallThickness);
        Xabs = reshape(Xabs, size(Xrel));
        Yabs = reshape(Yabs, size(Yrel));
        
        % ---------------------------------------------------------------
        % 1) Produce signal windows for both interpolated and raw images
        % ---------------------------------------------------------------
        
        mVesicleImWinStackInterp = reshape((stParameters.dBeta.*vVesicleR(IDX(:))>XrelR(:).*vVesicleR(IDX(:)))+(stParameters.dBeta.*vVesicleR(IDX(:))<=XrelR(:).*vVesicleR(IDX(:)) & -stParameters.dBeta.*vVesicleR(IDX(:))+XrelR(:).*vVesicleR(IDX(:))<1/stParameters.dAlpha).*(0.5*(cos(2*pi*(0.5*stParameters.dAlpha)*(XrelR(:).*vVesicleR(IDX(:))-stParameters.dBeta.*vVesicleR(IDX(:))))+1)),size(IDX));
        
        % ---------------------------------------------------------------
        % 2) Produce BG windows for both interpolated and raw images
        % ---------------------------------------------------------------
        
        
        mVesicleImBGWinStackInterp = interpolateImagePixels(mMicrographBinaryVesicles, Xabs, Yabs);

        mVesicleImBGWinStackInterp(mVesicleImBGWinStackInterp(:) >= 0.5) = 1;
        mVesicleImBGWinStackInterp(mVesicleImBGWinStackInterp(:) < 0.5) = 0;
        
        
    elseif strcmp(sProfileType, 'POL')
        
        % Polar coordinates
        
        [Rrel, Arel, IDX] = createVesInterpRelativeMeshGrids(sProfileType, stParameters.dMaxR, stParameters.dMaxRR, iNrOfVesicles);
        
        [Xabs, Yabs] = createVesInterpAbsoluteMeshGrids(stParameters.dMaxR, Rrel, Arel, vVesicleCntX(IDX(:)), vVesicleCntY(IDX(:)), vVesicleR(IDX(:)), stParameters.iVesShapeInterpMethod, stParameters.dWallThickness);
        Rabs = vVesicleR(IDX(:)).*Rrel(:);
        
        Xabs = reshape(Xabs, size(IDX));
        Yabs = reshape(Yabs, size(IDX));
        Rabs = reshape(Rabs, size(IDX));
        
        mVesicleImWinStackInterp = reshape((stParameters.dBeta.*vVesicleR(IDX(:))>Rrel(:).*vVesicleR(IDX(:)))+(stParameters.dBeta.*vVesicleR(IDX(:))<=Rrel(:).*vVesicleR(IDX(:)) & -stParameters.dBeta.*vVesicleR(IDX(:))+Rrel(:).*vVesicleR(IDX(:))<1/stParameters.dAlpha).*(0.5*(cos(2*pi*(0.5*stParameters.dAlpha)*(Rrel(:).*vVesicleR(IDX(:))-stParameters.dBeta.*vVesicleR(IDX(:))))+1)),size(IDX)); 
    
    else
        error('Unknown vesicle profile type');
    end

end    
