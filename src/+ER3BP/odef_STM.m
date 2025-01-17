function [sdot] = odef_STM(f,s,p)
% ER3BP.ODEF_STM  First-order differential equation for ECR3BP STM
%   Reference trajectory and state transition matrix (STM) are propagated
%   simultaneously to maintain accuracy in sensitive regions
%
%   S(1:3)  = position
%   S(4:6)  = velocity
%   S(7:42) = STM

sdot = zeros(42,1);
sdot(1:6) = ER3BP.odef(f,s(1:6),p);

phi = reshape(s(7:42),[6,6]);
Omega = [0,2,0;
        -2,0,0;
         0,0,0];
UXX = (1/(1+p.e*cos(f)))*(CR3BP.UXX(s(1:3),p.mu) ...
  - [0,0,0;0,0,0;0,0,p.e*cos(f)]);
A = [zeros(3),eye(3);UXX,Omega];
phidot = A*phi;
sdot(7:42) = reshape(phidot,[36,1]);
end