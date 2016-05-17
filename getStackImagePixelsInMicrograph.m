
% From a stacked image in any given format, return its original pixel
% values, given the stack information and original micrograph

% iStackImageID: ID of the stacked image of interest
% mMicrograph: The micrograph from which it was generated
% X, Y: Interpolation information

% Notice: Due to the purpose of interpolation, the pixels returned have a
% larger dimension than necessary (+ offset), but for the purpose of
% scaling values from the interpolated image and back, a crop value is
% returned so that the images mImageInterp and
% crop(mImagePixelsInMicExtForInterp, iImCropSize) are completely equivalent

% INPUT:
% * mMicrograph: Micrograph to extract raw vesicle pixels from
% * mXabsVes, mYabsVes: Absolute meshgrids for interpolating the
% vesicle pixel values from mMicrograph and into a normalised grid

% OUTPUT
% * mImagePixelsInMicExtForInterp: Boxed out, raw image pixels from the
% micrograph, which should be used for interpolation into the shape
% normalised grid - it is a little bigger than the actual involved pixels,
% to account for a correct bicubic interpolation
% * XabsForInterp, YabsForInterp: Absolute meshgrids for interpolating the
% vesicle pixel values from mImagePixelsInMicExtForInterp and into a
% normalised grid
% * mImagePixelsInMicExtForInterpWin, mImagePixelsInMicExtForInterpBGWin,
% mImagePixelsInMicExtForInterpHardWin: Windows sized for
% mImagePixelsInMicExtForInterp 
% * vImagePixelsCropInfo: pixel positions in mImagePixelsInMicExtForInterp
% (idx 1-4) and mMicrograph (idx 5-8) which indicate where to cut out the
% raw, original vesicle image pixels to use for removal
% * mVesXrelR, mVesYrelA: Relative grid to interpolate from another image
% and onto the raw vesicle image. Used later in
% resizeInterpolateVesicleImage, and generally for interpolating the model
% mean and components onto the raw vesicle pixels


