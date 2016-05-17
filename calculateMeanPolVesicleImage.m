% Always returns windowed, aligned vesicle images and windowed mean

function [mImMean, mVesImageSetShiftAligned, vVesShifts, vVesHorShifts, mImMeanBeforeHorShifts] = calculateMeanPolVesicleImage(stParameters, mVesImageSet, mVesImageWinSet)


    dRadiusInner = stParameters.dMaxR - stParameters.dWallThickness/2;

    vVesShifts = [];
    mVesImageSetShiftAligned = [];
    vVesHorShifts = [];
    mImMeanBeforeHorShifts = [];

    mVesImageSetWindowed = mVesImageSet.*mVesImageWinSet;
    mImMean = mean(mVesImageSetWindowed, 3);
    
    if stParameters.iVesShapeInterpMethod == 3
        
        %figure; imshow(mVesicleTrainingSet_hosvd(:,:,15),[]);
        %figure; imshow(meanImg,[]);
        
        mVesImageSetShiftAligned = mVesImageSetWindowed;
        vVesShifts = zeros(size(mVesImageSet,3),1);
        
        for itShift = 1:stParameters.iShiftIterations

            for iVesIdx = 1:size(mVesImageSet,3)
                [vShifts, mVesImageShiftAligned] = circshiftAlignVesicleImage(mVesImageSetShiftAligned(:,:,iVesIdx), mImMean);
                vVesShifts(iVesIdx) = vShifts;
                mVesImageSetShiftAligned(:,:,iVesIdx) = mVesImageShiftAligned;
            end
            
            mImMean = zeros(size(mImMean));
            
            for iVesIdx = 1:size(mVesImageSet,3)
                mImMean = mImMean + mVesImageSetShiftAligned(:,:,iVesIdx);
            end
            mImMean = mImMean/size(mVesImageSet,3);
            
        end
        
    elseif stParameters.iVesShapeInterpMethod == 4
        
        mVesImageSetShiftAligned = mVesImageSet;
        
        % For test
        %mImMeanBeforeHorShifts = mImMean;
        %mVesImageSetShiftAlignedBeforeHorShifts = mVesImageSetShiftAligned;

        if stParameters.iShiftMethod == 4
            vVesHorShifts = zeros(size(mVesImageSet,3), stParameters.iMaxShiftFrequencies*2, 2);
        else
            vVesHorShifts = zeros(size(mVesImageSet,3), stParameters.iMaxShiftFrequencies, 2);
        end
        
        %if stParameters.iShiftMethod > 2
        %    error('stParameters.iShiftMethod not implemented!');
        %end

        for itShift = 1:stParameters.iShiftIterations

            for iVesIdx = 1:size(mVesImageSet,3)
                [vShifts, mVesImageShiftAligned] = circshiftAlignVesicleImage(mVesImageSetShiftAligned(:,:,iVesIdx), mImMean, 1, mVesImageWinSet(:,:,iVesIdx), stParameters.iMaxShiftFrequencies, stParameters.iMaxShiftAmplitude, stParameters.iShiftMethod, dRadiusInner,0);
                
                %TEST CASES
                %stParameters.iMaxShiftFrequencies = 12;
                %stParameters.iMaxShiftAmplitude = 4;
                %stParameters.iShiftMethod = 1;
                %stParameters.iShiftMethod = 2;
                %stParameters.iShiftMethod = 3;
                %stParameters.iShiftMethod = 4;
                %[vShifts, mVesImageShiftAligned] = circshiftAlignVesicleImage(mVesImageSetShiftAligned(:,:,273), mImMean, 1, mVesImageWinSet(:,:,273), stParameters.iMaxShiftFrequencies, stParameters.iMaxShiftAmplitude, stParameters.iShiftMethod, dRadiusInner);
                %[vShifts, mVesImageShiftAligned] = circshiftAlignVesicleImage(mVesImageSetShiftAligned(:,:,68), mImMean, 1, mVesImageWinSet(:,:,68), stParameters.iMaxShiftFrequencies, stParameters.iMaxShiftAmplitude, stParameters.iShiftMethod, dRadiusInner);
                %[vShifts, mVesImageShiftAligned] = circshiftAlignVesicleImage(mVesImageSetShiftAligned(:,:,10), mImMean, 1, mVesImageWinSet(:,:,10), stParameters.iMaxShiftFrequencies, stParameters.iMaxShiftAmplitude, stParameters.iShiftMethod, dRadiusInner);
                
                % JSB illustration:
%                 imPOL = mVesImageSetShiftAligned(:,:,115);%273, 468,10, 115
%                 figure; imshow(imPOL, []);
%                 imCAR = interpolateVesicleImagePOLtoCAR(imPOL, 60, 1.7, 1);
%                 figure; imshow(imCAR, []);
%                [vShifts, mVesImageShiftAligned] = circshiftAlignVesicleImage(mVesImageSetShiftAligned(:,:,273), mImMean, 1, mVesImageWinSet(:,:,273), 15, 7, 2, dRadiusInner);
                
                
                % TODO ADJUST FOR OTHER METHODS:
                vVesHorShifts(iVesIdx, :, :) = vShifts;
                mVesImageSetShiftAligned(:,:,iVesIdx) = mVesImageShiftAligned;
            end
            
            mImMean = zeros(size(mImMean)); 

            for iVesIdx = 1:size(mVesImageSet,3)
                mImMean = mImMean + mVesImageSetShiftAligned(:,:,iVesIdx).*mVesImageWinSet(:,:,iVesIdx);%TODO TJEK
                
                if itShift == stParameters.iShiftIterations
                    % return windowed set
                    mVesImageSetShiftAligned(:,:,iVesIdx) = mVesImageSetShiftAligned(:,:,iVesIdx).*mVesImageWinSet(:,:,iVesIdx);
                end
            end
            mImMean = mImMean/size(mVesImageSet,3);
            
        end
        
    else
        %error('Invalid shape interpolation method');
    end
   
end