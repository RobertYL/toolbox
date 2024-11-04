function [UXX] = UXX(r,mu)
% CR3BP.UXX  Hessian of psuedo-potential for spatial CR3BP
%   Computing U_XX = [U*_xx, U*_xy, U*_xz;
%                     U*_yx, U*_yy, U*_yz;
%                     U*_zx, U*_zy, U*_zz]
%   using the notation defined in page F1 of the AAE 632 notes
%
%   If N position vectors r are provided, returns Nx3x3 matrix UXX

x = r(1,:);
y = r(2,:);
z = r(3,:);

y2 = y.^2;
z2 = z.^2;

d = vecnorm(r+[mu;0;0]);
r = vecnorm(r-[1-mu;0;0]);
d3 = d.^3; d5 = d.^5;
r3 = r.^3; r5 = r.^5;

%   U*_xx, U*_xy, ... defined on page E10
Uast_xx = 1 - (1-mu)./d3 - mu./r3 ...
  + (3*(1-mu)*(x+mu).^2)./d5 + (3*mu*(x-1+mu).^2)./r5;
Uast_yy = 1 - (1-mu)./d3 - mu./r3 ...
  + (3*(1-mu)*y2)./d5 + (3*mu*y2)./r5;
Uast_zz = -(1-mu)./d3 - mu./r3 ...
  + (3*(1-mu)*z2)./d5 + (3*mu*z2)./r5;
Uast_xy = (3*(1-mu)*(x+mu).*y)./d5 + (3*mu*(x-1+mu).*y)./r5;
Uast_xz = (3*(1-mu)*(x+mu).*z)./d5 + (3*mu*(x-1+mu).*z)./r5;
Uast_yz = (3*(1-mu)*y.*z)./d5 + (3*mu*y.*z)./r5;

UXX = zeros([size(r,2),3,3]);
UXX(:,1,1) = Uast_xx;
UXX(:,2,2) = Uast_yy;
UXX(:,3,3) = Uast_zz;
UXX(:,1,2) = Uast_xy;
UXX(:,2,1) = Uast_xy;
UXX(:,1,3) = Uast_xz;
UXX(:,3,1) = Uast_xz;
UXX(:,2,3) = Uast_yz;
UXX(:,3,2) = Uast_yz;
UXX = squeeze(UXX);
end