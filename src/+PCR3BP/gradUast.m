function [gradUast] = gradUast(r,mu,option)
% PCR3BP.GRADUAST  Gradient of psuedo-potential for planar CR3BP
%
%   Use OPTION to specify return type:
%       default - return gradient
%       'x'|'y' - return x- or y-component
%       'n'     - return normalized gradient

r_13 = r+[mu;0];
r_23 = r-[1-mu;0];
gradU = -(1-mu)*r_13./(vecnorm(r_13).^3)-(mu)*r_23./(vecnorm(r_23).^3);
gradUast = r + gradU;

if exist('option','var')
    if option == 'x'
        gradUast = gradUast(1);
    elseif option == 'y'
        gradUast = gradUast(2);
    elseif option == 'n'
        gradUast = gradUast./vecnorm(gradUast);
    end
end
end