function [sdot] = ode(s,mu)
% CR3BP.ODE  First-order differential equation for spatial CR3BP
%   Evaluate time derivative for spatial CR3BP for mass ratio MU and state
%   vector(s) S = [position; velocity]
%
%   ARGUMENTS:
%     s   - column vector | matrix
%           state(s)
%     mu  - positive scalar
%           mass ratio

arguments
  s  (6,:) double
  mu (1,1) double
end

% initialize
sdot = zeros(size(s));
r = s(1:3,:);
v = s(4:6,:);

% compute flow
sdot(1:3,:) = v;
sdot(4,:) = +2*v(2,:) + r(1,:);
sdot(5,:) = -2*v(1,:) + r(2,:);
r_13 = r + [mu;0;0];
r_23 = r - [1-mu;0;0];
sdot(4:6,:) = sdot(4:6,:) ...
              - (1-mu)*r_13./power(vecnorm(r_13),3) ...
              - mu*r_23./power(vecnorm(r_23),3);
end