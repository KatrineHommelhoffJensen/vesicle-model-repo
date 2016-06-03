%GETSTACKIMAGEPIXELSINMICROGRAPH Function that interpolates vesicle image
%pixels from the micrograph into normalised (meshgrid) form, given the
%vesicle position and radius

function [mImagePixelsInMicExtForInterp, XabsForInterp, YabsForInterp, mImagePixelsInMicExtForInterpWin, mImagePixelsInMicExtForInterpBGWin, vImagePixelsCropInfo, mVesXrelR, mVesYrelA, mImagePixelsInMicExtForInterpHardWin] = getStackImagePixelsInMicrograph(mMicrograph, mXabsVes, mYabsVes, bCreateWindows, dRadiusVes, dBeta, dAlpha, mMicrographBinaryVesicles, bAddHardVesWin, bCalcCropInfo, dMaxRR, dXVes, dYVes, iVesShapeInterpMethod, dWallThickness)
     
    mImagePixelsInMicExtForInterp = [];
    mImagePixelsInMicExtForInterpWin = [];
    mImagePixelsInMicExtForInterpBGWin = [];
    XabsForInterp = [];
    YabsForInterp = [];
    mImagePixelsInMicExtForInterpHardWin = [];
    vImagePixelsCropInfo = [];
    mVesXrelR = []; 
    mVesYrelA = [];
        
    
    XcntVal = mXabsVes(1, floor(length(mXabsVes(1,:))/2) + 1);
    Xcnt = floor(XcntVal); % The relevant pixel value

    YcntVal = mYabsVes(floor(length(mYabsVes(:,1))/2) + 1, 1);
    Ycnt = floor(YcntVal); % The relevant pixel value

    offset = max(Xcnt - floor(min(mXabsVes(:))), Ycnt - floor(min(mYabsVes(:))));
    
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
        

        if nargin > 9 && bCalcCropInfo
                    
            
            
            vImagePixelsCropInfo = zeros(8,1);
            
            dRadiusDestVes = dRadiusVes;
            dRadiusOrigVes = dRadiusVes;
            dXOrigVes = dXVes;
            dYOrigVes = dYVes;
            
            
            [Xabs, Yabs] = createVesInterpAbsoluteMeshGrids(dRadiusDestVes, XrelR, YrelA, dXOrigVes, dYOrigVes, dRadiusOrigVes, iVesShapeInterpMethod, dWallThickness);
            Xabs = reshape(Xabs, size(XrelR,1), size(XrelR,2));
            Yabs = reshape(Yabs, size(XrelR,1), size(XrelR,2));
                        
            if length(floor(min(Yabs(:))):ceil(max(Yabs(:)))) ~= length(floor(min(Xabs(:))):ceil(max(Xabs(:))))
                error('Invalid image dimensions!');
            end
            
            vImagePixelsCropInfo(5:8) = [round(min(Yabs(:))), round(max(Yabs(:))), round(min(Xabs(:))), round(max(Xabs(:)))];
            mImagePixelsInMic = mMicrograph(vImagePixelsCropInfo(5):vImagePixelsCropInfo(6), vImagePixelsCropInfo(7):vImagePixelsCropInfo(8));
            if size(mImagePixelsInMic,1) ~= size(Xabs,1)
                error('Invalid image dimensions!');
            end
            
            
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
          
        
        if bCreateWindows

            ptVesicleCnt = [YabsForInterp(floor(length(YabsForInterp(:,1))/2) + 1, 1), XabsForInterp(1, floor(length(XabsForInterp(1,:))/2) + 1)];
            mImagePixelsInMicExtForInterpWin = createVesicleImageSignalWindow(size(mImagePixelsInMicExtForInterp), dRadiusVes, ptVesicleCnt, dBeta, dAlpha, 1);

            if nargin > 8 && bAddHardVesWin
                mImagePixelsInMicExtForInterpHardWin = createVesicleImageSignalWindow(size(mImagePixelsInMicExtForInterp), dRadiusVes, ptVesicleCnt, dBeta, dAlpha, 0);
            end
            
            if size(mMicrographBinaryVesicles,1) > 0

                mImagePixelsInMicExtForInterpBGWin = mMicrographBinaryVesicles(Ycnt-offset:Ycnt+offset, Xcnt-offset:Xcnt+offset);
                
            end

        end

    end

end    
