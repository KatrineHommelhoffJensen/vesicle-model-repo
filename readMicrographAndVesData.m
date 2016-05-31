function [mMicrograph, dVesicleCntX, dVesicleCntY, dVesicleR] = readMicrographAndVesData(stParameters, bTrainingMic, micrographId)

    if bTrainingMic
        stMicData = load(strcat(stParameters.sDataDirTrainingMics, 'MicData_', num2str(micrographId), '.mat'));
    else
        stMicData = load(strcat(stParameters.sDataDirNewMics, 'MicData_', num2str(micrographId), '.mat'));  
    end
                  
    dVesicleCntX = stMicData.dVesicleCntX;
    dVesicleCntY = stMicData.dVesicleCntY;
    dVesicleR = stMicData.dVesicleR;
    mMicrograph = stMicData.mMicrograph;
    clear stMicData;
            
end