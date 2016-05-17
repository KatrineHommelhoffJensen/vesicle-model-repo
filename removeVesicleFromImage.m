
% Handles subtraction of a vesicle structure from an image, including
% projecting onto the model components and merging the vesicle and
% background signal


% stVesicleModel: The model to be used for subtraction
% mPrincCompReg, mComponents: Model components

% mImBox: Boxed out image pixels from micrograph (not normalized!)
% mImWin: Vesicle signal window for boxed out image
% mImBGWin: Background signal window for boxed out image
% dImageMean, dStd: Normalization constants
% mImNormInterp: mImBox image intensity normalized and interpolated
% mImNormInterpWin: Vesicle signal window for interpolated image

% mImBoxSub: Returned vesicle subtracted image



function [mImBoxSub, h] = removeVesicleFromImage(stVesicleModel, iPrincCompReg, mImBox, mImWin, mImHardWin, mImHardBGWin, mImBoxNorm, mImNormInterp, mImNormInterpWin, mImNormInterpPOLWindowed, mVesXrelR, mVesYrelA, dVesRadius, dImageMean, dStd, bShowFigure)

    h = [];
    
    if ~isValidVesicleImage(mImBoxNorm) 
        error('Invalid vesicle image');
    end
    if ~isValidVesicleBGImage(mImHardBGWin) 
        error('Invalid vesicle background image');
    end
    
    
    % -----------------------------------------------------------
    % 1) Project mImNormInterp onto model
    % -----------------------------------------------------------
    
    % Window image
    mImBoxSubInterp = mImNormInterp.*mImNormInterpWin;
    

    [mImBoxSubInterp] = projectImageOnModel(stVesicleModel, iPrincCompReg, mImBoxSubInterp, mImNormInterpPOLWindowed, 0);
        
   

    if bShowFigure
        
        % First row intensity scaled after interpolated image
        
        % Notice: normalized images display negative values (zero mean) while unnormalized should be displayed in only positive range 
        
        minValNorm = min(mImNormInterp(:));
        maxValNorm = max(mImNormInterp(:));
        
        h=figure;
        stdFigSize = get(h, 'Position');close(h);
        h = figure('Position',[stdFigSize(1),stdFigSize(2),stdFigSize(3)+100,stdFigSize(4)+400]);
        subplot(6,4,1);
        imshow(mImNormInterp, [minValNorm, maxValNorm]);title(strcat('mImNormInterp (', num2str(size(mImNormInterp,1)), ')'));
        colormap gray;freezeColors
        subplot(6,4,2);
        imshow(mImBoxSubInterp, [minValNorm, maxValNorm]);title(strcat('mImBoxSubInterp (', num2str(size(mImBoxSubInterp,1)), ')'));
        colormap gray;freezeColors
        subplot(6,4,3);
        mImDiffInterp = (mImNormInterp - mImBoxSubInterp).*mImNormInterpWin;
        imshow(mImDiffInterp, [minValNorm, maxValNorm]);title(strcat('mImDiffInterp (', num2str(size(mImDiffInterp,1)), ')'));
        colormap gray;freezeColors
        %subplot(6,4,4);
        %mImDiffBox = resizeInterpolateVesicleImage(stVesicleModel.stParameters.iVesShapeInterpMethod, stVesicleModel.stParameters.dWallThickness, mImDiffInterp, stVesicleModel.stParameters.dMaxR, size(mImDiffInterp, 1)/2 + 1, size(mImDiffInterp, 2)/2 + 1, mVesXrelR, mVesYrelA, dVesRadius);       
        %imshow(mImDiffBox, [minValNorm, maxValNorm]);title(strcat('mImDiffBox (', num2str(size(mImDiffBox,1)), ')'));
        %colormap gray;freezeColors
        
        G = fspecial('gaussian',[5 5],2);
        imO = imfilter(mImNormInterp,G,'same');
        minValFiltNorm = min(imO(:));
        maxValFiltNorm = max(imO(:));
        
        subplot(6,4,5);
        imshow(imfilter(mImNormInterp,G,'same'), [minValFiltNorm, maxValFiltNorm]); title(strcat('std-', num2str(std(mImNormInterp(:)))));
        colormap jet;freezeColors
        subplot(6,4,6);
        imshow(imfilter(mImBoxSubInterp,G,'same'), [minValFiltNorm, maxValFiltNorm]); title(strcat('std-', num2str(std(mImBoxSubInterp(:)))));
        colormap jet;freezeColors
        subplot(6,4,7);
        imshow(imfilter(mImDiffInterp,G,'same'), [minValFiltNorm, maxValFiltNorm]);
        colormap jet;freezeColors
        %subplot(6,4,8);
        %imshow(imfilter(mImDiffBox,G,'same'), [minValFiltNorm, maxValFiltNorm]);
        %colormap jet;freezeColors
        
    end
    
    % -----------------------------------------------------------
    % 2) Reverse interpolation and normalization
    % -----------------------------------------------------------
    
    % Interpolation
    mImBoxSub = resizeInterpolateVesicleImage(stVesicleModel.stParameters.iVesShapeInterpMethod, stVesicleModel.stParameters.dWallThickness, mImBoxSubInterp, stVesicleModel.stParameters.dMaxR, size(mImBoxSubInterp, 1)/2 + 1, size(mImBoxSubInterp, 2)/2 + 1, mVesXrelR, mVesYrelA, dVesRadius);
    
    % Normalization
    mImBoxSub = reverseNormalizeVesicleImage(mImBoxSub, dImageMean, dStd);
    
    
    
    % -----------------------------------------------------------
    % 3) Merge with mImBox
    % -----------------------------------------------------------
    
    mImBGWin = abs(mImWin - 1);
    mImBoxSubMerge =  (mImBoxSub.*mImWin) +  (mImBox.*mImBGWin);
    
    if bShowFigure
        
