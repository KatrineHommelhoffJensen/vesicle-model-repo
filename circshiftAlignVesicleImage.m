%CIRCSHIFTALIGNVESICLEIMAGE Function that aligns a polar coordinate vesicle
%image mVesImage to another, mAlignToImage (one of them will typically be a
%vesicle mean), by shifting it horisontally according to a sinusoidal curve,
%the parameters of which is estimated to give the smallest error when
%comparing the aligned images. The aligned image is returned in
%mVesImageShiftAligned and the shifts used are recorded and returned in
%vShifts.
%
%   Parameters include:
%
%   'mVesImage'             Vesicle image to be aligned
%
%   'mAlignToImage'         Vesicle image to be aligned to
%
%   'iShiftFrequencies'     Number of frequences (coefficients) in sinusoid
%                           to be estimated
%
%   'iMaxShiftAmplitude'    Maximum amplitude to be used in estimate
%
%   'dRadiusInner'          Inner radius (inner side of vesicle wall) of
%                           shape normalised, polar coordinate vesicle
%                           image
%
%   'bBlurAlignToImage'     If 1, then convolve image with Gaussian filter
%                           before alignment, to remove noise and enhance
%                           vesicle wall features 
%


function [vShifts, mVesImageShiftAligned] = circshiftAlignVesicleImage(mVesImage, mAlignToImage, iShiftFrequencies, iMaxShiftAmplitude, dRadiusInner, bBlurAlignToImage)
 
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
        
    iMaxShiftAmplitudeApprox = round(iMaxShiftAmplitude*1.7); 
    vShifts = zeros(1, R);

    for iRowIdx = 1:size(mVesImage,1)
        dMinValue = mean(mean((mAlignToImage - mVesImageShiftAligned).^2));
        vShifts(iRowIdx) = 0; %no shift
        for iColIdx = [-iMaxShiftAmplitudeApprox:iMaxShiftAmplitudeApprox]
            mImTmp = mVesImageShiftAligned;
            mImTmp(iRowIdx,:) = circshift(mImTmp(iRowIdx,:), [0,iColIdx]);
            val = mean(mean((mAlignToImage - mImTmp).^2));
            if val < dMinValue
                dMinValue = val;
                vShifts(iRowIdx) = iColIdx;
            end
        end
    end
            
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
              
    vShifts = zeros(iShiftFrequencies, 2);
    vShifts(:,1) = vAmplitudes1;
    vShifts(:,2) = vAmplitudes2;
    [radius, angle]=meshgrid(1:size(mVesImage,2),1:size(mVesImage,1));
    mVesImageShiftAligned = sinusoidShiftVesicleImage(mVesImage, radius, angle, dRadiusInner, vShifts);
        
end



