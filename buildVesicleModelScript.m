%BUILDVESICLEMODELSCRIPT Script that demonstrates how to build a vesicle
%model from a training set of vesicle images (sampled from micrographs) and
%how to use a vesicle model to remove vesicles from a new micrograph.


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

stVesicleModel = readVesicleModel(stVesicleModel.stParameters.sSaveToDir, stVesicleModel.sName);

for micIdx=1:stVesicleModel.stParameters.iNrOfNewMics

    micrographId = stVesicleModel.stParameters.vNewMicIdxs(micIdx);

    [mTestMicrograph, dTestVesicleCntX, dTestVesicleCntY, dTestVesicleR] = stVesicleModel.stParameters.ReadNewMicAndVesDataFunc(stVesicleModel.stParameters, micrographId);

    removeVesiclesFromMicrograph(stVesicleModel, stVesicleModel.stParameters.iPrincComp, 0, 0, mTestMicrograph, dTestVesicleCntX, dTestVesicleCntY, dTestVesicleR, 1, num2str(micrographId));

    close all;
end


close all;















