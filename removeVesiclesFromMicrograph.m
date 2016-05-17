
% We assume the micrograph is already median subtracted

% The micrograph has to be read according to the model type

% Modifications since last version:
% * Only subtract directly from micrograph (not stack)
% * New normalization (normalize, interp, window)
% * New subtraction procedure (subtractVesicleFromImage2) with subtraction
% in original representation (CAR, POL, RAD)
% * Only implemented for CAR, POL and RAD

function [mMicrographVesiclesSubtracted, vesicleIdxRemoved, hFigBefore, hFigAfter] = removeVesiclesFromMicrograph(stVesicleModel, iPrincCompReg, iPrincCompRad, iPrincCompAng, mMicrograph, vVesicleCntX, vVesicleCntY, vVesicleR, bShowFigure, sTestMicText, bFigApplyGaussFilt)


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
    if stVesicleModel.stParameters.iVesShapeInterpMethod == 3 || stVesicleModel.stParameters.iVesShapeInterpMethod == 4
        [Rabs, Aabs, mVesicleImWinStackInterpPOL] = createVesInterpAbsoluteMeshGridsForMic('POL', vVesicleCntX, vVesicleCntY, vVesicleR, stVesicleModel.stParameters, mMicrographBinaryVesicles);
    end
    


    mMicrographVesiclesSubtracted = mMicrograph;
    vesicleIdxRemoved = zeros(iNrOfVesicles,1);

    
    showFigIdx = [6 7 27 35]; % TIP paper

    for vesIdx = 1:iNrOfVesicles

        % Correction of X and Y values to boxed image: Center
        % coordinates should be aligned
        
        %[mImagePixelsInMicrograph, mXvesIm, mYvesIm, mImagePixelsVesicleWin, mImagePixelsBGWin, iImCropSize, mImBoxXcrop, mImBoxYcrop, mImagePixelsVesicleHardWin] = getStackImagePixelsInMicrograph(mMicrographVesiclesSubtracted, Xabs(:, :, vesIdx), Yabs(:, :, vesIdx), 1, vVesicleR(vesIdx), dBeta, stVesicleModel.stParameters.dAlpha, mMicrographBinaryVesicles, 1, 1, dMaxRR, dMaxRfac, vVesicleCntX(vesIdx), vVesicleCntY(vesIdx));
        [mImagePixelsInMicrograph, mXvesIm, mYvesIm, mImagePixelsVesicleWin, mImagePixelsBGWin, vImagePixelsCropInfo, mVesXrelR, mVesYrelA, mImagePixelsVesicleHardWin] = getStackImagePixelsInMicrograph(mMicrographVesiclesSubtracted, Xabs(:, :, vesIdx), Yabs(:, :, vesIdx), 1, vVesicleR(vesIdx), stVesicleModel.stParameters.dBeta, stVesicleModel.stParameters.dAlpha, mMicrographBinaryVesicles, 1, 1, stVesicleModel.stParameters.dMaxRR, vVesicleCntX(vesIdx), vVesicleCntY(vesIdx), stVesicleModel.stParameters.iVesShapeInterpMethod, stVesicleModel.stParameters.dWallThickness);
        
        
        % Before normalization, the following two images should be
        % completely equal:
        % im1 = mMicrographVesiclesSubtracted(mImBoxYcrop(1):mImBoxYcrop(2), mImBoxXcrop(1):mImBoxXcrop(2));
        % im2 = crop(mImagePixelsInMicrograph, iImCropSize);

        
        if isValidVesicleImage(mImagePixelsInMicrograph) && isValidVesicleBGImage(mImagePixelsBGWin) 

            
                % Normalize raw image without windowing                
                

                    [mImagePixelsInMicrographNorm, dImageMean, dStd] = normalizeVesicleImage(mImagePixelsInMicrograph, mImagePixelsVesicleWin, mImagePixelsBGWin, 0);


                mImNormInterp = interpolateImagePixels(mImagePixelsInMicrographNorm, mXvesIm, mYvesIm);
            
            mImNormInterp(isnan(mImNormInterp(:)))=0;
            
            mImNormInterpPOLWindowed = [];
            if stVesicleModel.stParameters.iVesShapeInterpMethod == 3 || stVesicleModel.stParameters.iVesShapeInterpMethod == 4
                mImNormInterpPOL = interpolateImagePixels(mMicrographVesiclesSubtracted, Rabs(:, :, vesIdx), Aabs(:, :, vesIdx));
                mImNormInterpPOLWindowed = mImNormInterpPOL.*mVesicleImWinStackInterpPOL(:,:,vesIdx);

            end

            if bShowFigure && sum(ismember(showFigIdx, vesIdx))
                bShowFig = 1;
            else
                bShowFig = 0;
            end

            % Crop function used (which crop):
            % /Users/katrine/Documents/Cryo-EM/Development/MatLab/Membrane/Fred/aEMCodeRepository-master/aLibs/EMBase/Crop.m
            %if isValidVesicleBGImage(Crop(mImagePixelsBGWin, iImCropSize))
            if isValidVesicleBGImage(mImagePixelsBGWin(vImagePixelsCropInfo(1):vImagePixelsCropInfo(2), vImagePixelsCropInfo(3):vImagePixelsCropInfo(4)))
            
                if vesIdx == 2 || vesIdx == 6 || vesIdx == 7 || vesIdx == 35
                    p = 1;
                end
                
                [mImBoxSub, h] = removeVesicleFromImage(stVesicleModel, iPrincCompReg,mImagePixelsInMicrograph(vImagePixelsCropInfo(1):vImagePixelsCropInfo(2),vImagePixelsCropInfo(3):vImagePixelsCropInfo(4)),mImagePixelsVesicleWin(vImagePixelsCropInfo(1):vImagePixelsCropInfo(2), vImagePixelsCropInfo(3):vImagePixelsCropInfo(4)),mImagePixelsVesicleHardWin(vImagePixelsCropInfo(1):vImagePixelsCropInfo(2), vImagePixelsCropInfo(3):vImagePixelsCropInfo(4)),mImagePixelsBGWin(vImagePixelsCropInfo(1):vImagePixelsCropInfo(2), vImagePixelsCropInfo(3):vImagePixelsCropInfo(4)),mImagePixelsInMicrographNorm(vImagePixelsCropInfo(1):vImagePixelsCropInfo(2), vImagePixelsCropInfo(3):vImagePixelsCropInfo(4)),mImNormInterp, mVesicleImWinStackInterp(:,:,vesIdx), mImNormInterpPOLWindowed, mVesXrelR, mVesYrelA, vVesicleR(vesIdx), dImageMean, dStd, bShowFig);
                
                
                if isValidVesicleImage(mImBoxSub)

                    
                    mMicrographVesiclesSubtracted(vImagePixelsCropInfo(5):vImagePixelsCropInfo(6),vImagePixelsCropInfo(7):vImagePixelsCropInfo(8)) = mImBoxSub;
                    vesicleIdxRemoved(vesIdx) = 1;

                    

                    if bShowFig

                        % overall figure title
                        ax=axes('Units','Normal','Position',[.075 .075 .85 .87],'Visible','off');
                        set(get(ax,'Title'),'Visible','on')
                        title(char(stVesicleModel.sName, 'Vesicle subtraction data'));

                        if stVesicleModel.stParameters.bSaveData
                            saveAsKeepSize(h, strcat(stVesicleModel.stParameters.sSaveToDir, stVesicleModel.sName, '-PC-', num2str(iPrincCompReg), '-subtract-data2-idx-', num2str(vesIdx), '-mic-', sTestMicText, strcat('.pdf')));
                        end
                        close(h);
                        
                    end

                end
            end

        end

    end
    
    clear mMicrographBinaryVesicles;
    
    if 1%bShowFigure
        % show the micrograph after vesicle subtraction
        h = figure;
        stdFigSize = get(h, 'Position'); close(h);
        hFigBefore = figure('Position',[stdFigSize(1),stdFigSize(2),stdFigSize(3)+70,stdFigSize(3)]); 
        if bFigApplyGaussFilt
            imagesc(GaussFilt(mMicrograph, 0.1)); colormap gray; axis xy; hold on;
        else
            imagesc(mMicrograph); colormap gray; axis xy; hold on;
        end
        for vesicleIdx=1:iNrOfVesicles
            if vesicleIdxRemoved(vesicleIdx)
                plot(vVesicleCntX(vesicleIdx),vVesicleCntY(vesicleIdx),'b.');
            else
                plot(vVesicleCntX(vesicleIdx),vVesicleCntY(vesicleIdx),'r.');
            end
        end
        title(char(stVesicleModel.sName, 'Micrograph before vesicle subtraction, gauss filtered'));
    
