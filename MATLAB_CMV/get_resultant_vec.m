function [M, phase] = get_resultant_vec(magnitude, theta)
% This function converts the magnitudes and angles into a phasor. The
% resultant vector's is then decomposed as magnitude, M, and angle, phase.

zTotal = 0;
threshold = 0.02;
[nRows, nCols, nPages] = size(magnitude);
M = zeros(nPages, 1);
phase = zeros(nPages, 1);

for iPage = 1:(nPages - 1)
    for iRow = 1:nRows
        for iCol = 1:nCols
            R = magnitude(iRow, iCol, iPage);
            rtheta = deg2rad(theta(iRow, iCol, iPage));

            if R > threshold
                z = R * (cos(rtheta) + j * sin(rtheta));                         %convert into complex form
                zTotal = zTotal + z;                                      %add complex numbers
            end
        end
    end

    M(iPage) = abs(zTotal);
    phase(iPage) = angle(zTotal);
end
end