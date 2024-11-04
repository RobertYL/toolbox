function [sdot] = ode_STM(s,mu)
% R2BP.ODE_STM  First-order differential equation for restricted 2BP STM
%   Reference trajectory and state transition matrix (STM) are propagated
%   simultaneously to maintain accuracy in sensitive regions
%
%   Source: AAE 632 notes, set H, page H4-5
%
%   S(1:3)  = position
%   S(4:6)  = velocity
%   S(7:42) = STM

sdot = zeros(42,1);
sdot(1:6) = R2BP.ode(s(1:6),mu);

phi = reshape(s(7:42),[6,6]);

r = s(1:3);
A21 = mu*(-eye(3)/(norm(r)^3) + 3/(norm(r)^5)*(r*r.'));


A = [zeros(3),eye(3);A21,zeros(3)];
phidot = A*phi;
sdot(7:42) = reshape(phidot,[36,1]);
end