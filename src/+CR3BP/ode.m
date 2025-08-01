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

sdot = zeros(size(s));
sdot(1:3,:) = s(4:6,:);
sdot(4:6,:) = 2*[s(5,:);-s(4,:);zeros(1,size(s,2))] ...
                + CR3BP.gradUast(s(1:3,:),mu);
end