function [sdot] = ode(s,p)
% ER3BP.ODE  First-order diff. equation for the elliptic R3BP (nd. time)
%   S(1:3) = position (rho)
%   S(4:6) = velocity (rhodot)
%   S(7) = true anomaly (f)

rho = s(1:3);
rhodot = s(4:6);
f = s(7);

fdot = sqrt(1+p.e*cos(f));

sdot = zeros(size(s));
sdot(1:3) = rhodot;
sdot(4:6) = -p.e*sin(f)/(2*fdot)*rhodot ...
  + 2*fdot*[rhodot(2);-rhodot(1);0] - [0;0;p.e*cos(f)*rho(3)] ...
  + CR3BP.gradUast(rho,p.mu);
sdot(7) = fdot;
end