function [stParameters] = getParameters()

    iPaperIdx = 0;
    if iPaperIdx == 0

        % ====================================================================
        % Model for TIP
        % ====================================================================

        stParameters.iPrincCompRad = 6;
        stParameters.iPrincCompAng = 5;
        stParameters.iPrincComp = 27;

        stParameters.dMaxR = 40; %maxRadius expected
        stParameters.dMaxRR = 1.7;%1.65; %size of window compared to radius
        stParameters.dAlpha = 1/12; 
        stParameters.iVesShapeInterpMethod = 1;
        % 1: conventional interpolation
        % 2: wall stays constant in interpolation
        % 3: As (2) but additionally rotationally aligned
        % 4: As (2) but additionally horisontal shifts
        stParameters.dWallThickness = 55;
        stParameters.iShiftIterations = 3;
        stParameters.iMaxShiftFrequencies = 10;
        stParameters.iMaxShiftAmplitude = 7;
        stParameters.iShiftMethod = 1; % regular or fast REMOVE

        if stParameters.iVesShapeInterpMethod < 4
            stParameters.dBeta = 0.72*stParameters.dMaxRR;
            stParameters.dBetaBGWin = 0.8*stParameters.dMaxRR;
        else
            % we need extra space to 'shift out' information
            stParameters.dBeta = 0.75*stParameters.dMaxRR;
            stParameters.dBetaBGWin = 0.8*stParameters.dMaxRR;
        end

        stParameters.sSaveToDir = strcat(pwd, '/out_buildVesicleModelsScript/');
        stParameters.bSaveData = 1;


        % For reading micrographs
        %stParameters.trainingMicrographIdx = [1:10 27 39 40];
        stParameters.vTrainingMicIdxs = [1:6];
        stParameters.iNrOfTrainingMics = length(stParameters.vTrainingMicIdxs);

        stParameters.vNewMicIdxs = [20]; % INSTRUCT
        stParameters.iNrOfNewMics = length(stParameters.vNewMicIdxs);

        % For reading micrograph and data (FredCode) INSTRUCT
        stParameters.ReadTrainMicAndVesDataFunc = @readTrainMicrographAndVesData;
        stParameters.ReadNewMicAndVesDataFunc = @readNewMicrographAndVesData;

        %stParameters.sDataDirTrainingMics = '/Users/khje/Dropbox/PhD shared/Projects/Fred Sigworth/Data/LiposomeImVes130422/';
        stParameters.sDataDirTrainingMics = strcat(pwd, '/Data/TIP/');
        %stParameters.sDataDirNewMics = '/Users/khje/Dropbox/PhD shared/Projects/Fred Sigworth/Data/Hideki/';
        stParameters.sDataDirNewMics = strcat(pwd, '/Data/TIP/');

        stParameters.sModelNamePrefix = '27.04.16';
    
    else
        % ====================================================================
        % Model for JSB
        % ====================================================================

        stParameters.iPrincCompRad = 8;%6;
        stParameters.iPrincCompAng = 3;%5;
        stParameters.iPrincComp = 24;%27;

        stParameters.dMaxR = 60;%40; %maxRadius expected
        stParameters.dMaxRR = 1.7; %size of window compared to radius
        stParameters.dAlpha = 1/12; 
        stParameters.iVesShapeInterpMethod = 4;%1;
        % 1: conventional interpolation
        % 2: wall stays constant in interpolation
        % 3: As (2) but additionally rotationally aligned
        % 4: As (2) but additionally horisontal shifts
        stParameters.dWallThickness = 55;
        stParameters.iShiftIterations = 3;
        stParameters.iMaxShiftFrequencies = 10; %6????
        stParameters.iMaxShiftAmplitude = 7;
        stParameters.iShiftMethod = 1; % regular or fast REMOVE

        if stParameters.iVesShapeInterpMethod < 4
            stParameters.dBeta = 0.72*stParameters.dMaxRR;
            stParameters.dBetaBGWin = 0.8*stParameters.dMaxRR;
        else
            % we need extra space to 'shift out' information
            stParameters.dBeta = 0.75*stParameters.dMaxRR;
            stParameters.dBetaBGWin = 0.8*stParameters.dMaxRR;
        end

        stParameters.sSaveToDir = strcat(pwd, '/out_buildVesicleModelsScript/');
        stParameters.bSaveData = 1;


        % For reading micrographs
        stParameters.trainingMicrographIdx = [1:10 27 39 40];
        stParameters.iNrOfTrainingMics = length(stParameters.vTrainingMicIdxs);

        stParameters.vNewMicIdxs = [8, 11]; % INSTRUCT
        stParameters.iNrOfNewMics = length(stParameters.vNewMicIdxs);

        % For reading micrograph and data (FredCode) INSTRUCT
        stParameters.ReadTrainMicAndVesDataFunc = @readTrainMicrographAndVesData;
        stParameters.ReadNewMicAndVesDataFunc = @readNewMicrographAndVesData;

        stParameters.sDataDirTrainingMics = strcat(pwd, '/Data/JSB/');
        stParameters.sDataDirNewMics = strcat(pwd, '/Data/JSB/');

        stParameters.sModelNamePrefix = '28.04.16';    
    
    end
end