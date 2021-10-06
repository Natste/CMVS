function [M, Phase] = getResultantVector(magnitude,theta)
% This function converts the magnitudes and angles into a phasor. The
% resultant vector's is then decomposed as magnitude, M, and angle, Phase.

z_total = 0;
threshold = 0.02;
[~,~,pages] = size(magnitude);
M = zeros(pages,1);
Phase = zeros(pages,1);

for idx = 1:(pages-1)
    for i = 1:3
        for j = 1:3
            R = magnitude(i,j,idx);
            rtheta = deg2rad(theta(i,j,idx));
            
            if R > threshold                       
                z = R*(cos(rtheta)+1i*sin(rtheta));                         %convert into complex form
                z_total = z_total + z;                                      %add complex numbers
            end
        end
    end
    
    M(idx) = abs(z_total);
    Phase(idx) = angle(z_total);
end
end