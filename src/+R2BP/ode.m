function [sdot] = ode(s,mu)
% R2BP.ODE  First-order differential equation for restricted 2BP
%   S(1:3) = position
%   S(4:6) = velocity

r = s(1:3);
v = s(4:6);

sdot = zeros(size(s));
sdot(1:3) = v;
sdot(4:6) = -mu*r/(norm(r)^3);
end