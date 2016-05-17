
function [stVesicleModel] = saveVesicleModel(stParameters, mImHOSVDmeanTrainSetPOL, mImHOSVDmeanPOL, mImModelWinPOL, mImHOSVDmeanCAR, mComponentsPOL, mComponentsCAR)

    stVesicleModel.stParameters = stParameters;
    stVesicleModel.mImHOSVDmeanTrainSetPOL = mImHOSVDmeanTrainSetPOL;
    stVesicleModel.mImHOSVDmeanPOL = mImHOSVDmeanPOL;
    stVesicleModel.mImModelWinPOL = mImModelWinPOL;
    stVesicleModel.mImHOSVDmeanCAR = mImHOSVDmeanCAR;
    stVesicleModel.mComponentsPOL = mComponentsPOL; 
    stVesicleModel.mComponentsCAR = mComponentsCAR;
            
    stVesicleModel.sName = strcat(stParameters.sModelNamePrefix, '-maxR-', num2str(stParameters.dMaxR), '-iShapeInterpMet-', num2str(stParameters.iVesShapeInterpMethod), '-iShiftMethod-', num2str(stParameters.iShiftMethod), '-iShiftFreq-', num2str(stParameters.iMaxShiftFrequencies), '-iShiftAmpl-', num2str(stParameters.iMaxShiftAmplitude),'-PC-', num2str(stParameters.iPrincComp), '-R', num2str(stParameters.iPrincCompRad), '-A', num2str(stParameters.iPrincCompAng));
    
    if ~strcmp(stParameters.sSaveToDir, '')
        save(strcat(stParameters.sSaveToDir, stVesicleModel.sName, '.mat'), '-struct', 'stVesicleModel');   
    end
end