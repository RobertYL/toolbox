function [sdot] = ode_STM(s,mu)
% PCR3BP.ODE_STM  First-order differential equation for planar CR3BP STM
%   Reference trajectory and state transition matrix (STM) are propagated
%   simultaneously to maintain accuracy in sensitive regions
%
%   S(1:2)  = position
%   S(3:4)  = velocity
%   S(5:20) = STM

sdot = zeros(20,1);
sdot(1:4) = PCR3BP.ode(s(1:4),mu);

phi = reshape(s(5:20),[4,4]);
Omega = [0,2;
        -2,0];
UXX = PCR3BP.UXX(s(1:2),mu);
A = [zeros(2),eye(2);UXX,Omega];
phidot = A*phi;
sdot(5:20) = reshape(phidot,[16,1]);
end