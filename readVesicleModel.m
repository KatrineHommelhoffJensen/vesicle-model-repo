function [stVesicleModel] = readVesicleModel(destDir, modelName)
 
   stVesicleModel = load(strcat(destDir, modelName, '.mat'));   
   
end