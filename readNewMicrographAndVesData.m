function [mMicrograph, dVesicleCntX, dVesicleCntY, dVesicleR] = readNewMicrographAndVesData(stParameters, micrographId)

    [mMicrograph, dVesicleCntX, dVesicleCntY, dVesicleR] = readMicrographAndVesData(stParameters, 0, micrographId);

end