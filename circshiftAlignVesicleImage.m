function [vShifts, mVesImageShiftAligned] = circshiftAlignVesicleImage(mVesImage, mAlignToImage, bHorShift, mVesWindow, iShiftFrequencies, iMaxShiftAmplitude, iShiftMethod, dRadiusInner, bBlurAlignToImage)
 
    mVesImageShiftAligned = [];
    
    if nargin < 3 || ~bHorShift
            
        dMinValue = Inf;
        for iRowIdx = 1:size(mVesImage,1)
            val = mean(mean((mAlignToImage - circshift(mVesImage, iRowIdx)).^2));
            if val < dMinValue
                dMinValue = val;
                vShifts = iRowIdx;
            end
        end
        mVesImageShiftAligned = circshift(mVesImage, vShifts);
            
    elseif nargin > 3 %~isempty(vHorShiftColIdxs)

        dRadiusInner = round(dRadiusInner); % make sure its an integer       
        R = size(mVesImage,1);
        
        % blur image for comparison
        mVesImageShiftAligned = double(mVesImage);
        H=fspecial('Gaussian',[7 7],1);
        for i=1:10
            if bBlurAlignToImage
                mAlignToImage = imfilter(mAlignToImage, H);
            else
                mVesImageShiftAligned = imfilter(mVesImageShiftAligned, H);
            end
        end
        %mAmplitudes = lsqnonlin(@(mAmplitudes)amplitudesResidual(mAmplitudes, img{10}, mimg{10}, mVesWindow, dRadiusInner, radius, angle), mAmplitudesInit,[],[],options);

        % time start
        %tStart = tic;
        
        
        if iShiftMethod == 1
        
            
            % --------------------------------------------------------------
            % Implementation 1) 
            % FAST APPROXIMATION
            % time: 0 minutes and 2.991915 seconds for 
            % circshiftAlignVesicleImage(mVesImageSetShiftAligned(:,:,273), mImMean, 1, mVesImageWinSet(:,:,273), 12, 4, 1, dInnerRadius);

            % for 4 amplitudes this methods use 7 max shifts
            iMaxShiftAmplitudeApprox = round(iMaxShiftAmplitude*1.7); 
            vShifts = zeros(1, R);
            
            for iRowIdx = 1:size(mVesImage,1)
                dMinValue = mean(mean((mAlignToImage - mVesImageShiftAligned).^2));
                vShifts(iRowIdx) = 0; %no shift
                for iColIdx = [-iMaxShiftAmplitudeApprox:iMaxShiftAmplitudeApprox]%[-7:7]%[-4:4]
                    mImTmp = mVesImageShiftAligned;
                    mImTmp(iRowIdx,:) = circshift(mImTmp(iRowIdx,:), [0,iColIdx]);
                    val = mean(mean((mAlignToImage - mImTmp).^2));
                    if val < dMinValue
                        dMinValue = val;
                        vShifts(iRowIdx) = iColIdx;
                    end
                end
                %mVesImageShiftAligned(iRowIdx,:) = circshift(mVesImageShiftAligned(iRowIdx,:), [0,vShifts(iRowIdx)]);
            end
            %mVesImageShiftAligned = mVesImageShiftAligned.*mVesWindow;
    %         
    %         % http://www.continuummechanics.org/cm/fourierxforms.html
            vAmplitudes1 = zeros(iShiftFrequencies,1);
            vAmplitudes2 = zeros(iShiftFrequencies,1);
            R = length(vShifts);
            for f = 1:iShiftFrequencies
                for iRowIdx = 1:size(mVesImage,1)
                    vAmplitudes1(f) = vAmplitudes1(f) + vShifts(iRowIdx)*sin(2*pi*iRowIdx*f/R);
                    vAmplitudes2(f) = vAmplitudes2(f) + vShifts(iRowIdx)*cos(2*pi*iRowIdx*f/R);
                end
                vAmplitudes1(f) = vAmplitudes1(f)*2/R;
                vAmplitudes2(f) = vAmplitudes2(f)*2/R;
            end
            
            % JSB illustration
