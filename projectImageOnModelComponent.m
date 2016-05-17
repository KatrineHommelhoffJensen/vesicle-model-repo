
function [mImProj] = projectImageOnModelComponent(mIm, mComp)
    
    b = mComp;
    b(isnan(b(:)))=0; b(isinf(b(:)))=0;
    mImProj = (b(:)'*mIm(:))*b/norm(b(:)).^2;
    mImProj(isnan(mImProj(:)))=0;
            
end