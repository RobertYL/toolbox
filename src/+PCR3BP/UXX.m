function [UXX] = UXX(r,mu)
% PCR3BP.UXX  Hessian of psuedo-potential for planar CR3BP
%   Computing U_XX = [U*_xx, U*_xy;
%                     U*_yx, U*_yy]
%   using the notation defined in page F1 of the AAE 632 notes
%
%   If N position vectors r are provided, returns Nx2x2 matrix UXX

x = r(1,:);
y = r(2,:);

d = vecnorm(r+[mu;0]);
r = vecnorm(r-[1-mu;0]);
d3 = d.^3; d5 = d.^5;
r3 = r.^3; r5 = r.^5;

%   U*_xx, U*_xy, ... defined on page E10
Uast_xx = 1 - (1-mu)./d3 - mu./r3 ...
  + (3*(1-mu)*(x+mu).^2)./d5 + (3*mu*(x-1+mu).^2)./r5;
Uast_yy = 1 - (1-mu)./d3 - mu./r3 ...
  + (3*(1-mu)*y.^2)./d5 + (3*mu*y.^2)./r5;
Uast_xy = (3*(1-mu)*(x+mu).*y)./d5 + (3*mu*(x-1+mu).*y)./r5;

UXX = zeros([size(r,2),2,2]);
UXX(:,1,1) = Uast_xx;
UXX(:,2,2) = Uast_yy;
UXX(:,1,2) = Uast_xy;
UXX(:,2,1) = Uast_xy;
UXX = squeeze(UXX);
end