%             vShiftsSinusoid = zeros(size(vShifts));
%             intPOLMin = 0;
%             intPOLMax = 0;
%             intCARMin = 0;
%             intCARMax = 0;
%             
%             
%                 for f = 1:iShiftFrequencies
%                     imTMP = mVesImageShiftAligned;
%                     for iRowIdx=1:R
%                         vShiftsSinusoid(iRowIdx) = vShiftsSinusoid(iRowIdx) + vAmplitudes1(f)*sin(2*pi*iRowIdx*f/R) + vAmplitudes2(f)*cos(2*pi*iRowIdx*f/R);
%                     end
%                     vShifts = round(vShiftsSinusoid);
%                     
%                     for iRowIdx = 1:size(mVesImage,1)
%                         imTMP(iRowIdx,:) = circshift(imTMP(iRowIdx,:), [0,vShifts(iRowIdx)]);
%                     end
%                      
%                     if f == 1 || f == 4 || f == 7 || f == 10 || f == 13
%                         if f == 1
%                             intPOLMin = min(imTMP(:));
%                             intPOLMax = max(imTMP(:));
%                         end
%                         figure; ax = axes; hold on; ylim([-10 10]); plot(vShiftsSinusoid(:), 'b-');
%                         figure; imshow(imTMP, [intPOLMin, intPOLMax]);
%                         imCAR = interpolateVesicleImagePOLtoCAR(imTMP.*mVesWindow, 60, 1.7, 1);
%                         if f == 1
%                             intCARMin = min(imCAR(:));
%                             intCARMax = max(imCAR(:));
%                         end
%                         figure; imshow(imCAR, [intCARMin, intCARMax]);
%                     end
%                 end
            
            
            
           
            
%             vShiftsSinusoid = zeros(size(vShifts));
%             for iRowIdx=1:R
%                 for f = 1:iShiftFrequencies
%                     vShiftsSinusoid(iRowIdx) = vShiftsSinusoid(iRowIdx) + vAmplitudes1(f)*sin(2*pi*iRowIdx*f/R) + vAmplitudes2(f)*cos(2*pi*iRowIdx*f/R);
%                 end
%             end
%             vShifts = round(vShiftsSinusoid);
%             %figure; hold on;plot(vShifts(:), 'b-');plot(vShiftsSinusoid(:), 'r-');
%             for iRowIdx = 1:size(mVesImage,1)
%                 mVesImageShiftAligned(iRowIdx,:) = circshift(mVesImageShiftAligned(iRowIdx,:), [0,vShifts(iRowIdx)]);
%             end
            %figure; imshow(mVesImageShiftAligned, []);
            %mVesImageShiftAligned = mVesImageShiftAligned.*mVesWindow;
            %figure; imshow(mVesImageShiftAligned2, []);
        
            
        vShifts = zeros(iShiftFrequencies, 2);
        vShifts(:,1) = vAmplitudes1;
        vShifts(:,2) = vAmplitudes2;
        [radius, angle]=meshgrid(1:size(mVesImage,2),1:size(mVesImage,1));
        mVesImageShiftAligned = sinusoidShiftVesicleImage(mVesImage, radius, angle, dRadiusInner, vShifts, iShiftFrequencies);
        
        
        % --------------------------------------------------------------
        % Implementation 1) time: 0 minutes and 20.353963 seconds
        
