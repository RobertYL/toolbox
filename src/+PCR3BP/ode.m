function [sdot] = ode(s,mu)
% PCR3BP.ODE  First-order differential equation for planar CR3BP
%   S(1:2) = position
%   S(3:4) = velocity

r = s(1:2,:);
v = s(3:4,:);

sdot = zeros(size(s));
sdot(1:2,:) = v;
sdot(3:4,:) = 2*[v(2,:);-v(1,:)] + PCR3BP.gradUast(r,mu);
end