%         minVal = min(mImBoxNorm(:));
%         maxVal = max(mImBoxNorm(:));
%         imO = imfilter(mImBoxNorm,G,'same');

        % Colors displayed according to raw, unnormalized boxed image

        minVal = min(mImBox(:));
        maxVal = max(mImBox(:));
        imO = imfilter(mImBox,G,'same');
        minValFilt = min(imO(:));
        maxValFilt = max(imO(:));
        
        subplot(6,4,4);
        imshow(mImBoxSubMerge, [minVal, maxVal]);title(strcat('mImBoxSub (rev) (', num2str(size(mImBoxSubMerge,1)), ')'));
        colormap gray;freezeColors
        subplot(6,4,8);
        imshow(imfilter(mImBoxSubMerge,G,'same'), [minValFilt, maxValFilt]); title(strcat('std-', num2str(std(mImBoxSubMerge(:)))));
        colormap jet;freezeColors
        
        sTxt = 'Row 1 and 2: Model subtraction with interpolated/normalised vesicle image:';
        sTextBox = uicontrol('style','text');
        %set(sTextBox,'String',sTxt,'Position', [10 800 600 15]);
        sTxt = '(1) Intensnorm+interp orig, (2) win(orig) after sub, (3) Model projection, (4) Merge of rev(Intensnorm+interp) residual with raw';
        sTextBox = uicontrol('style','text');
        %set(sTextBox,'String',sTxt,'Position', [10 785 600 15]);
    end
    
    % -----------------------------------------------------------
    % 4) Alternative merge method (applied to micrograph)
    % -----------------------------------------------------------
    
    mImBoxSub2 = (mImBoxNorm.*mImWin);
    
    [mImBoxSub2, mImBoxSubLevels, vSignalLevels, vMedians, mModelMeanImage] = projectImageOnModel(stVesicleModel, iPrincCompReg, mImBoxSub2, mImNormInterpPOLWindowed, 1, mVesXrelR, mVesYrelA, dVesRadius, 1, 1, mImBoxNorm, mImBox, mImWin, mImBGWin, mImHardWin, mImHardBGWin, dImageMean, dStd);
    

    mImBoxSub2 = reverseNormalizeVesicleImage(mImBoxSub2, dImageMean, dStd);
    mImBoxSub2Merge = (mImBoxSub2.*mImWin) +  (mImBox.*mImBGWin);
    
    if bShowFigure
        
        
        subplot(6,4,9);
        imshow(mImBox, [minVal, maxVal]);title(strcat('mImBox (', num2str(size(mImBox,1)), ')'));
        colormap gray;freezeColors
        
        subplot(6,4,10);
        imshow(mImBoxSub2, [minVal, maxVal]);title(strcat('\color{blue} M3: mImBoxSub2 (', num2str(size(mImBoxSub2,1)), ')'));
        colormap gray;freezeColors
        
        mImDiff = (mImBox - mImBoxSub2).*mImWin;
        subplot(6,4,11);
        %imshow(mImBox.*mImHardBGWin, [minVal, maxVal]);title(strcat('mImBox BG (', num2str(size(mImBox,1)), ')'));
        imshow(mImDiff, [minVal, maxVal]);title(strcat('mImDiff (', num2str(size(mImBox,1)), ')'));
        colormap gray;freezeColors
        
        subplot(6,4,12);
        imshow(mImBoxSub2Merge, [minVal, maxVal]);title(strcat('\color{blue} M3: mImBoxSub2Merge (', num2str(size(mImBoxSub2Merge,1)), ')'));
        colormap gray;freezeColors
        
        % Gauss filtered
        
        subplot(6,4,13);
        imshow(imfilter(mImBox,G,'same'), [minValFilt, maxValFilt]);
        colormap jet;freezeColors
        
        subplot(6,4,14);
        imshow(imfilter(mImBoxSub2,G,'same'), [minValFilt, maxValFilt]);
        colormap jet;freezeColors
        
        subplot(6,4,15);
        %imshow(imfilter(mImBox.*mImHardBGWin,G,'same'), [minValFilt, maxValFilt]);
        imshow(imfilter(mImDiff,G,'same'), [minValFilt, maxValFilt]);
        colormap jet;freezeColors
        
        subplot(6,4,16);
        imshow(imfilter(mImBoxSub2Merge,G,'same'), [minValFilt, maxValFilt]); title(strcat('M3: std-', num2str(std(mImBoxSub2Merge(:)))));
        colormap jet;freezeColors
        
        % Windowing
        
        subplot(6,4,17);
        imshow(mImBox.*mImWin, [minVal, maxVal]);title(strcat('mImBox BG (', num2str(size(mImBox,1)), ')'));
        colormap gray;freezeColors
        
         subplot(6,4,21);
        imshow(imfilter(mImBox.*mImWin,G,'same'), [minValFilt, maxValFilt]);
        colormap jet;freezeColors
        
