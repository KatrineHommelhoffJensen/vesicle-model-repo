

function removeVesiclesFromMicrographs(sModelDir, sModelName)

    stVesicleModel = readVesicleModel(sModelDir, sModelName);


    for micIdx=1:stVesicleModel.stParameters.iNrOfNewMics

        micrographId = stVesicleModel.stParameters.vNewMicIdxs(micIdx);

        [mTestMicrograph, dTestVesicleCntX, dTestVesicleCntY, dTestVesicleR] = stVesicleModel.stParameters.ReadNewMicAndVesDataFunc(stVesicleModel.stParameters, micrographId);

        sTestMicText = num2str(micrographId);

        

        [mMicrographVesiclesSubtracted, vesicleIdxRemoved, hFigBefore, hFigAfter] = removeVesiclesFromMicrograph(stVesicleModel, stVesicleModel.stParameters.iPrincComp, 0, 0, mTestMicrograph, dTestVesicleCntX, dTestVesicleCntY, dTestVesicleR, 1, sTestMicText, 0);
        saveAsKeepSize(hFigBefore, strcat(stVesicleModel.stParameters.sSaveToDir, stVesicleModel.sName, '-before-vesicle-subtraction-mic-', sTestMicText, strcat('.pdf')));
        saveAsKeepSize(hFigAfter, strcat(stVesicleModel.stParameters.sSaveToDir, stVesicleModel.sName, '-after-vesicle-subtraction-mic-', sTestMicText, strcat('.pdf')));
        save(strcat(stVesicleModel.stParameters.sSaveToDir, stVesicleModel.sName, '-after-vesicle-subtraction-mic-', sTestMicText, strcat('.mat')), 'mMicrographVesiclesSubtracted');

        close all;
    end

end