%function [mImagePixelsInMicExtForInterp, XabsForInterp, YabsForInterp, mImagePixelsInMicExtForInterpWin, mImagePixelsInMicExtForInterpBGWin, iImCropSize, mImBoxXcrop, mImBoxYcrop, mImagePixelsInMicExtForInterpHardWin] = getStackImagePixelsInMicrograph(mMicrograph, mXves, mYves, bCreateWindows, dRadiusVes, dBeta, dAlpha, mMicrographBinaryVesicles, bAddHardVesWin, bCalcCropInfo, dMaxRR, dMaxRfac, dXVes, dYVes)
function [mImagePixelsInMicExtForInterp, XabsForInterp, YabsForInterp, mImagePixelsInMicExtForInterpWin, mImagePixelsInMicExtForInterpBGWin, vImagePixelsCropInfo, mVesXrelR, mVesYrelA, mImagePixelsInMicExtForInterpHardWin] = getStackImagePixelsInMicrograph(mMicrograph, mXabsVes, mYabsVes, bCreateWindows, dRadiusVes, dBeta, dAlpha, mMicrographBinaryVesicles, bAddHardVesWin, bCalcCropInfo, dMaxRR, dXVes, dYVes, iVesShapeInterpMethod, dWallThickness)
    
    % The coordinates of the stacked image iStackImageID in the
    % original micrograph, are given by:
    % round(X(:,:,iStackImageID))
    % round(Y(:,:,iStackImageID))
         
    
    mImagePixelsInMicExtForInterp = [];
    mImagePixelsInMicExtForInterpWin = [];
    mImagePixelsInMicExtForInterpBGWin = [];
    XabsForInterp = [];
    YabsForInterp = [];
    mImagePixelsInMicExtForInterpHardWin = [];
    % KHJ addded 18.08.15:
    vImagePixelsCropInfo = [];
    mVesXrelR = []; 
    mVesYrelA = [];
        
    
    % The corresponding, original image is thus given by
    % mXves = X(:, :, vesIdx);
    XcntVal = mXabsVes(1, floor(length(mXabsVes(1,:))/2) + 1);
    Xcnt = floor(XcntVal); % The relevant pixel value

    % mYves = Y(:, :, vesIdx);
    YcntVal = mYabsVes(floor(length(mYabsVes(:,1))/2) + 1, 1);
    Ycnt = floor(YcntVal); % The relevant pixel value

    offset = max(Xcnt - floor(min(mXabsVes(:))), Ycnt - floor(min(mYabsVes(:))));
    
    % Essential with constant on offset: interp2 takes values from
    % the surrounding area (at least 10 %): We need however to find out,
    % how big an amount we need to interpolate (depends on the size in
    % shape norm meth 2) 
    
    if nargin > 9 && bCalcCropInfo
        
        [Xrel, Yrel, dummy, XrelR, YrelA] = createVesInterpRelativeMeshGrids('CAR', dRadiusVes, dMaxRR);
        offset = floor(size(XrelR,1)/2) + 1;
        
        if size(XrelR,1) > (2*offset)
            error('Invalid image format');
        end
    else
        offset = offset + round(offset/10);
    end
    

    if (Ycnt-offset >= 1) && (Ycnt+offset <= size(mMicrograph, 1)) && (Xcnt-offset >= 1) && (Xcnt+offset <= size(mMicrograph, 2))

        mImBoxX = [Xcnt-offset; Xcnt+offset];
        mImBoxY = [Ycnt-offset; Ycnt+offset];
        mImagePixelsInMicExtForInterp = mMicrograph(mImBoxY(1):mImBoxY(2), mImBoxX(1):mImBoxX(2));

        newCnt = ceil(size(mImagePixelsInMicExtForInterp, 1)/2);
        if mMicrograph(Ycnt, Xcnt) ~= mImagePixelsInMicExtForInterp(newCnt, newCnt)
            error('Pixel centering error');
        end

        XabsForInterp = mXabsVes - (Xcnt - newCnt);
        YabsForInterp = mYabsVes - (Ycnt - newCnt);
        % Example: Xcnt == 559, newCnt == 101
        % mXves(1, 69) == 559.1258 -> XabsForInterp(1, 69) == 101.1258
        
        
        % -------------------
        % New impl: Replace crop with pixel 'crop' indices which matches
        % the size of interpolation given by
        % createVesInterpRelativeMeshGrids - this way we can interpolate
        % the model values onto the raw images

        if nargin > 9 && bCalcCropInfo
                    
            %if dRadiusVes > 100
            %    keyboard;
            %end
            
            vImagePixelsCropInfo = zeros(8,1);
            
            dRadiusDestVes = dRadiusVes;
            dRadiusOrigVes = dRadiusVes;
            dXOrigVes = dXVes;
            dYOrigVes = dYVes;
            %[Xrel, Yrel, dummy, XrelR, YrelA] = createVesInterpRelativeMeshGrids('CAR', dRadiusDestVes, dMaxRR, dMaxRfac);
            
            % Notice: If dRadiusVes is larger than maxR, then the size of
            % XrelR should be larger than that of
            % mImagePixelsInMicExtForInterp, This however, also means that
            % we cannot interpolate from mImagePixelsInMicExtForInterp
            % because we lack the information!!!
            
            
            % 1) Absolute grids for interpolating values from mMicrograph
            % and into raw pixel box - to get cropping coordinates in
            % mMicrograph 
            
            
            [Xabs, Yabs] = createVesInterpAbsoluteMeshGrids(dRadiusDestVes, XrelR, YrelA, dXOrigVes, dYOrigVes, dRadiusOrigVes, iVesShapeInterpMethod, dWallThickness);
            Xabs = reshape(Xabs, size(XrelR,1), size(XrelR,2));
            Yabs = reshape(Yabs, size(XrelR,1), size(XrelR,2));
            
