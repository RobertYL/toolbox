function [sdot] = ode(s,mu)
% PCR3BP.ODE  First-order differential equation for planar CR3BP
%   Evaluate time derivative for planar CR3BP for mass ratio MU and state
%   vector(s) S = [position; velocity]
%
%   ARGUMENTS:
%     s   - column vector | matrix
%           state(s)
%     mu  - positive scalar
%           mass ratio

arguments
  s  (4,:) double
  mu (1,1) double
end

sdot = zeros(size(s));
sdot(1:2,:) = s(3:4,:);
sdot(3:4,:) = 2*[s(4,:);-s(3,:)] + PCR3BP.gradUast(s(1:2,:),mu);
end