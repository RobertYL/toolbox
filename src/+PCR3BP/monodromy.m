function [M] = monodromy(mu,T,r0,v0,options)
% PCR3BP.MONODROMY  Compute monodromy matrix for a periodic orbit
%   Compute a monodromy matrix for different types of periodic orbits
%
%   ARGUMENTS:
%     mu  - mass ratio
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
%                     options : "45" | "89"
%
%     'IntOptions'  - integrator options. event function will be overridden
%                     default : odeset(AbsTol=1e-9,RelTol=1e-12)
%

arguments
  mu (1,1) double
  T  (1,1) double
  r0 (2,1) double
  v0 (2,1) double
  options.Method     (1,1) string = "direct";
  options.Integrator (1,1) string = "45";
  options.IntOptions (1,1) struct = odeset(RelTol=1e-9,AbsTol=1e-12);
end

% unpack arguments
method = options.Method;
ode_opt = options.IntOptions;
if strcmpi(options.Integrator,"45")
  ode_int = @(r0,v0,T) PCR3BP.ode45(mu,[0,T],r0,v0, ...
    options=ode_opt,STM=true);
elseif strcmpi(options.Integrator,"89")
  ode_int = @(r0,v0,T) PCR3BP.ode89(mu,[0,T],r0,v0, ...
    options=ode_opt,STM=true);
else
  warning("Invalid integrator option selected");
end

if strcmpi(method,"direct")
  [~,~,~,M] = ode_int(r0,v0,T);
elseif strcmpi(method,"half")
  G = [1, 0, 0, 0;
       0,-1, 0, 0;
       0, 0,-1, 0;
       0, 0, 0, 1];
  Omega = [0,1;
          -1,0];
  [~,~,~,phi] = ode_int(r0,v0,T/2);

  M = G*[zeros(2),-eye(2);eye(2),-2*Omega]*(phi.') ...
       *[-2*Omega,eye(2);-eye(2),zeros(2)]*G*phi;
else
  warning("Invalid construction method selected");
end

end

