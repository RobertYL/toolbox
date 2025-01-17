function [gradU] = gradU(r,mu,option)
% CR3BP.GRADU  Gradient of potential function for spatial CR3BP
%
%   Use OPTION to specify return type:
%       default     - return gradient
%       'x'|'y'|'z' - return x- or y-component
%       'n'         - return normalized gradient

r_13 = r+[mu;0;0];
r_23 = r-[1-mu;0;0];
gradU = -(1-mu)*r_13./(vecnorm(r_13).^3)-(mu)*r_23./(vecnorm(r_23).^3);

if exist('option','var')
    if option == 'x'
        gradU = gradU(1);
    elseif option == 'y'
        gradU = gradU(2);
    elseif option == 'z'
        gradU = gradU(3);
    elseif option == 'n'
        gradU = gradU./vecnorm(gradU);
    end
end
end