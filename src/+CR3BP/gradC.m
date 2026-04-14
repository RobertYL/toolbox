function [gradC] = gradC(mu,r,v)
% CR3BP.GRADC  Gradient of Jacobi constant for spatial CR3BP
%   Returns COLUMN vector
%
%   dC = 2*[(1-mu)*r_1/r_1^3 + mu*r_2/r_2^3 + (r-r_z) - z]
%
%   ARGUMENTS:
%     mu  - positive scalar
%           mass ratio
%     r   - column vector | matrix
%           position(s)
%     v   - column vector | matrix
%           velocity(s)

arguments
  mu (1,1) double
  r  (3,:) double
  v  (3,:) double
end

r_13 = r+[mu;0;0];
r_23 = r-[1-mu;0;0];
gradU = -(1-mu)*r_13./(vecnorm(r_13).^3)-(mu)*r_23./(vecnorm(r_23).^3);
gradUast = r.*[1;1;0] + gradU;
gradC = 2*[gradUast;-v];

end
