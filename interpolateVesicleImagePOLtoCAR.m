
function [mVesImageCAR] = interpolateVesicleImagePOLtoCAR(mVesImagePOL, dMaxR, dMaxRR)
    
    [Xrel,Yrel] = meshgrid(-dMaxRR:1/(dMaxR):dMaxRR,-dMaxRR:1/(dMaxR):dMaxRR);
    mVesImageCAR = zeros(size(Xrel));
    Rrel = sqrt(Xrel.^2+Yrel.^2);
    Arel = atan2(Yrel,Xrel);
    
    % 1) The old way, causing artifacts:
%     [R1,A1] = meshgrid(0:1/(dMaxRfac*dMaxR):dMaxRR,0:1/(dMaxRfac*dMaxR):2*pi);
%     mVesImageCAR(:) = interp2(R1,A1,sqrt(R1).^(-1).*[mVesImagePOL;mVesImagePOL(1,:)],Rrel(:),mod(Arel(:),2*pi),'bicubic');
%     figure; imshow(cleanVesicleImage(mVesImageCAR), []);
    % 2) Fix #1
    [R1,A1] = meshgrid(0:1/(dMaxR):dMaxRR,0:1/(dMaxR):2*pi+1/(dMaxR));
    %mVesImageCAR(:) = interp2(R1,A1,sqrt(R1).^(-1).*[mVesImagePOL(1,:);mVesImagePOL;mVesImagePOL(end,:)],Rrel(:),mod(Arel(:),2*pi),'bicubic');
    
    %TEST better weights
    mVesImageCAR(:) = interp2(R1,A1,1/sqrt(2*pi)*(sqrt(R1).^(-1)).*[mVesImagePOL(1,:);mVesImagePOL;mVesImagePOL(end,:)],Rrel(:),mod(Arel(:),2*pi),'bicubic');
    
    %figure; imshow(cleanVesicleImage(mVesImageCAR), []);
    % 3) Fix #2
%     mVesImageCAR(:) = interp2(R1,A1,sqrt(R1).^(-1).*[mVesImagePOL;mVesImagePOL(1:2,:)],Rrel(:),mod(Arel(:),2*pi),'bicubic');
%     figure; imshow(cleanVesicleImage(mVesImageCAR), []);
    mVesImageCAR(isnan(mVesImageCAR(:))) = 0;
    mVesImageCAR = reshape(mVesImageCAR, size(Xrel,1), size(Xrel,2));
    
end