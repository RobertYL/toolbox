function [sdot] = ode_STM(s,mu)
% CR3BP.ODE_STM  First-order differential equation for spatial CR3BP STM
%   Reference trajectory and state transition matrix (STM) are propagated
%   simultaneously to maintain accuracy in sensitive regions
%
%   S(1:3)  = position
%   S(4:6)  = velocity
%   S(7:42) = STM

sdot = zeros(42,1);
sdot(1:6) = CR3BP.ode(s(1:6),mu);

phi = reshape(s(7:42),[6,6]);
Omega = [0,2,0;
        -2,0,0;
         0,0,0];
UXX = CR3BP.UXX(s(1:3),mu);
A = [zeros(3),eye(3);UXX,Omega];
phidot = A*phi;
sdot(7:42) = reshape(phidot,[36,1]);
end