%         subplot(6,4,18);
%         imshow(mImBox.*mImHardBGWin, [minVal, maxVal]);title(strcat('mImBox BG (', num2str(size(mImBox,1)), ')'));
%         colormap gray;freezeColors
%         
%         subplot(6,4,22);
%         imshow(imfilter(mImBox.*mImHardBGWin,G,'same'), [minValFilt, maxValFilt]);
%         colormap jet;freezeColors

        subplot(6,4,18);
        imshow((mImBox-mImDiff).*mImWin, [minVal, maxVal]);title(strcat('mImBox-mImDiff (', num2str(size(mImBox,1)), ')'));
        colormap gray;freezeColors
        
        subplot(6,4,22);
        tmp1 = mImBox.*mImWin;
        tmp2 = mImDiff.*mImWin;
        imshow(imfilter((mImBox-mImDiff).*mImWin,G,'same'), [minValFilt, maxValFilt]);title(strcat('std(mImBox-mImDiff) (', num2str(std(tmp1(:)-tmp2(:))), ')'));
        colormap jet;freezeColors

        
        % Procrustes analysis
        
        dDist1 = calcVesicleImageProcrustesDistance(mModelMeanImage, mImBoxNorm, mImWin);
        subplot(6,4,19);
        imshow(mModelMeanImage, [minVal, maxVal]); title('Model mean');
        colormap gray;freezeColors
        
        dDist2 = calcVesicleImageProcrustesDistance(mModelMeanImage, mImDiff, mImWin);
        subplot(6,4,20);
        imshow(mModelMeanImage-mImDiff, [minVal, maxVal]); title('Model mean-mdlProj'); 
        colormap gray;freezeColors
        
        
        subplot(6,4,23);
        imshow(imfilter(mModelMeanImage,G,'same'), [minValFilt, maxValFilt]); title(char('Pro mean-normIm', num2str(dDist1)));
        colormap jet;freezeColors
        
        subplot(6,4,24);
        imshow(imfilter(mModelMeanImage-mImDiff,G,'same'), [minValFilt, maxValFilt]); title(char('Pro mean-mdlPro', num2str(dDist2)));
        colormap jet;freezeColors
        
        
        sTxt = 'Row 3-6: Model subtraction with shape interp model and intensity norm vesicle image:';
        sTextBox = uicontrol('style','text');
        %set(sTextBox,'String',sTxt,'Position', [10 540 600 15]);
        
        
        % Compensate for aura
        
%         mImTmp = mImBoxSub2.*mImBGWin;
%         mImTmp = mImTmp(find(mImTmp > 0));
%         mImBoxSub2_2 = mImBoxSub2 - median(mImTmp(:));
%         subplot(6,4,19);
%         imshow(mImBoxSub2_2, [minVal, maxVal]);title(strcat('M3: mImBoxSub2 (', num2str(size(mImBoxSub2,1)), ')'));
%         colormap gray;freezeColors
%         
%         subplot(6,4,23);
%         imshow(imfilter(mImBoxSub2_2,G,'same'), [minValFilt, maxValFilt]);
%         colormap jet;freezeColors
%         
%         mImTmpMerge = (mImBoxSub2_2.*mImWin) +  (mImBox.*mImBGWin);
%         
%         subplot(6,4,20);
%         imshow(mImTmpMerge, [minVal, maxVal]);title(strcat('M3: mImBoxSub2 (', num2str(size(mImBoxSub2,1)), ')'));
%         colormap gray;freezeColors
%         
%         subplot(6,4,24);
%         imshow(imfilter(mImTmpMerge,G,'same'), [minValFilt, maxValFilt]);
%         colormap jet;freezeColors
        
    end
    
    

    
    % Final sub method
    mImBoxSub = mImBoxSub2Merge; %M3
    
end

% TODO REMOVE
function [dDist] = calcVesicleImageProcrustesDistance(mImage1, mImage2, mWindow)
    
    
    if size(mImage1, 1) ~= size(mImage2, 1) || size(mImage1, 1) ~= size(mWindow, 1)
        error('Invalid image size among input');
    end
    
    %mean(mean((mImMean - mImTmp).^2));
    dDist = sum(sum(((mImage1 - mImage2).*mWindow)^2));
    
end
