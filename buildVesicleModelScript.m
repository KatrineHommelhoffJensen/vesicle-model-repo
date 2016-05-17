%BUILDVESICLEMODELSCRIPT Script that demonstrates how to build a vesicle
%model from a training set of vesicle images (sampled from micrographs) and
%how to use a vesicle model to remove vesicles from a new micrograph.

%   IMSHOW(I) displays the grayscale image I.
%
%   IMSHOW(I,[LOW HIGH]) displays the grayscale image I, specifying the display
%   range for I in [LOW HIGH]. The value LOW (and any value less than LOW)
%   displays as black, the value HIGH (and any value greater than HIGH) displays
%   as white. Values in between are displayed as intermediate shades of gray,
%   using the default number of gray levels. 
%
%   IMSHOW(I,[]) displays the grayscale image I scaling the display based
%   on the range of pixel values in I. IMSHOW uses [min(I(:)) max(I(:))] as
%   the display range, that is, the minimum value in I is displayed as
%   black, and the maximum value is displayed as white.
%
%   IMSHOW(RGB) displays the truecolor image RGB.
%
%   IMSHOW(BW) displays the binary image BW. IMSHOW displays pixels with the
%   value 0 (zero) as black and pixels with the value 1 as white.
%
%   IMSHOW(X,MAP) displays the indexed image X with the colormap MAP.
%
%   IMSHOW(FILENAME) displays the image stored in the graphics file
%   FILENAME. The file must contain an image that IMREAD or DICOMREAD can
%   read. IMSHOW calls IMREAD or DICOMREAD to read the image from the file,
%   but does not store the image data in the MATLAB workspace. If the file
%   contains multiple images, the first one will be displayed. The file
%   must be in the current directory or on the MATLAB path. (DICOMREAD
%   capability and the NITF file format require the Image Processing
%   Toolbox.)
%
%   IMSHOW(IMG,RI,___) displays the image IMG with associated 2-D spatial
%   referencing object RI. IMG may be a grayscale, RGB, or binary image.
%   IMG may also be a graphics file FILENAME. (This syntax requires the
%   Image Processing Toolbox.)
%
%   IMSHOW(I,RI,[LOW HIGH]) displays the grayscale image I with associated
%   2-D spatial referencing object RI and a specified display range for I
%   in [LOW HIGH]. (This syntax requires the Image Processing Toolbox.)
%
%   IMSHOW(X,RX,MAP) displays the indexed image X with associated 2-D
%   spatial referencing object RX and colormap MAP. (This syntax requires
%   the Image Processing Toolbox.)
%
%   HIMAGE = IMSHOW(___) returns the handle to the image object created by
%   IMSHOW.
%
%   IMSHOW(___,PARAM1,VAL1,PARAM2,VAL2,___) displays the image, specifying
%   parameters and corresponding values that control various aspects of the
%   image display. Parameter names can be abbreviated, and case does not matter.
%
%   Parameters include:
%
%   'Border'                 String that controls whether
%                            a border is displayed around the image in the
%                            figure window. Valid strings are 'tight' and
%                            'loose'.
%
%                            Note: There can still be a border if the image
%                            is very small, or if there are other objects
%                            besides the image and its axes in the figure.
%                               
%                            By default, the border is set to 'loose'.
%
%   'Colormap'               2-D, real, M-by-3 matrix specifying a colormap. 
%                            IMSHOW uses this to set the figure's colormap
%                            property. Use this parameter to view grayscale
%                            images in false color.
%
%   'DisplayRange'           Two-element vector [LOW HIGH] that controls the
%                            display range of a grayscale image. See above
%                            for more details about how to set [LOW HIGH].
%
%                            Including the parameter name is optional,
%                            except when the image is specified by a
%                            filename. The syntax IMSHOW(I,[LOW HIGH]) is
%                            equivalent to IMSHOW(I,'DisplayRange',[LOW
%                            HIGH]). The parameter name must be specified
%                            when using IMSHOW with a filename, as in the
%                            syntax IMSHOW(FILENAME,'DisplayRange',[LOW
%                            HIGH]). If I is an integer type,
%                            'DisplayRange' defaults to the minimum and
%                            maximum representable values for that integer
%                            class. For images with floating point data,
%                            the default is [0 1].
%
%   'InitialMagnification'   A numeric scalar value, or the text string 'fit',
%                            that specifies the initial magnification used to 
%                            display the image. When set to 100, the image is 
%                            displayed at 100% magnification. When set to 
%                            'fit' IMSHOW scales the entire image to fit in 
%                            the window.
%
%                            On initial display, the entire image is visible.
%                            If the magnification value would create an image 
%                            that is too large to display on the screen,  
%                            IMSHOW warns and displays the image at the 
%                            largest magnification that fits on the screen.
%
%                            By default, the initial magnification is set to
%                            100%.
%
%                            If the image is displayed in a figure with its
%                            'WindowStyle' property set to 'docked', then
%                            IMSHOW warns and displays the image at the
%                            largest magnification that fits in the figure.
%
%                            Note: If you specify the axes position (using
%                            subplot or axes), imshow ignores any initial
%                            magnification you might have specified and
%                            defaults to the 'fit' behavior.
%
%                            When used with the 'Reduce' parameter, only
%                            'fit' is allowed as an initial magnification.
%
%   'Parent'                 Handle of an axes that specifies
%                            the parent of the image object created
%                            by IMSHOW.
%
%   'Reduce'                 Logical value that specifies whether IMSHOW
%                            subsamples the image in FILENAME. The 'Reduce'
%                            parameter is only valid for TIFF images and
%                            you must specify a filename. Use this
%                            parameter to display overviews of very large
%                            images.
%
%   'XData'                  Two-element vector that establishes a
%                            nondefault spatial coordinate system by
%                            specifying the image XData. The value can
%                            have more than 2 elements, but only the first
%                            and last elements are actually used.
%
%   'YData'                  Two-element vector that establishes a
%                            nondefault spatial coordinate system by
%                            specifying the image YData. The value can
%                            have more than 2 elements, but only the first
%                            and last elements are actually used.
%
%   Class Support
%   -------------  
%   A truecolor image can be uint8, uint16, single, or double. An indexed
%   image can be logical, uint8, single, or double. A grayscale image can
%   be any numeric datatype. A binary image is of class logical.
%
%   If your image is int8, int16, uint32, int32, or single, the CData in
%   the resulting image object will be double. For all other classes, the
%   CData matches the input image class.
% 
%   Image Processing Toolbox Preferences
%   ------------------------------------  
%   If you have the Image Processing Toolbox installed, you can use the
%   IPTSETPREF function to set several toolbox preferences that modify the
%   behavior of IMSHOW:
%
%   - 'ImshowBorder' controls whether IMSHOW displays the image with a border
%     around it.
%
%   - 'ImshowAxesVisible' controls whether IMSHOW displays the image with the
%     axes box and tick labels.
%
%   - 'ImshowInitialMagnification' controls the initial magnification for
%     image display, unless you override it in a particular call by
%     specifying IMSHOW(...,'InitialMagnification',INITIAL_MAG).
%   
%   For more information about these preferences, see the reference entry for
%   IPTSETPREF.
%   
%   Remarks
%   -------
%   IMSHOW is the fundamental image display function in MATLAB, optimizing
%   figure, axes, and image object property settings for image display. If
%   you have the Image Processing Toolbox installed, IMTOOL provides all
%   the image display capabilities of IMSHOW but also provides access to
%   several other tools for navigating and exploring images, such as the
%   Pixel Region tool, Image Information tool, and the Adjust Contrast
%   tool. IMTOOL presents an integrated environment for displaying images
%   and performing some common image processing tasks.
%
%   The IMSHOW function is not supported when MATLAB is started with the
%   -nojvm option.
%
%   Examples
%   --------
%
%       % Display an indexed image
%       imdata = load('clown.mat');
%       imshow(imdata.X,imdata.map) 
%
%
%   Examples (Requires Image Processing Toolbox)
%   --------------------------------------------
%       % Display a grayscale image 
%       I = imread('cameraman.tif');
%       imshow(I) 
%
%       % Display a grayscale image, adjust the display range
%       h = imshow(I,[0 80]);
%
%       % Display a grayscale image with an associated spatial referencing
%       % object.
%       I = imread('pout.tif');
%       RI = imref2d(size(I));
%       RI.XWorldLimits = [0 3];
%       RI.YWorldLimits = [2 5];
%       imshow(I,RI);
%
%   See also IMREAD, IMAGE, IMAGESC.