%             if sum(Xabs(:)-Xabs(:)) ~= 0
%                 error('Invalid image dimensions!');
%             end
            
            if length(floor(min(Yabs(:))):ceil(max(Yabs(:)))) ~= length(floor(min(Xabs(:))):ceil(max(Xabs(:))))
                error('Invalid image dimensions!');
            end
            
            vImagePixelsCropInfo(5:8) = [round(min(Yabs(:))), round(max(Yabs(:))), round(min(Xabs(:))), round(max(Xabs(:)))];
            mImagePixelsInMic = mMicrograph(vImagePixelsCropInfo(5):vImagePixelsCropInfo(6), vImagePixelsCropInfo(7):vImagePixelsCropInfo(8));
            if size(mImagePixelsInMic,1) ~= size(Xabs,1)
                error('Invalid image dimensions!');
            end
            
            
            % Notice: In shapenormmeth (2) If mXabsVes is smaller than
            % Xabs, then it also needs less amounts of pixels to
            % interpolate from and mImagePixelsInMic3 will thus be smaller
            % than mImagePixelsInMic!
            %vImagePixelsCropInfoTest(5:8) = [round(min(mYabsVes(:))), round(max(mYabsVes(:))), round(min(mXabsVes(:))), round(max(mXabsVes(:)))];
            %mImagePixelsInMic3 = mMicrograph(vImagePixelsCropInfoTest(5):vImagePixelsCropInfoTest(6), vImagePixelsCropInfoTest(7):vImagePixelsCropInfoTest(8));
            
            
            % 2) Absolute grids for interpolating values from 
            % mImagePixelsInMicExtForInterp and into raw pixel box - to get
            % cropping coordinates in mImagePixelsInMicExtForInterp
            
            
            % Now we take the pixels out of mImagePixelsInMicExtForInterp
            dXOrigVes = dXVes - (Xcnt - newCnt);
            dYOrigVes = dYVes - (Ycnt - newCnt);

            [Xabs, Yabs] = createVesInterpAbsoluteMeshGrids(dRadiusDestVes, XrelR, YrelA, dXOrigVes, dYOrigVes, dRadiusOrigVes, iVesShapeInterpMethod, dWallThickness);
            Xabs = reshape(Xabs, size(XrelR,1), size(XrelR,2));
            Yabs = reshape(Yabs, size(XrelR,1), size(XrelR,2));
            
            
            vImagePixelsCropInfo(1:4) = [round(min(Yabs(:))), round(max(Yabs(:))), round(min(Xabs(:))), round(max(Xabs(:)))];
            mImagePixelsInMic2 = mImagePixelsInMicExtForInterp(vImagePixelsCropInfo(1):vImagePixelsCropInfo(2), vImagePixelsCropInfo(3):vImagePixelsCropInfo(4));
        
            if sum(mImagePixelsInMic(:)-mImagePixelsInMic2(:)) ~= 0
                error('Invalid image dimensions!');
            end
            
            % return new values
            mVesXrelR = XrelR;
            mVesYrelA = YrelA;
        end
        
        % -------------------
        
        
        
        
        if bCreateWindows

            ptVesicleCnt = [YabsForInterp(floor(length(YabsForInterp(:,1))/2) + 1, 1), XabsForInterp(1, floor(length(XabsForInterp(1,:))/2) + 1)];
            mImagePixelsInMicExtForInterpWin = createVesicleImageSignalWindow(size(mImagePixelsInMicExtForInterp), dRadiusVes, ptVesicleCnt, dBeta, dAlpha, 1);

            if nargin > 8 && bAddHardVesWin
                mImagePixelsInMicExtForInterpHardWin = createVesicleImageSignalWindow(size(mImagePixelsInMicExtForInterp), dRadiusVes, ptVesicleCnt, dBeta, dAlpha, 0);
            end
            
            if size(mMicrographBinaryVesicles,1) > 0

                mImagePixelsInMicExtForInterpBGWin = mMicrographBinaryVesicles(Ycnt-offset:Ycnt+offset, Xcnt-offset:Xcnt+offset);
                % local area

            end

        end

    end

end    
