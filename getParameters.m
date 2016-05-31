%GETPARAMETERS Function that returns a setup of parameters for the vesicle
%model. Alle parameters are mandatory. Two setups are demonstrated:
%
% (1) Vesicle model in the TIP paper:
% K. H. Jensen, F.J. Sigworth and S. S. Brandt, "Removal of Vesicle
% Structures from Transmission Electron Microscope Images", IEEE
% Transactions on Image Processing, 2015; 25(2):540-552.
%
% (2) Vesicle model in the JSB paper:
% K. H. Jensen, S. S. Brandt, H. Shigematsu and F.J. Sigworth, "Statistical
% modeling and removal of lipid membrane projections for cryo-EM structure 
% determination of reconstituted membrane proteins", Journal of structural
% biology, 2016; 194(1):49-60

function stParameters = getParameters()

    iPaperIdx = 1;
    if iPaperIdx == 1

        % ====================================================================
        % (1) Model for TIP
        % ====================================================================

        % --------------------------------------------------------------------
        % Model parameters
        
        stParameters.iPrincCompRad = 6; % Weighted radial components
        stParameters.iPrincCompAng = 5; % Angular components
        stParameters.iPrincComp = 27; % Second-layer model components
        
        % --------------------------------------------------------------------
        % Vesicle interpolation parameters
        
        stParameters.dMaxR = 40; % Interpolate into vesicle radius size
        stParameters.dMaxRR = 1.7; % Size of vesicle window relative to radius
        stParameters.dAlpha = 1/12; % Steepness of Tukey window slope
        
        stParameters.dBeta = 0.72*stParameters.dMaxRR; % Vesicle window relative Tukey platform radius
        stParameters.dBetaBGWin = 0.8*stParameters.dMaxRR; % Vesicle background window relative Tukey platform radius
        % Relative radius of platform in Tukey window, i.e. beginning of
        % steep transition area (total radius: dBeta + 1/dAlpha), compared
        % to radius.
        
        stParameters.iVesShapeInterpMethod = 1;
        % 1: Shape interpolation as in TIP (scaling)
        % 2: Shape interpolation as in JSB; vesicle wall stays constant in
        % interpolation, rotationally align vesicle to mean
        
        % Following parameters are only for JSB shape interpolation
        stParameters.dWallThickness = 0; % Constant wall width in pixels
        stParameters.iShiftIterations = 0; % Iterations for estimating sinusoid
        stParameters.iMaxShiftFrequencies = 0; % Number of frequencies (coefficients) in the sinusoid estimate  
        stParameters.iMaxShiftAmplitude = 0; % Maximum frequency used
        
        % --------------------------------------------------------------------
        % Training data (for model) and new data (for removal)

        stParameters.vTrainingMicIdxs = [1:6]; % Indexes in folder
        stParameters.iNrOfTrainingMics = length(stParameters.vTrainingMicIdxs);

        stParameters.vNewMicIdxs = [20]; % Indexes in folder
        stParameters.iNrOfNewMics = length(stParameters.vNewMicIdxs);

        % Functionality for reading micrograph and data (to be exchanged by user)   
        stParameters.ReadTrainMicAndVesDataFunc = @readTrainMicrographAndVesData;
        stParameters.ReadNewMicAndVesDataFunc = @readNewMicrographAndVesData;

        % --------------------------------------------------------------------
        % Paths
        
        % Output folder for micrograph after vesicle removal
        stParameters.sSaveToDir = strcat(pwd, '/out_buildVesicleModelsScript/');
        stParameters.bSaveData = 1;
        
        stParameters.sDataDirTrainingMics = strcat(pwd, '/Data/TIP/');
        stParameters.sDataDirNewMics = strcat(pwd, '/Data/TIP/');

        stParameters.sModelNamePrefix = 'TIP2';
        
        % TODO remove!
        stParameters.showFigIdx = [6 7 27 35];
        
    else % iPaperIdx == 2
        % ====================================================================
        % (2) Model for JSB
        % ====================================================================
        
        % Notice: Due to data storage issues, the vesicle model is here
        % trained on a smaller training set than in the JSB paper. The
        % results are, however, very similar.
        
        % --------------------------------------------------------------------
        % Model parameters
        
        stParameters.iPrincCompRad = 8;
        stParameters.iPrincCompAng = 3;
        stParameters.iPrincComp = 24;

        % --------------------------------------------------------------------
        % Vesicle interpolation parameters
        
        stParameters.dMaxR = 60;
        stParameters.dMaxRR = 1.7; 
        stParameters.dAlpha = 1/12; 
        
        stParameters.dBeta = 0.75*stParameters.dMaxRR;
        stParameters.dBetaBGWin = 0.8*stParameters.dMaxRR;
        
        stParameters.iVesShapeInterpMethod = 2;
        
        stParameters.dWallThickness = 55;
        stParameters.iShiftIterations = 3;
        stParameters.iMaxShiftFrequencies = 6;
        stParameters.iMaxShiftAmplitude = 7;
        
        % --------------------------------------------------------------------
        % Training data (for model) and new data (for removal)

        stParameters.vTrainingMicIdxs = [1:6];
        stParameters.iNrOfTrainingMics = length(stParameters.vTrainingMicIdxs);

        stParameters.vNewMicIdxs = [11];
        stParameters.iNrOfNewMics = length(stParameters.vNewMicIdxs);

        stParameters.ReadTrainMicAndVesDataFunc = @readTrainMicrographAndVesData;
        stParameters.ReadNewMicAndVesDataFunc = @readNewMicrographAndVesData;

        % --------------------------------------------------------------------
        % Paths
        
        stParameters.sSaveToDir = strcat(pwd, '/out_buildVesicleModelsScript/');
        stParameters.bSaveData = 1;
        
        stParameters.sDataDirTrainingMics = strcat(pwd, '/Data/JSB/');
        stParameters.sDataDirNewMics = strcat(pwd, '/Data/JSB/');

        stParameters.sModelNamePrefix = 'JSB2';
        
        % TODO remove!
        stParameters.showFigIdx = [2 8];
    
    end
end