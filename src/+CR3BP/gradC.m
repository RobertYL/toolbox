function [gradC] = gradC(mu,varargin)
% CR3BP.GRADC  Gradient of Jacobi constant for spatial CR3BP
%   Returns COLUMN vector
%
%   dC = 2*[(1-mu)*r_1/r_1^3 + mu*r_2/r_2^3 + (r-r_z) - z]
%
%   USAGE:
%     dC = CR3BP.gradC(mu,r,v)
%     dC = CR3BP.gradC(mu,s)      where s is size (6,N), s = [r;v]
%
%   ARGUMENTS:
%     mu  - positive scalar
%           mass ratio
%     r   - (3,N) column vector | matrix
%           position(s)
%     v   - (3,N) column vector | matrix
%           velocity(s)
%     s   - (6,N) column vector | matrix
%           state(s)

assert(isscalar(mu) && isnumeric(mu), "mu must be a numeric scalar.");

if nargin == 2
  s = varargin{1};
  assert(isnumeric(s), "s must be numeric");
  assert(size(s,1) == 6, "s must be size (6,N)");
  r = s(1:3,:);
  v = s(4:6,:);
elseif nargin == 3
  r = varargin{1};
  v = varargin{2};
  assert(isnumeric(r) && isnumeric(v), "r and v must be numeric");
  assert(size(r,1) == 3 && size(v,1) == 3 && size(r,2) == size(v,2), ...
      "r and v must be size (3,N)");
else
  assert(0, "CR3BP.gradC: Invalid argument signature");
end

r_13 = r+[mu;0;0];
r_23 = r-[1-mu;0;0];
gradU = -(1-mu)*r_13./(vecnorm(r_13).^3)-(mu)*r_23./(vecnorm(r_23).^3);
gradUast = r.*[1;1;0] + gradU;
gradC = 2*[gradUast;-v];

end
