function [sdot] = odef(f,s,p)
% ER3BP.ODEF  First-order diff. equation for the elliptic R3BP (true anom.)
%   S(1:3) = position (rho)
%   S(4:6) = velocity (rhodot)

rho = s(1:3);
rhodot = s(4:6);

sdot = zeros(size(s));
sdot(1:3) = rhodot;
sdot(4:6) = 2*[rhodot(2);-rhodot(1);0] ...
  + (1/(1+p.e*cos(f)))*(CR3BP.gradUast(rho,p.mu) - [0;0;p.e*cos(f)*rho(3)]);
end