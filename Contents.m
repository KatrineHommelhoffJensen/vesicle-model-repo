% PUBLISHED CODE
%
% Files
%   buildVesicleModel_hosvd                - 
%   buildVesicleModelScript                - Display image in Handle Graphics figure.  
%   calculateMeanPolVesicleImage           - Always returns windowed, aligned vesicle images and windowed mean
%   circshiftAlignVesicleImage             - 
%   cleanVesicleImage                      - Removes Inf and NaN
%   createBinaryVesicleMicrograph          - Creates a micrograph with 1's in pixels belonging to a vesicle, 0's otherwise. 
%   createVesicleImageSignalWindow         - From the image size and relative radius, the function creates a Tukey
%   createVesInterpAbsoluteMeshGrids       - Uses relative meshgrids (R, A) and information about actual location
%   createVesInterpAbsoluteMeshGridsForMic - Extract stack of vesicle images from micrograph
%   createVesInterpRelativeMeshGrids       - Creates relative mesh grids (containing relative positions), in the
%   getParameters                          - 
%   getStackImagePixelsInMicrograph        - From a stacked image in any given format, return its original pixel
%   getVesicleImageStackFromMicrograph     - 
%   getVesicleImageWinDeviation            - Returns the deviation of the image inside the window
%   getVesicleImageWinMedian               - 
%   getVesiclePixelsInImage                - Creates an image with 1's in pixels belonging to a vesicle, 0's otherwise.
%   interpolateImagePixels                 - Interpolates pixel values from image mImOrig to image mImInterpStack
%   interpolateVesicleImagePOLtoCAR        - 
%   isValidVesicleBGImage                  - 
%   isValidVesicleImage                    - 
%   normalizeVesicleImage                  - Normalizes a vesicle image according to a method specified by iVesImNormMethod
%   pathdef                                - Search path defaults.
%   projectImageOnModel                    - Projects the image mIm onto the residual subspace of the model: The
%   projectImageOnModelComponent           - 
%   readVesicleModel                       - 
%   removeVesicleFromImage                 - Handles subtraction of a vesicle structure from an image, including
%   removeVesiclesFromMicrograph           - We assume the micrograph is already median subtracted
%   removeVesiclesFromMicrographs          - 
%   resizeInterpolateVesicleImage          - Resizes vesicle image while respecting interpolation rules tied to the 
%   reverseNormalizeVesicleImage           - Undos vesicle image normalization according to a method specified by iVesImNormMethod
%   saveVesicleModel                       - 
%   saveVesicleSubtractedMicrograph        - 
%   sinusoidShiftVesicleImage              - 