%         if saveData
%             saveAsKeepSize(h, strcat(stVesicleModel.stParameters.sSaveToDir, stVesicleModel.sName, '-before-vesicle-subtraction-', strcat('.pdf')));
%         end
        
        
        hFigAfter = figure('Position',[stdFigSize(1),stdFigSize(2),stdFigSize(3)+70,stdFigSize(3)]); 
        if bFigApplyGaussFilt
            imagesc(GaussFilt(mMicrographVesiclesSubtracted, 0.1)); colormap gray; axis xy; hold on;
        else
            imagesc(mMicrographVesiclesSubtracted); colormap gray; axis xy; hold on;
        end
        for vesicleIdx=1:iNrOfVesicles
            if vesicleIdxRemoved(vesicleIdx)
                plot(vVesicleCntX(vesicleIdx),vVesicleCntY(vesicleIdx),'b.');
            else
                plot(vVesicleCntX(vesicleIdx),vVesicleCntY(vesicleIdx),'r.');
            end
        end
        title(char(stVesicleModel.sName, 'Micrograph after vesicle subtraction, gauss filtered'));

%         if saveData
%             saveAsKeepSize(h, strcat(stVesicleModel.stParameters.sSaveToDir, stVesicleModel.sName, '-after-vesicle-subtraction-', strcat('.pdf')));
%         end
    end
    
    if stVesicleModel.stParameters.bSaveData
        % Save vesicle subtracted micrograph
        saveVesicleSubtractedMicrograph(stVesicleModel.stParameters.sSaveToDir, mMicrographVesiclesSubtracted, strcat(stVesicleModel.sName, '-mic-', sTestMicText), vVesicleCntX, vVesicleCntY, vVesicleR, vesicleIdxRemoved, stVesicleModel.sName, iPrincCompReg, iPrincCompRad, iPrincCompAng);
    end
end
