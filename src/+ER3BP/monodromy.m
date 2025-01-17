function [M] = monodromy(p,T,r0,v0,options)
% ER3BP.MONODROMY  Compute monodromy matrix for a periodic orbit
%   Compute a monodromy matrix for different types of periodic orbits
%
%   ARGUMENTS:
%     p   - model parameters
%     T   - period of orbit
%     r0  - initial position
%     v0  - initial velocity
%
%   RETURNS:
%     M   - monodromy matrix
%
%   OPTIONS:
%
%     'Method'      - computation method. "half" uses system properties to
%                     compose two half-period STMs
%                     options : "direct" | "half"
%
%     'Integrator'  - integrator
%                     options : "89"
%
%     'IntOptions'  - integrator options. event function will be overridden
%                     default : odeset(AbsTol=1e-13,RelTol=1e-16)
%
%   Source: ???
%
%   Validated numerically

% TODO: add ode45?
% TODO: support time dependent formulation

arguments
  p  (1,1) struct
  T  (1,1) double
  r0 (3,1) double
  v0 (3,1) double
  options.Method     (1,1) string = "direct";
  options.Integrator (1,1) string = "89";
  options.IntOptions (1,1) struct = odeset(RelTol=1e-13,AbsTol=1e-16);
end

% unpack arguments
method = options.Method;
ode_opt = options.IntOptions;
if strcmpi(options.Integrator,"89")
  ode_int = @(r0,v0,T) ER3BP.odef89(p,[0,T],r0,v0, ...
    options=ode_opt,STM=true);
else
  warning("Invalid integrator option selected");
end

if strcmpi(method,"direct")
  [~,~,~,M] = ode_int(r0,v0,T);
elseif strcmpi(method,"half")
  G = [1, 0, 0, 0, 0, 0;
       0,-1, 0, 0, 0, 0;
       0, 0, 1, 0, 0, 0;
       0, 0, 0,-1, 0, 0;
       0, 0, 0, 0, 1, 0;
       0, 0, 0, 0, 0,-1];
  Omega = [0,1,0;
          -1,0,0;
           0,0,0];
  [~,~,~,phi] = ode_int(r0,v0,T/2);
  
  M = G*[zeros(3),-eye(3);eye(3),-2*Omega]*(phi.') ...
       *[-2*Omega,eye(3);-eye(3),zeros(3)]*G*phi;
else
  warning("Invalid construction method selected");
end

end