%         % time start
%         tStart = tic;
%         
%         [radius, angle]=meshgrid(1:size(mVesImage,2),1:size(mVesImage,1));
%         modifiedRadius = zeros(size(radius));
%         dMinValue=Inf;
%         mShift = zeros(size(mVesImage,1),iShiftFrequencies); 
%         mBestAmpl = zeros(iShiftFrequencies, 2);
%         for f = 1:iShiftFrequencies
%             for vSinAmplitude = -4:0.5:4
%                 for vCosAmplitude = -4:0.5:4
% 
%                     mShift(:,f) = vSinAmplitude*sin(2*pi*((1:size(mVesImage,1))')*f/R)+...
%                                  vCosAmplitude*cos(2*pi*((1:size(mVesImage,1))')*f/R); 
%                     totalShift = sum(mShift,2)*ones(1,size(mVesImage,2));                   
%                     modifiedRadius(:,1:dRadiusInner) = radius(:,1:dRadiusInner).*(dRadiusInner-totalShift(:,1:dRadiusInner))/dRadiusInner;
%                     modifiedRadius(:,(dRadiusInner+1):end) = radius(:,(dRadiusInner+1):end) -totalShift(:,(dRadiusInner+1):end);
%                     mCorrectedVesImage=reshape(interp2(mVesImage,modifiedRadius(:),angle(:),'linear',0),size(mVesImage));
% 
%                     val = norm(mCorrectedVesImage.*mVesWindow - mAlignToImage, 'fro')/sqrt(prod(size(mVesImage)));
% 
%                     %figure(1);
%                     %imshow(mCorrectedVesImage,[])
%                     %title(['Std: ' num2str(val)]);
%                     %pause
% 
%                     if val<dMinValue
%                         dMinValue=val;
%                         mBestShiftF = mShift(:,f);
%                         mBestImage = mCorrectedVesImage;
%                         mBestAmpl(f, 1) = vSinAmplitude;
%                         mBestAmpl(f, 2) = vCosAmplitude;
%                         
% 
%                     end
%                 end
%             end
%             mShift(:,f)=mBestShiftF; %HERTIL ERROR???
%         end
%         
%         % time end
%         tEnd = toc(tStart);
%         fprintf('time: %d minutes and %f seconds\n', floor(tEnd/60),rem(tEnd,60));
%         
%         vShifts = mShift;
%         mVesImageShiftAligned = mBestImage;
%         figure; imshow(mVesImage, []);title('Original');
%         figure; imshow(mBestImage, []);title('Impl-1-vis-A');
%         mBestImageFromAmpl = sinusoidShiftVesicleImage(mVesImage, radius, angle, dRadiusInner, mBestAmpl, iShiftFrequencies);
%         figure; imshow(mBestImageFromAmpl, []);title('Impl-1-vis-B');
        
        
        elseif iShiftMethod == 2

            % --------------------------------------------------------------
            % Implementation 2) time: 0 minutes and 23.713264 seconds
            % Original method
            % time: 0 minutes and 21.407749 seconds for
            % circshiftAlignVesicleImage(mVesImageSetShiftAligned(:,:,273), mImMean, 1, mVesImageWinSet(:,:,273), 12, 4, 2, dInnerRadius);
            

            [radius, angle]=meshgrid(1:size(mVesImage,2),1:size(mVesImage,1));
            dMinValue=Inf;
            mBestAmpl = zeros(iShiftFrequencies, 2);
            mAmpl = zeros(iShiftFrequencies, 2);        
            for f = 1:iShiftFrequencies
                for vSinAmplitude = -iMaxShiftAmplitude:0.5:iMaxShiftAmplitude
                    for vCosAmplitude = -iMaxShiftAmplitude:0.5:iMaxShiftAmplitude

                        mAmpl(f, 1) = vSinAmplitude;
                        mAmpl(f, 2) = vCosAmplitude;

                        [mCorrectedVesImage] = sinusoidShiftVesicleImage(mVesImageShiftAligned, radius, angle, dRadiusInner, mAmpl, f);

                        val = norm(mCorrectedVesImage.*mVesWindow - mAlignToImage, 'fro')/sqrt(prod(size(mVesImage)));

                        %figure(1);
                        %imshow(mCorrectedVesImage,[])
                        %title(['Std: ' num2str(val)]);
                        %pause

                        if val<dMinValue
                            dMinValue=val;
                            mBestAmpl(f, 1) = vSinAmplitude;
                            mBestAmpl(f, 2) = vCosAmplitude;

                        end
                    end
                end
                mAmpl = mBestAmpl;  
            end

            % JSB illustration
%             imTMP = sinusoidShiftVesicleImage(mVesImage, radius, angle, dRadiusInner, mBestAmpl, 1);
%             intPOLMin = min(imTMP(:));
%             intPOLMax = max(imTMP(:));
%             imCAR = interpolateVesicleImagePOLtoCAR(imTMP.*mVesWindow, 60, 1.7, 1);
%             intCARMin = min(imCAR(:));
%             intCARMax = max(imCAR(:));
%             figure; imshow(imTMP, [intPOLMin, intPOLMax]);
%             figure; imshow(imCAR, [intCARMin, intCARMax]);
%             imTMP = sinusoidShiftVesicleImage(mVesImage, radius, angle, dRadiusInner, mBestAmpl, 4);
%             imCAR = interpolateVesicleImagePOLtoCAR(imTMP.*mVesWindow, 60, 1.7, 1);
%             figure; imshow(imTMP, [intPOLMin, intPOLMax]);
%             figure; imshow(imCAR, [intCARMin, intCARMax]);
%             imTMP = sinusoidShiftVesicleImage(mVesImage, radius, angle, dRadiusInner, mBestAmpl, 7);
%             imCAR = interpolateVesicleImagePOLtoCAR(imTMP.*mVesWindow, 60, 1.7, 1);
%             figure; imshow(imTMP, [intPOLMin, intPOLMax]);
%             figure; imshow(imCAR, [intCARMin, intCARMax]);
%             imTMP = sinusoidShiftVesicleImage(mVesImage, radius, angle, dRadiusInner, mBestAmpl, 10);
%             imCAR = interpolateVesicleImagePOLtoCAR(imTMP.*mVesWindow, 60, 1.7, 1);
%             figure; imshow(imTMP, [intPOLMin, intPOLMax]);
%             figure; imshow(imCAR, [intCARMin, intCARMax]);
%             imTMP = sinusoidShiftVesicleImage(mVesImage, radius, angle, dRadiusInner, mBestAmpl, 15);
%             imCAR = interpolateVesicleImagePOLtoCAR(imTMP.*mVesWindow, 60, 1.7, 1);
%             figure; imshow(imTMP, [intPOLMin, intPOLMax]);
%             figure; imshow(imCAR, [intCARMin, intCARMax]);
            
            mVesImageShiftAligned = sinusoidShiftVesicleImage(mVesImage, radius, angle, dRadiusInner, mBestAmpl, iShiftFrequencies);
            vShifts = mBestAmpl;
            
        elseif iShiftMethod == 3 || 4
        
        
            % --------------------------------------------------------------
            % Implementation 3) time: 0 minutes and 20.921314 seconds
            % Fast implementation of original method (but more difficult to read)
            % time: 0 minutes and 19.798813 seconds for
            % circshiftAlignVesicleImage(mVesImageSetShiftAligned(:,:,273), mImMean, 1, mVesImageWinSet(:,:,273), 12, 4, 3, dInnerRadius);
            % time: 0 minutes and 24.912004 seconds for
            % circshiftAlignVesicleImage(mVesImageSetShiftAligned(:,:,273), mImMean, 1, mVesImageWinSet(:,:,273), 12, 4, 4, dInnerRadius);

             mDesignMatrix = [sin(2*pi*((1:size(mVesImage,1))')*(1:iShiftFrequencies)/R)...
                              cos(2*pi*((1:size(mVesImage,1))')*(1:iShiftFrequencies)/R)];


            [radius, angle]=meshgrid(1:size(mVesImage,2),1:size(mVesImage,1));
            dMinValue=Inf;
            mBestAmpl = zeros(iShiftFrequencies, 2);
            mAmpl = zeros(iShiftFrequencies, 2);        
            for f = 1:iShiftFrequencies
                for vSinAmplitude = -iMaxShiftAmplitude:0.5:iMaxShiftAmplitude
                    for vCosAmplitude = -iMaxShiftAmplitude:0.5:iMaxShiftAmplitude

                        mAmpl(f, 1) = vSinAmplitude;
                        mAmpl(f, 2) = vCosAmplitude;

                        [mCorrectedVesImage] = sinusoidShiftVesicleImageFast(mVesImageShiftAligned, radius, angle, dRadiusInner, mAmpl, f, mDesignMatrix(:,[1:f iShiftFrequencies+(1:f)]));


                        val = norm(mCorrectedVesImage.*mVesWindow - mAlignToImage, 'fro')/sqrt(prod(size(mVesImage)));

                        %figure(1);
                        %imshow(mCorrectedVesImage,[])
                        %title(['Std: ' num2str(val)]);
                        %pause

                        if val<dMinValue
                            dMinValue=val;
                            mBestAmpl(f, 1) = vSinAmplitude;
                            mBestAmpl(f, 2) = vCosAmplitude;

                        end
                    end
                end
                mAmpl = mBestAmpl;  
            end

            if iShiftMethod ~= 4
            
                mVesImageShiftAligned = sinusoidShiftVesicleImage(mVesImage, radius, angle, dRadiusInner, mBestAmpl, iShiftFrequencies);
                vShifts = mBestAmpl;

        
            else%if iShiftMethod == 4
        
                % Add refinement with twice the frequencies
                options = optimset('Algorithm','levenberg-marquardt');%,'Display','iter');
                [radius, angle]=meshgrid(1:size(mVesImage,2),1:size(mVesImage,1));
                mAmplitudesInit = zeros(iShiftFrequencies*2, 2);
                mAmplitudesInit(1:iShiftFrequencies,:) = mBestAmpl;
                try
                    mAmplitudes = lsqnonlin(@(mAmplitudes)amplitudesResidual(mAmplitudes, mVesImageShiftAligned, double(mAlignToImage), mVesWindow, dRadiusInner, radius, angle), mAmplitudesInit,[],[],options);
                catch err
                    rethrow(err);
                end
                mVesImageShiftAligned = sinusoidShiftVesicleImage(mVesImage, radius, angle, dRadiusInner, mAmplitudes, iShiftFrequencies);
                vShifts = mAmplitudes;
            end
        
         
        
%         % --------------------------------------------------------------
%         % Implementation 5)
%         options = optimset('Algorithm','levenberg-marquardt');
%         [radius, angle]=meshgrid(1:size(mVesImage,2),1:size(mVesImage,1));
%         mAmpl = zeros(iShiftFrequencies, 2);
%         mVesImage2 = mVesImage;
%         for f = 1:iShiftFrequencies
%             mAmplitudesInit = zeros(1, 2);
%             mAmplitudes = lsqnonlin(@(mAmplitudes)amplitudesResidual(mAmplitudes, mVesImage2, mAlignToImage, mVesWindow, dRadiusInner, radius, angle), mAmplitudesInit,[],[],options);
%             mAmpl(f,:) = mAmplitudes;
%             mVesImage2 = sinusoidShiftVesicleImage(mVesImage, radius, angle, dRadiusInner, mAmpl(1:f,:), f);      
%         end
%         figure; imshow(mVesImage2, []);
        
        
        else
            error('Invalid shift sub method');
        end
        
        
        
    else
        error('Invalid parameter');
    end
    
    % time end
    %tEnd = toc(tStart);
    %fprintf('time: %d minutes and %f seconds\n', floor(tEnd/60),rem(tEnd,60));   
    
    %figure; imshow(mVesImage, []); title('Original');
    %figure; imshow(mVesImageShiftAligned, []); title('Aligned');
   
end

function [mShiftedVesImage] = sinusoidShiftVesicleImageFast(mVesImage, mgVesImageRadius, mgVesImageAngle, vRInner, mAmplitudes, iCurFreqIdx, mDesignMatrix)
    
    modifiedRadius = zeros(size(mgVesImageRadius));
    totalShift  = mDesignMatrix*reshape(mAmplitudes(1:iCurFreqIdx,:),2*iCurFreqIdx,1)*ones(1,size(mVesImage,2));
    modifiedRadius(:,1:vRInner) = mgVesImageRadius(:,1:vRInner).*(vRInner-totalShift(:,1:vRInner))/vRInner;
    modifiedRadius(:,(vRInner+1):end) = mgVesImageRadius(:,(vRInner+1):end) -totalShift(:,(vRInner+1):end);
    mShiftedVesImage = reshape(interp2(mVesImage, modifiedRadius(:), mgVesImageAngle(:),'linear',0),size(mVesImage));
    
end


% function [mShiftedVesImage] = sinusoidShiftVesicleImage(mVesImage, mgVesImageRadius, mgVesImageAngle, vRInner, mAmplitudes, iCurFreqIdx)
%     
%     modifiedRadius = zeros(size(mgVesImageRadius));
%     R = size(mVesImage,1);
%     mShift = zeros(size(mVesImage,1), iCurFreqIdx);
%     for f = 1:iCurFreqIdx
%         mShift(:,f) = mAmplitudes(f, 1)*sin(2*pi*((1:size(mVesImage,1))')*f/R)+...
%                           mAmplitudes(f, 2)*cos(2*pi*((1:size(mVesImage,1))')*f/R);
%     end
%     totalShift = sum(mShift,2)*ones(1,size(mVesImage,2));                   
%     modifiedRadius(:,1:vRInner) = mgVesImageRadius(:,1:vRInner).*(vRInner-totalShift(:,1:vRInner))/vRInner;
%     modifiedRadius(:,(vRInner+1):end) = mgVesImageRadius(:,(vRInner+1):end) -totalShift(:,(vRInner+1):end);
%     mShiftedVesImage = reshape(interp2(mVesImage, modifiedRadius(:), mgVesImageAngle(:),'linear',0),size(mVesImage));
%     
% end




function [residual] = amplitudesResidual(mAmplitudes, mVesImage, mAlignToImage, mVesWindow, iRadiusInner, mgVesImageRadius, mgVesImageAngle)

    mCorrectedVesImage = sinusoidShiftVesicleImage(mVesImage, mgVesImageRadius, mgVesImageAngle, iRadiusInner, mAmplitudes, size(mAmplitudes, 1));
    residual = mCorrectedVesImage(:).*mVesWindow(:) - mAlignToImage(:);
end

