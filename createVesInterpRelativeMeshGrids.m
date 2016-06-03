%CREATEVESINTERPRELATIVEMESHGRID Function that creates relative mesh grids
%(containing relative positions), in the resolution dictated by 
% * dRadius: number of pixels from 0 to 1
% * dRadiusRelExt: number of pixels after 1, relative to radius
% * dRadiusFac: for even higher resolution (default 1) of relative grids

function [mDim1, mDim2, mDimIdx, mDim1Coord2, mDim2Coord2] = createVesInterpRelativeMeshGrids(sProfileType, dRadius, dRadiusRelExt, iNrOfVesicles)
    
    mDimIdx = [];

    if strcmp(sProfileType, 'CAR')
        
        % Cartesian coordinates
        if nargin > 3
            [mDim1, mDim2, mDimIdx] = meshgrid(-dRadiusRelExt:1/(dRadius):dRadiusRelExt,-dRadiusRelExt:1/(dRadius):dRadiusRelExt,1:iNrOfVesicles);
        else
            [mDim1, mDim2] = meshgrid(-dRadiusRelExt:1/(dRadius):dRadiusRelExt,-dRadiusRelExt:1/(dRadius):dRadiusRelExt);
        end
        mDim1Coord2 = sqrt(mDim1.^2 + mDim2.^2);
        mDim2Coord2 = atan2(mDim2, mDim1);
        
        % Cartesian coordinate image format:
        % mDim1:        Xrel
        % mDim2:        Yrel
        % mDimIdx:      Idx in stack
        % ...with the image positions in (r,a) instead of (x,y):
        % mDim1Coord2:  XrelR 
        % mDim2Coord2:  YrelA
  
        
    elseif strcmp(sProfileType, 'POL')
        
        % Polar coordinates
        if nargin > 3
            [mDim1, mDim2, mDimIdx] = meshgrid(0:1/(dRadius):dRadiusRelExt,0:1/(dRadius):2*pi-1/(dRadius),1:iNrOfVesicles);
        else
            [mDim1, mDim2] = meshgrid(0:1/(dRadius):dRadiusRelExt,0:1/(dRadius):2*pi-1/(dRadius));
        end
        
        % Polar coordinate image format:
        % mDim1:        Rrel 
        % mDim2:        Arel
        % mDimIdx:      Idx in stack
        
    else
        error('Unknown vesicle profile type');
    end
    
end