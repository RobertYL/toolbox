function [gradUast] = gradUast(r,mu,option)
% CR3BP.GRADUAST  Gradient of psuedo-potential for spatial CR3BP
%
%   Use OPTION to specify return type:
%       default     - return gradient
%       'x'|'y'|'z' - return x- or y-component
%       'n'         - return normalized gradient

r_13 = r+[mu;0;0];
r_23 = r-[1-mu;0;0];
gradU = -(1-mu)*r_13./(vecnorm(r_13).^3)-(mu)*r_23./(vecnorm(r_23).^3);
gradUast = r.*[1;1;0] + gradU;

if exist('option','var')
    if option == 'x'
        gradUast = gradUast(1);
    elseif option == 'y'
        gradUast = gradUast(2);
    elseif option == 'z'
        gradUast = gradUast(3);
    elseif option == 'n'
        gradUast = gradUast./vecnorm(gradUast);
    end
end
end