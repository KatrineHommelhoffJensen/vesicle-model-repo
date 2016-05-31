%SAVEVESICLESUBTRACTEDMICROGRAPH Function saves the micrograph after
%vesicle removal, in the folder specified in 'getParameters.m', and plots
%and saves images before and after removal, with the removed vesicle
%centers marked in blue, the rest in red.

function saveVesicleSubtractedMicrograph(stVesicleModel, mMicrograph, mMicrographVesiclesSubtracted, sName, dVesicleCntX, dVesicleCntY, dVesicleR, vVesicleIdxRemoved, iPrincCompReg, iPrincCompRad, iPrincCompAng, sTestMicText)

    stVesicleSubMic.mMicrograph = mMicrographVesiclesSubtracted;
    stVesicleSubMic.sName = sName;
    stVesicleSubMic.dVesicleCntX = dVesicleCntX;
    stVesicleSubMic.dVesicleCntY = dVesicleCntY;
    stVesicleSubMic.dVesicleR = dVesicleR;
    stVesicleSubMic.vVesicleIdxRemoved = vVesicleIdxRemoved;
    stVesicleSubMic.sModelName = stVesicleModel.sName;
    stVesicleSubMic.iPrincCompReg = iPrincCompReg;
    stVesicleSubMic.iPrincCompRad = iPrincCompRad;
    stVesicleSubMic.iPrincCompAng = iPrincCompAng;

    save(strcat(stVesicleModel.stParameters.sSaveToDir, sName, '.mat'), '-struct', 'stVesicleSubMic');
    
    iNrOfVesicles = length(dVesicleR);
    
    h = figure;
    stdFigSize = get(h, 'Position'); close(h);
    hFigBefore = figure('Position',[stdFigSize(1),stdFigSize(2),stdFigSize(3)+70,stdFigSize(3)]); 
    if 0
        imagesc(GaussFilt(mMicrograph, 0.1)); colormap gray; axis xy; hold on;
    else
        imagesc(mMicrograph); colormap gray; axis xy; hold on;
    end
    for vesicleIdx=1:iNrOfVesicles
        if vVesicleIdxRemoved(vesicleIdx)
            plot(dVesicleCntX(vesicleIdx),dVesicleCntY(vesicleIdx),'b.');
        else
            plot(dVesicleCntX(vesicleIdx),dVesicleCntY(vesicleIdx),'r.');
        end
    end
    title(char(stVesicleModel.sName, 'Micrograph before vesicle subtraction, gauss filtered'));

    hFigAfter = figure('Position',[stdFigSize(1),stdFigSize(2),stdFigSize(3)+70,stdFigSize(3)]); 
    if 0
        imagesc(GaussFilt(mMicrographVesiclesSubtracted, 0.1)); colormap gray; axis xy; hold on;
    else
        imagesc(mMicrographVesiclesSubtracted); colormap gray; axis xy; hold on;
    end
    for vesicleIdx=1:iNrOfVesicles
        if vVesicleIdxRemoved(vesicleIdx)
            plot(dVesicleCntX(vesicleIdx),dVesicleCntY(vesicleIdx),'b.');
        else
            plot(dVesicleCntX(vesicleIdx),dVesicleCntY(vesicleIdx),'r.');
        end
    end
    title(char(stVesicleModel.sName, 'Micrograph after vesicle subtraction, gauss filtered'));


    saveAsKeepSize(hFigBefore, strcat(stVesicleModel.stParameters.sSaveToDir, stVesicleModel.sName, '-before-vesicle-subtraction-mic-', sTestMicText, strcat('.pdf')));
    saveAsKeepSize(hFigAfter, strcat(stVesicleModel.stParameters.sSaveToDir, stVesicleModel.sName, '-after-vesicle-subtraction-mic-', sTestMicText, strcat('.pdf')));
    save(strcat(stVesicleModel.stParameters.sSaveToDir, stVesicleModel.sName, '-after-vesicle-subtraction-mic-', sTestMicText, strcat('.mat')), 'mMicrographVesiclesSubtracted');

end

function saveAsKeepSize(h, destFile)

    set(h, 'PaperPositionMode','auto');
    try
        print(h, '-dpdf', sprintf('-r%d',150), destFile);
    catch err
        % handles random errors from ghostscript
        print(h, '-dpng', sprintf('-r%d',150), strcat(destFile,'.png'));
    end
end