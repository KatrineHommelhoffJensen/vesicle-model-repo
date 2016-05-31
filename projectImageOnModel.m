
% Projects the image mIm onto the residual subspace of the model: The
% resulting mImProj wil have the vesicle structure removed. It is assumed
% that the image is intensity normalised. Then the procedure takes care of:
% 1) If the model and image are different in scaling, then shape normalise
% the model to fit the image
% 2) Subtract the model mean from mIm
% 3) For each model component, subtract the model projection from mIm
% 4) Clean up the images

function [mVesImage, mImBoxSubLevels, vSignalLevels, vMedians, mModelMeanImage] = projectImageOnModel(stVesicleModel, iPrincCompReg, mVesImage, mVesImageInterpPOLWindowed, bResizeModel, mVesXrelR, mVesYrelA, dVesRadius, bReturnSignalLevels, bReturnModelMean, varargin)
  
    mImBoxSubLevels = [];
    vSignalLevels = [];
    vMedians = [];
    mModelMeanImage = [];
    
    if nargin < 9
        bReturnSignalLevels = 0;
    end
    
    if nargin < 10
        bReturnModelMean = 0;
    end
    
    if bReturnSignalLevels && nargin > 10
        
        if length(varargin) < 8
            error('Missing parameters');
        end
            
        mImBoxNorm = varargin{1};
        mImBox = varargin{2};
        mImWin = varargin{3};
        mImBGWin = varargin{4};
        mImHardWin = varargin{5};
        mImHardBGWin = varargin{6};
        dImageMean = varargin{7};
        dStd = varargin{8};
        
        mImBoxSubLevels = zeros(size(mImBoxNorm, 1), size(mImBoxNorm, 2), iPrincCompReg+1);
        vSignalLevels = zeros(iPrincCompReg+1, 1);
        vMedians = zeros(iPrincCompReg+1, 1);

    end
    
    imHOSVDmean = stVesicleModel.mImHOSVDmeanCAR;
    if iPrincCompReg < 1
        mComponents = [];
    else
        mComponents = cell(iPrincCompReg);
        for i=1:iPrincCompReg            
            mComponents{i} = stVesicleModel.mComponentsCAR(:,:,i);
        end
    end
    
    if stVesicleModel.stParameters.iVesShapeInterpMethod == 2
        
        % New strategy: Rotationally align model to vesicle image:
        % 1) Get intensity and shape normalized vesicle image in the
        % polar coordinates
        % 2) Rotationally align model mean to vesicle image
        % 3) Convert the modified model mean and components to cartesian
        % coordinates
        % 4) resizeInterpolateVesicleImage modified model mean and
        % components in the cartesian coordinates
             
        mImTrainMeanShiftAligned = stVesicleModel.mImHOSVDmeanTrainSetPOL;
        mImHOSVDmeanPOLShiftedToVesIm = stVesicleModel.mImHOSVDmeanPOL;

        vShifts = circshiftAlignVesicleImage(mImTrainMeanShiftAligned, mVesImageInterpPOLWindowed, stVesicleModel.stParameters.iMaxShiftFrequencies, stVesicleModel.stParameters.iMaxShiftAmplitude, stVesicleModel.stParameters.dMaxR - stVesicleModel.stParameters.dWallThickness/2,1);
        
        dRadiusInner = round(stVesicleModel.stParameters.dMaxR - stVesicleModel.stParameters.dWallThickness/2);
        [radius, angle]=meshgrid(1:size(mImHOSVDmeanPOLShiftedToVesIm,2),1:size(mImHOSVDmeanPOLShiftedToVesIm,1));
        mImHOSVDmeanPOLShiftedToVesIm = sinusoidShiftVesicleImage(double(mImHOSVDmeanPOLShiftedToVesIm), radius, angle, round(dRadiusInner), vShifts);
        mImHOSVDmeanPOLShiftedToVesIm = mImHOSVDmeanPOLShiftedToVesIm.*stVesicleModel.mImModelWinPOL;
            
        
        % back to cartesian
        mImHOSVDmeanCARShiftedToVesIm = interpolateVesicleImagePOLtoCAR(mImHOSVDmeanPOLShiftedToVesIm, stVesicleModel.stParameters.dMaxR, stVesicleModel.stParameters.dMaxRR);
        if bResizeModel
            mImHOSVDmeanCARShiftedToVesIm = resizeInterpolateVesicleImage(stVesicleModel.stParameters.iVesShapeInterpMethod, stVesicleModel.stParameters.dWallThickness, mImHOSVDmeanCARShiftedToVesIm, stVesicleModel.stParameters.dMaxR, size(mImHOSVDmeanCARShiftedToVesIm, 1)/2 + 1, size(mImHOSVDmeanCARShiftedToVesIm, 2)/2 + 1, mVesXrelR, mVesYrelA, dVesRadius);
        end
        imHOSVDmean = cleanVesicleImage(mImHOSVDmeanCARShiftedToVesIm);
        
        if iPrincCompReg > 0
            for j=1:iPrincCompReg
                mImComponentCARShiftedToVesIm = stVesicleModel.mComponentsPOL(:,:,j);
                [radius, angle]=meshgrid(1:size(mImComponentCARShiftedToVesIm,2),1:size(mImComponentCARShiftedToVesIm,1));
                mImComponentCARShiftedToVesIm = sinusoidShiftVesicleImage(double(mImComponentCARShiftedToVesIm), radius, angle, round(dRadiusInner), vShifts);

                % back to cartesian
                mImComponentCARShiftedToVesIm = interpolateVesicleImagePOLtoCAR(mImComponentCARShiftedToVesIm, stVesicleModel.stParameters.dMaxR, stVesicleModel.stParameters.dMaxRR);

                if bResizeModel
                    mImComponentCARShiftedToVesIm = resizeInterpolateVesicleImage(stVesicleModel.stParameters.iVesShapeInterpMethod, stVesicleModel.stParameters.dWallThickness, mImComponentCARShiftedToVesIm, stVesicleModel.stParameters.dMaxR, size(mImComponentCARShiftedToVesIm, 1)/2 + 1, size(mImComponentCARShiftedToVesIm, 2)/2 + 1, mVesXrelR, mVesYrelA, dVesRadius);
                end
                mComponents{j} = mImComponentCARShiftedToVesIm;
            end
        end
        
        
    elseif bResizeModel
        
        imHOSVDmean = resizeInterpolateVesicleImage(stVesicleModel.stParameters.iVesShapeInterpMethod, stVesicleModel.stParameters.dWallThickness, imHOSVDmean, stVesicleModel.stParameters.dMaxR, size(imHOSVDmean, 1)/2 + 1, size(imHOSVDmean, 2)/2 + 1, mVesXrelR, mVesYrelA, dVesRadius);

        if iPrincCompReg > 0
            for j=1:iPrincCompReg
                mComponents{j} = resizeInterpolateVesicleImage(stVesicleModel.stParameters.iVesShapeInterpMethod, stVesicleModel.stParameters.dWallThickness, mComponents{j}, stVesicleModel.stParameters.dMaxR, size(mComponents{j}, 1)/2 + 1, size(mComponents{j}, 2)/2 + 1, mVesXrelR, mVesYrelA, dVesRadius);
            end
        end
    end
    
    
    
    
    if ~(isfield(stVesicleModel, 'bSuppressMeanSubtract') && stVesicleModel.bSuppressMeanSubtract == 1)
    
        % Subtract mean vesicle
        mVesImage = mVesImage - imHOSVDmean;
    end
    
    
    if bReturnModelMean
        mModelMeanImage = imHOSVDmean;
    end
    
    if bReturnSignalLevels
        % Noise level difference (in intensity normalized frame!)
        mImTmp = (mVesImage.*mImWin) + (mImBoxNorm.*mImBGWin);
        vSignalLevels(1) = getVesicleImageWinDeviation(mImTmp, mImHardWin, mImHardBGWin);
        vMedians(1) = getVesicleImageWinMedian(mVesImage, mImHardWin, 1);
        mImBoxSubLevels(:,:,1) = (reverseNormalizeVesicleImage(mVesImage, dImageMean, dStd).*mImWin) +  (mImBox.*mImBGWin);
    end
    
    
    
    % Subtract model projection
    if iPrincCompReg > 0
        for j=1:iPrincCompReg

            mVesImage = mVesImage - projectImageOnModelComponent(mVesImage, mComponents{j});

            if bReturnSignalLevels
                % Noise level difference (in intensity normalized frame!)
                mImTmp = (mVesImage.*mImWin) + (mImBoxNorm.*mImBGWin);
                vSignalLevels(j+1) = getVesicleImageWinDeviation(mImTmp, mImHardWin, mImHardBGWin);
                vMedians(j+1) = getVesicleImageWinMedian(mVesImage, mImHardWin, 1);
                % Intensity normalized values, visualized with reverse normalized,
                % signal merged images
                mImBoxSubLevels(:,:,j+1) = (reverseNormalizeVesicleImage(mVesImage, dImageMean, dStd).*mImWin) +  (mImBox.*mImBGWin);
            end
        end
    end
    
end

