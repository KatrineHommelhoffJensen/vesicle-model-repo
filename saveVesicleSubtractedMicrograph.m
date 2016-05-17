function saveVesicleSubtractedMicrograph(sDestDir, mMicrograph, sName, dVesicleCntX, dVesicleCntY, dVesicleR, vVesicleIdxRemoved, sModelName, iPrincCompReg, iPrincCompRad, iPrincCompAng)

    stVesicleSubMic.mMicrograph = mMicrograph;
    stVesicleSubMic.sName = sName;
    stVesicleSubMic.dVesicleCntX = dVesicleCntX;
    stVesicleSubMic.dVesicleCntY = dVesicleCntY;
    stVesicleSubMic.dVesicleR = dVesicleR;
    stVesicleSubMic.vVesicleIdxRemoved = vVesicleIdxRemoved;
    stVesicleSubMic.sModelName = sModelName;
    stVesicleSubMic.iPrincCompReg = iPrincCompReg;
    stVesicleSubMic.iPrincCompRad = iPrincCompRad;
    stVesicleSubMic.iPrincCompAng = iPrincCompAng;

    save(strcat(sDestDir, sName, '.mat'), '-struct', 'stVesicleSubMic');   
end