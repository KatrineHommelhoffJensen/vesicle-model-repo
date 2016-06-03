%GETVESICLEIMAGESTACKFROMMICROGRAPH Function that extracts and interpolates
%vesicle image pixels from the micrograph, given a set of vesicle center
%positions and radii


function [mVesicleImStack, mVesicleImWinStackInterp] = getVesicleImageStackFromMicrograph(mMicrograph, vVesicleCntX, vVesicleCntY, vVesicleR, stParameters, mMicrographBinaryVesicles)

    iNrOfVesicles = length(vVesicleR);   
        
        
    [Xabs, Yabs, mVesicleImWinStackInterpTmp, mVesicleImBGWinStackInterpTmp, Rabs] = createVesInterpAbsoluteMeshGridsForMic('POL', vVesicleCntX, vVesicleCntY, vVesicleR, stParameters, mMicrographBinaryVesicles);

    % Interpolating image wise
    mVesicleImStackTmp = zeros(size(mVesicleImWinStackInterpTmp,1)*size(mVesicleImWinStackInterpTmp,2), iNrOfVesicles);
    iNewNrOfVesicles = 0;
    for vesIdx = 1:iNrOfVesicles

        Xtmp = Xabs(:, :, vesIdx);
        Ytmp = Yabs(:, :, vesIdx);
        [mImagePixelsInMicrograph, mXvesIm, mYvesIm, mImagePixelsVesicleWin, mImagePixelsBGWin] = getStackImagePixelsInMicrograph(mMicrograph, Xtmp(:), Ytmp(:), 1, vVesicleR(vesIdx), stParameters.dBeta, stParameters.dAlpha, mMicrographBinaryVesicles);

        if isValidVesicleImage(mImagePixelsInMicrograph) && isValidVesicleBGImage(mImagePixelsBGWin)

            mImagePixelsInMicrograph = normalizeVesicleImage(mImagePixelsInMicrograph, mImagePixelsVesicleWin, mImagePixelsBGWin, 0);
            Rabstmp = Rabs(:,:,vesIdx);
            im = 1/sqrt(2*pi)*sqrt(Rabstmp(:)).*interpolateImagePixels(mImagePixelsInMicrograph, mXvesIm, mYvesIm);%.*winIterp(:);
            im(isnan(im(:)))=0;
            mVesicleImStackTmp(:,vesIdx) = im;

        else

            iNewNrOfVesicles = iNewNrOfVesicles + 1;

        end

    end

    mVesicleImStackTmp = mVesicleImStackTmp(:);
    mVesicleImStackTmp = reshape(mVesicleImStackTmp, size(mVesicleImWinStackInterpTmp));

    iNewNrOfVesicles = iNrOfVesicles - iNewNrOfVesicles;
    mVesicleImStack = zeros(size(mVesicleImWinStackInterpTmp,1), size(mVesicleImWinStackInterpTmp,2), iNewNrOfVesicles);
    mVesicleImWinStackInterp = zeros(size(mVesicleImWinStackInterpTmp,1), size(mVesicleImWinStackInterpTmp,2), iNewNrOfVesicles);
    vesCount = 1;
    for vesIdx = 1:iNrOfVesicles
        im = mVesicleImStackTmp(:,:,vesIdx);
        if sum(im(:)) ~= 0
            mVesicleImStack(:,:,vesCount) = im;
            mVesicleImWinStackInterp(:,:,vesCount) = mVesicleImWinStackInterpTmp(:,:,vesCount);
            vesCount = vesCount + 1;
        end
    end

    clear iNewNrOfVesicles;
    clear mVesicleImStackTmp;
    clear mVesicleImWinStackInterpTmp;
    clear mVesicleImBGWinStackInterpTmp;
    clear X;
    clear Y;
    
end    
