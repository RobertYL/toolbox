function [C] = C(mu,r,v)
% PCR3BP.C  Jacobi constant for planar CR3BP
%
%   C = 2*[(1-mu)/r_1 + mu/r_2] + |r|^2 - |v|^2
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
  r  (2,:) double
  v  (2,:) double
end

C = 2*((1-mu)./vecnorm(r+[mu;0]) + mu./vecnorm(r-[1-mu;0])) ...
    + sum(r.^2,1) - sum(v.^2,1);
end