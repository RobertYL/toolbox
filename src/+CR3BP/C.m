function [C] = C(mu,varargin)
% CR3BP.C  Jacobi constant for spatial CR3BP
%
%   C = 2*[(1-mu)/r_1 + mu/r_2] + |r|^2 - |v|^2
%
%   USAGE:
%     C = CR3BP.C(mu,r,v)
%     C = CR3BP.C(mu,s)      where s is size (6,N), s = [r;v]
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
  assert(0, "CR3BP.C: Invalid argument signature");
end

C = 2*((1-mu)./vecnorm(r+[mu;0;0]) + mu./vecnorm(r-[1-mu;0;0])) ...
    + sum(r(1:2,:).^2,1) - sum(v.^2,1);
end
