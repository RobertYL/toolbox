function [sdot] = ode(s,mu)
% CR3BP.ODE  First-order differential equation for spatial CR3BP
%   S(1:3) = position
%   S(4:6) = velocity

r = s(1:3,:);
v = s(4:6,:);

sdot = zeros(size(s));
sdot(1:3,:) = v;
sdot(4:6,:) = 2*[v(2,:);-v(1,:);zeros(1,size(v,2))] + CR3BP.gradUast(r,mu);
end