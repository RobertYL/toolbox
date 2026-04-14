function [UXX] = UXX(r,mu)
% CR3BP.UXX  Hessian of psuedo-potential for spatial CR3BP
%   Computing U_XX = [U*_xx, U*_xy, U*_xz;
%                     U*_yx, U*_yy, U*_yz;
%                     U*_zx, U*_zy, U*_zz]
%   using the notation defined in page F1 of the AAE 632 notes

arguments
  r  (3,1) double
  mu (1,1) double
end

um = 1-mu;

x = r(1,:);
y = r(2,:);
z = r(3,:);

d = norm(r + [mu;0;0]);
r = norm(r - [um;0;0]);
d3 = d*d*d; d5 = d*d*d*d*d;
r3 = r*r*r; r5 = r*r*r*r*r;

%   U*_xx, U*_xy, ... defined on page E10
Uast_xx = 1 - um/d3 - mu/r3 + 3*(um*(x+mu)^2/d5 + mu*(x-um)^2/r5);
Uast_yy = 1 - um/d3 - mu/r3 + 3*(um/d5          + mu/r5)*y*y;
Uast_zz =   - um/d3 - mu/r3 + 3*(um/d5          + mu/r5)*z*z;
Uast_xy = 3*(um*(x+mu)/d5 + mu*(x-um)/r5)*y;
Uast_xz = 3*(um*(x+mu)/d5 + mu*(x-um)/r5)*z;
Uast_yz = 3*(um/d5        + mu/r5)*y*z;

UXX = [Uast_xx,Uast_xy,Uast_xz;
       Uast_xy,Uast_yy,Uast_yz;
       Uast_xz,Uast_yz,Uast_zz];
end
