function [mMicrograph, dVesicleCntX, dVesicleCntY, dVesicleR] = readTrainMicrographAndVesData(stParameters, micrographId)

    [mMicrograph, dVesicleCntX, dVesicleCntY, dVesicleR] = readMicrographAndVesData(stParameters, 1, micrographId);

end