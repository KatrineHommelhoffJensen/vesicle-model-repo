%CREATEVESICLEIMAGESIGNALWINDOW Function that creates a window for a
%vesicle image: Either hard or soft, i.e. Tukey.

function [mWin] = createVesicleImageSignalWindow(sVesicleImSize, dVesicleRadius, ptVesicleCnt, dBeta, dAlpha, bSoftWindow)

    mWin = zeros(sVesicleImSize);
    for i=1:sVesicleImSize(1)
        for j=1:sVesicleImSize(2)
            dist = distPointPoint([i-0.5,j-0.5], ptVesicleCnt);
            if dist <= dBeta*dVesicleRadius
                mWin(i,j) = 1;
            elseif bSoftWindow && dist > dBeta*dVesicleRadius && dist < (dBeta*dVesicleRadius + (1/dAlpha))
                mWin(i,j) = 0.5*(cos(pi*dAlpha*(dist - dBeta*dVesicleRadius))+1);
            end
        end
    end
                
end