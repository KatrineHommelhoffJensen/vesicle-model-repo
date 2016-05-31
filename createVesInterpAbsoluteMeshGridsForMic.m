
% Extract stack of vesicle images from micrograph
% sProfileType: Decides vesicle profile (2D, 1DA, 1DR, 1DAR)
% vVesicleR, vVesicleCntX, vVesicleCntY: vesicle positions in micrograph
% bNormalize: Should images be normalized (1/0)
% bWindow: Should images be windowed (1/0)


function [Xabs, Yabs, mVesicleImWinStackInterp, mVesicleImBGWinStackInterp, Rabs] = createVesInterpAbsoluteMeshGridsForMic(sProfileType, vVesicleCntX, vVesicleCntY, vVesicleR, stParameters, mMicrographBinaryVesicles)
    iNrOfVesicles = length(vVesicleR);

    
    % Notice: We will never need mVesicleImBGWinStackInterp - i.e.
    % background windows in interpolated form, as this structure is only
    % used for normalizing raw images. In this case it is only used for
    % illustration (CAR)
    
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
        
        % How to produce a stack of Tukey windows, all of similar diameter
        % but with different steepness (depending of how much the vesicle
        % image was scaled)
        % 0) Stack of centered, small radius-exact circles on black
        %       (vVesicleR(IDX(:))>R(:).*vVesicleR(IDX(:)))
        % 1) Stack of centered, white circles on black (window): 
        %       (dBeta.*vVesicleR(IDX(:))>R(:).*vVesicleR(IDX(:)))
        % 2) Stack of white rings (width = space from circles above towards
        % image boundary, width defined by alpha) on black:
        %       (dBeta.*vVesicleR(IDX(:))<=R(:).*vVesicleR(IDX(:)) & -dBeta.*vVesicleR(IDX(:))+R(:).*vVesicleR(IDX(:))<1/dAlpha); 
        % 3) Stack of black/withe cosine surface from center, different
        % from each image:
        %       (0.5*(cos(2*pi*(0.5*dAlpha)*(R(:).*vVesicleR(IDX(:))-dBeta.*vVesicleR(IDX(:))))+1))
        mVesicleImWinStackInterp = reshape((stParameters.dBeta.*vVesicleR(IDX(:))>XrelR(:).*vVesicleR(IDX(:)))+(stParameters.dBeta.*vVesicleR(IDX(:))<=XrelR(:).*vVesicleR(IDX(:)) & -stParameters.dBeta.*vVesicleR(IDX(:))+XrelR(:).*vVesicleR(IDX(:))<1/stParameters.dAlpha).*(0.5*(cos(2*pi*(0.5*stParameters.dAlpha)*(XrelR(:).*vVesicleR(IDX(:))-stParameters.dBeta.*vVesicleR(IDX(:))))+1)),size(IDX));
        
        % ---------------------------------------------------------------
        % 2) Produce BG windows for both interpolated and raw images
        % ---------------------------------------------------------------
        
        
        mVesicleImBGWinStackInterp = interpolateImagePixels(mMicrographBinaryVesicles, Xabs, Yabs);

        % Return to binary values after interpolation
        mVesicleImBGWinStackInterp(mVesicleImBGWinStackInterp(:) >= 0.5) = 1;
        mVesicleImBGWinStackInterp(mVesicleImBGWinStackInterp(:) < 0.5) = 0;
        % Smooth centered window
        
        
        
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
