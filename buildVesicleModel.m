function stVesicleModel = buildVesicleModel(stParameters, mVesicleTrainingSet, mVesicleTrainingSetWin)

% ====================================================================
% Align training vesicles and calculate mean
% ====================================================================

[meanImg, mVesicleTrainingSet2] = calculateMeanPolVesicleImage(stParameters, mVesicleTrainingSet, mVesicleTrainingSetWin);

if ~isempty(mVesicleTrainingSet2)
    mVesicleTrainingSet = mVesicleTrainingSet2;
    clear mVesicleTrainingSet2
else
    mVesicleTrainingSet = mVesicleTrainingSet.*mVesicleTrainingSetWin;
end
% At this point all polar coordinate vesicle images should be windowed!

mVesicleTrainingSet_meanSubtracted = mVesicleTrainingSet - meanImg(:,:,ones(size(mVesicleTrainingSet, 3),1)); 


% ====================================================================
% Build vesicle model
% ====================================================================

% A1, UPhi: Angular variance
A1 = zeros(size(mVesicleTrainingSet_meanSubtracted, 1),size(mVesicleTrainingSet_meanSubtracted, 2)*size(mVesicleTrainingSet_meanSubtracted, 3));
A1(:) = mVesicleTrainingSet_meanSubtracted(:);
cov1 = 1/(size(mVesicleTrainingSet_meanSubtracted, 2)*size(mVesicleTrainingSet_meanSubtracted, 3))*(A1*A1');
% A2, URho: Radial varience
A2 = zeros(size(mVesicleTrainingSet_meanSubtracted,2),size(mVesicleTrainingSet_meanSubtracted,1)*size(mVesicleTrainingSet_meanSubtracted,3));
imgStack2= permute(mVesicleTrainingSet_meanSubtracted,[2 1 3]);
A2(:) = imgStack2(:);
cov2 = 1/(size(mVesicleTrainingSet_meanSubtracted, 1)*size(mVesicleTrainingSet_meanSubtracted, 3))*(A2*A2');

% Select number basis functions to build combined model from
[UPhi,s]=eigs(cov1,stParameters.iPrincCompAng); % Ang
[URho,s]=eigs(cov2,stParameters.iPrincCompRad); % Rad


    basis=zeros(size(meanImg,1),size(meanImg,2),stParameters.iPrincCompAng, stParameters.iPrincCompRad);%iPrincCompAng_hosvd_basis,iPrincCompRad_hosvd_basis);
    
    for i=1:stParameters.iPrincCompAng
        for j=1:stParameters.iPrincCompRad
            imgPhiRho=UPhi(:,i)*URho(:,j)';
            basis(:,:,i,j)=imgPhiRho/norm(imgPhiRho(:));
        end
    end

    
%     %Basis vectors as columns
%     % All combinations af basis vectors (rad, ang)
    C = zeros(stParameters.iPrincCompAng*stParameters.iPrincCompRad, stParameters.iPrincCompAng*stParameters.iPrincCompRad);
    xi = zeros(stParameters.iPrincCompAng*stParameters.iPrincCompRad, size(mVesicleTrainingSet_meanSubtracted, 3));
    
    %Basis vectors as columns
    % All combinations af basis vectors (rad, ang)
    bimg = reshape(basis(:,:,1:stParameters.iPrincCompAng,1:stParameters.iPrincCompRad), size(basis,1)*size(basis,2), stParameters.iPrincCompAng*stParameters.iPrincCompRad);
    
    for idx = 1:size(mVesicleTrainingSet_meanSubtracted, 3)
        v = mVesicleTrainingSet_meanSubtracted(:,:,idx); v=v(:);
        xi(:,idx)=bimg'*v; %innerproduct between the basis vectors and the mean-subtracted image
    end
    meanxi=mean(xi,2); meanxi=meanxi(:,ones(size(mVesicleTrainingSet_meanSubtracted,3),1)); %mean of the coefficient vectors (PCA)
    C=1/size(mVesicleTrainingSet_meanSubtracted,3)*(xi-meanxi)*(xi-meanxi)'; %Covariance matrix of the coefficients

    [V,Lambda]=eig(C);
    [lambda,i]=sort(diag(Lambda),1,'descend');
    V=V(:,i);
    
    newbimg=bimg*V; %The new basis vectors 
    
    % The second PCA is performed in polar coordinates
    meanPhiRho=reshape(bimg*meanxi(:,1),size(imgPhiRho,1),size(imgPhiRho,2)); %The mean vesicle in the polar coordinates
    imgPhiRho2=reshape(newbimg,size(imgPhiRho,1),size(imgPhiRho,2),stParameters.iPrincCompAng, stParameters.iPrincCompRad); %The new basis in the polar coorinates
    
    % 1) mean of first PCA (in polar coordinates)
    % 2) mean of second PCA (in polar coordinates)
    mImHOSVDmeanTrainSetPOL = meanImg;
    %mImHOSVDmeanTrainSetCAR = interpolateVesicleImagePOLtoCAR(mImHOSVDmeanTrainSetPOL, stParameters.dMaxR, stParameters.dMaxRR);
    mImHOSVDmeanPOL = cleanVesicleImage(meanImg + meanPhiRho);    
    mImHOSVDmeanCAR = interpolateVesicleImagePOLtoCAR(mImHOSVDmeanPOL, stParameters.dMaxR, stParameters.dMaxRR);
    
    % Convert components
    % Polar coordinates:
    mComponentsPOL = imgPhiRho2;  
    mComponentsCAR = zeros(size(mImHOSVDmeanCAR, 1), size(mImHOSVDmeanCAR, 2), stParameters.iPrincCompAng, stParameters.iPrincCompRad);
    for idxAng=1:stParameters.iPrincCompAng
        for idxRad=1:stParameters.iPrincCompRad
            % From polar to cartesian:
            mComponentsCAR(:,:,idxAng,idxRad) = cleanVesicleImage(interpolateVesicleImagePOLtoCAR(mComponentsPOL(:,:,idxAng,idxRad), stParameters.dMaxR, stParameters.dMaxRR));
        end
    end
    
    stVesicleModel = saveVesicleModel(stParameters, mImHOSVDmeanTrainSetPOL, mImHOSVDmeanPOL, mVesicleTrainingSetWin(:,:,1), mImHOSVDmeanCAR, mComponentsPOL, mComponentsCAR);
end
