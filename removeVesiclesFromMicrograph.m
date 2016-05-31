
% We assume the micrograph is already median subtracted

% The micrograph has to be read according to the model type

% Modifications since last version:
% * Only subtract directly from micrograph (not stack)
% * New normalization (normalize, interp, window)
% * New subtraction procedure (subtractVesicleFromImage2) with subtraction
% in original representation (CAR, POL, RAD)
% * Only implemented for CAR, POL and RAD

function removeVesiclesFromMicrograph(stVesicleModel, iPrincCompReg, iPrincCompRad, iPrincCompAng, mMicrograph, vVesicleCntX, vVesicleCntY, vVesicleR, bShowFigure, sTestMicText)


    iNrOfVesicles = length(vVesicleR);
    
    % CAR vs POL: 
    % Notice that the micrograph is always interpolated in cartesian
    % coordinates. The only difference is, the basis in polar coordinates
    % will be interpolated into cartesian before projection.
    
    
    mMicrographBinaryVesicles = createBinaryVesicleMicrograph(size(mMicrograph), vVesicleCntX, vVesicleCntY, vVesicleR, stVesicleModel.stParameters.dBetaBGWin);
    mMicrographBinaryVesicles(:) = ~mMicrographBinaryVesicles(:);
    
    % Cartesian coordinates

    [Xabs, Yabs, mVesicleImWinStackInterp] = createVesInterpAbsoluteMeshGridsForMic('CAR', vVesicleCntX, vVesicleCntY, vVesicleR, stVesicleModel.stParameters, mMicrographBinaryVesicles);
    
    % For interpolating polar coordinates (iVesShapeInterpMethod == 3)
    if stVesicleModel.stParameters.iVesShapeInterpMethod == 2
        [Rabs, Aabs, mVesicleImWinStackInterpPOL] = createVesInterpAbsoluteMeshGridsForMic('POL', vVesicleCntX, vVesicleCntY, vVesicleR, stVesicleModel.stParameters, mMicrographBinaryVesicles);
    end
    
    mMicrographVesiclesSubtracted = mMicrograph;
    vesicleIdxRemoved = zeros(iNrOfVesicles,1);

    for vesIdx = 1:iNrOfVesicles

        % Correction of X and Y values to boxed image: Center
        % coordinates should be aligned
        
        [mImagePixelsInMicrograph, mXvesIm, mYvesIm, mImagePixelsVesicleWin, mImagePixelsBGWin, vImagePixelsCropInfo, mVesXrelR, mVesYrelA, mImagePixelsVesicleHardWin] = getStackImagePixelsInMicrograph(mMicrographVesiclesSubtracted, Xabs(:, :, vesIdx), Yabs(:, :, vesIdx), 1, vVesicleR(vesIdx), stVesicleModel.stParameters.dBeta, stVesicleModel.stParameters.dAlpha, mMicrographBinaryVesicles, 1, 1, stVesicleModel.stParameters.dMaxRR, vVesicleCntX(vesIdx), vVesicleCntY(vesIdx), stVesicleModel.stParameters.iVesShapeInterpMethod, stVesicleModel.stParameters.dWallThickness);
        
        if isValidVesicleImage(mImagePixelsInMicrograph) && isValidVesicleBGImage(mImagePixelsBGWin) 


            [mImagePixelsInMicrographNorm, dImageMean, dStd] = normalizeVesicleImage(mImagePixelsInMicrograph, mImagePixelsVesicleWin, mImagePixelsBGWin, 0);

            mImNormInterp = interpolateImagePixels(mImagePixelsInMicrographNorm, mXvesIm, mYvesIm);
            
            mImNormInterp(isnan(mImNormInterp(:)))=0;
            
            mImNormInterpPOLWindowed = [];
            if stVesicleModel.stParameters.iVesShapeInterpMethod == 2
                mImNormInterpPOL = interpolateImagePixels(mMicrographVesiclesSubtracted, Rabs(:, :, vesIdx), Aabs(:, :, vesIdx));
                mImNormInterpPOLWindowed = mImNormInterpPOL.*mVesicleImWinStackInterpPOL(:,:,vesIdx);

            end


            if isValidVesicleBGImage(mImagePixelsBGWin(vImagePixelsCropInfo(1):vImagePixelsCropInfo(2), vImagePixelsCropInfo(3):vImagePixelsCropInfo(4)))
            

                
                mImBoxSub = removeVesicleFromImage(stVesicleModel, iPrincCompReg,mImagePixelsInMicrograph(vImagePixelsCropInfo(1):vImagePixelsCropInfo(2),vImagePixelsCropInfo(3):vImagePixelsCropInfo(4)),mImagePixelsVesicleWin(vImagePixelsCropInfo(1):vImagePixelsCropInfo(2), vImagePixelsCropInfo(3):vImagePixelsCropInfo(4)),mImagePixelsVesicleHardWin(vImagePixelsCropInfo(1):vImagePixelsCropInfo(2), vImagePixelsCropInfo(3):vImagePixelsCropInfo(4)),mImagePixelsBGWin(vImagePixelsCropInfo(1):vImagePixelsCropInfo(2), vImagePixelsCropInfo(3):vImagePixelsCropInfo(4)),mImagePixelsInMicrographNorm(vImagePixelsCropInfo(1):vImagePixelsCropInfo(2), vImagePixelsCropInfo(3):vImagePixelsCropInfo(4)),mImNormInterp, mVesicleImWinStackInterp(:,:,vesIdx), mImNormInterpPOLWindowed, mVesXrelR, mVesYrelA, vVesicleR(vesIdx), dImageMean, dStd);
                
                if bShowFigure && sum(ismember(stVesicleModel.stParameters.showFigIdx, vesIdx)) 
        
                    fprintf( 'std %d \n', std(mImBoxSub(:))); % TODO remove
                
                end
                
                
                if isValidVesicleImage(mImBoxSub)

                    
                    mMicrographVesiclesSubtracted(vImagePixelsCropInfo(5):vImagePixelsCropInfo(6),vImagePixelsCropInfo(7):vImagePixelsCropInfo(8)) = mImBoxSub;
                    vesicleIdxRemoved(vesIdx) = 1;

                    
                end
            end

        end

    end
    
    clear mMicrographBinaryVesicles;
        
    if stVesicleModel.stParameters.bSaveData
        % Save vesicle subtracted micrograph
        saveVesicleSubtractedMicrograph(stVesicleModel, mMicrograph, mMicrographVesiclesSubtracted, strcat(stVesicleModel.sName, '-mic-', sTestMicText), vVesicleCntX, vVesicleCntY, vVesicleR, vesicleIdxRemoved, iPrincCompReg, iPrincCompRad, iPrincCompAng, sTestMicText);
    end
end