%   Copyright 1993-2014 The MathWorks, Inc.

close all;

% ====================================================================
% Initiate vesicle model parameters and structures
% ====================================================================

stParameters = getParameters();

mVesicleTrainingSet = [];
mVesicleTrainingSetWin = [];

% ====================================================================
% Extract training vesicle images from micrographs
% ====================================================================

for idx=1:stParameters.iNrOfTrainingMics
    
    iMicrographId = stParameters.vTrainingMicIdxs(idx);
    [mMicrograph, x, y, r] = stParameters.ReadTrainMicAndVesDataFunc(stParameters, iMicrographId);
            
    mMicrographBinaryVesicles = createBinaryVesicleMicrograph(size(mMicrograph), x, y, r, stParameters.dBetaBGWin);
    mMicrographBinaryVesicles(:) = ~mMicrographBinaryVesicles(:);
    [mSet, mWin] = getVesicleImageStackFromMicrograph(mMicrograph, x, y, r, stParameters, mMicrographBinaryVesicles);
    clear mMicrographBinaryVesicles;
    
    mVesicleTrainingSet = cat(3, mVesicleTrainingSet, mSet);
    mVesicleTrainingSetWin = cat(3, mVesicleTrainingSetWin, mWin);

    clear mMicrograph;  
    clear mSet;
    clear mWin;
end

% ====================================================================
% Calculate vesicle model from training vesicle images and parameters
% ====================================================================

stVesicleModel = buildVesicleModel(stParameters, mVesicleTrainingSet, mVesicleTrainingSetWin);

clear mVesicleTrainingSet;
clear mVesicleTrainingSetWin;

% ====================================================================
% Use vesicle model to remove vesicles from new micrograph
% ====================================================================

removeVesiclesFromMicrographs(stVesicleModel.stParameters.sSaveToDir, stVesicleModel.sName);


close all;















