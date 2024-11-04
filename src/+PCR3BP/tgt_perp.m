function [success,r0,v0,T,varargout] = tgt_perp(r0,v0,mu,options)
% PCR3BP.TGT_PERP  Target perpendicular crossing for given initial guess
%   Target perpendicular crossing of x-axis for the initial guess R0 and V0
%   in PCR3BP with mass ratio MU.
%
%   ARGUMENTS:
%     r0  - initial position. MUST be on x-axis
%     v0  - initial velocity. MUST be parallel to y-axis
%     mu  - mass ratio
%
%   RETURNS:
%     success - successfully converged
%     r0      - initial position of solution
%     v0      - initial velocity of solution
%     T       - period of solution
%     out     - (OPTIONAL) struct with iteration information
%       .iter   - number of iterations
%       .traj   - struct array of trajectories for each iteration
%         .t      - time series
%         .r      - position series
%         .v      - velocity series
%
%   OPTIONS:
%
%     'AbsTol'      - absolute tolerance of final x velocity for
%                     convergence
%                     default : 1e-9
%
%     'IterMax'     - maximum number of iterations
%                     default : 15
%
%     'T0'          - initial guess for time of first x-axis crossing
%                     default : 10
%
%     'TScale'      - scaling for next iteration time of crossing guess
%                     default : 2
%
%     'Integrator'  - integrator
%                     options : "45" | "89"
%
%     'IntOptions'  - integrator options. event function will be overridden
%                     default : odeset(AbsTol=1e-9,RelTol=1e-12)
%
%     'Debug'       - output all iterations for debugging
%                     options : "none" | "iter" | "all"
%

arguments
  r0 (2,1) double
  v0 (2,1) double
  mu (1,1) double
  options.AbsTol (1,1) double = 1e-9;
  options.IterMax (1,1) double = 15;
  options.T0 (1,1) double = 10;
  options.TScale (1,1) double = 2;
  options.Integrator (1,1) string = "45"
  options.IntOptions (1,1) struct = odeset(RelTol=1e-9,AbsTol=1e-12);
  options.Debug (1,1) string = "none";
end

% check for valid IC guess
assert(r0(2) < options.AbsTol);
assert(v0(1) < options.AbsTol);

% unpack arguments
tol = options.AbsTol;
it_max = options.IterMax;
T0 = options.T0;
T_sc = options.TScale;
ode_opt = options.IntOptions;
ode_opt.Events = @event_xcross;
if strcmpi(options.Integrator,"45")
  ode_int = @(r0,v0,T) PCR3BP.ode45(mu,[0,T],r0,v0, ...
    options=ode_opt,STM=true);
elseif strcmpi(options.Integrator,"89")
  ode_int = @(r0,v0,T) PCR3BP.ode89(mu,[0,T],r0,v0, ...
    options=ode_opt,STM=true);
else
  warning("Invalid integrator option selected");
end
if strcmpi(options.Debug,"none")
  debug = 0;
elseif strcmpi(options.Debug,"iter")
  debug = 1;
elseif strcmpi(options.Debug,"all")
  debug = 2;
else
  warning("Invalud debug option selected");
end

% initialize
success = false;
if debug; out = struct(); end

% check if initial guess is valid
[t,r,v,phi,te,~,~,~] = ode_int(r0,v0,T0);
if isempty(te)
  return;
end
% save debug
if debug >= 2; out.traj = struct(t=t,r=r,v=v,phi=phi); end

% iterate
dydot0 = 0;
for it = 1:it_max
  % update velocity
  ds = PCR3BP.ode([r(:,end);v(:,end)],mu);
  Dydot0 = -v(1,end)/(phi(3,4)-phi(2,4)*(ds(3)/v(2,end)));
  dydot0 = dydot0 + Dydot0;
  
  % simulate new guess
  [t,r,v,phi,te,~,~,~] = ode_int(r0,v0+[0;dydot0],t(end)*T_sc);

  % save debug
  if debug >= 2; out.traj(it+1) = struct(t=t,r=r,v=v,phi=phi); end

  % check for crossing
  if isempty(te)
    break;
  end

  if abs(v(1,end)) < tol
    success = true;
    break
  end
end

% return solution
v0 = v0 + [0;dydot0];
T = t(end)*2;

% package debug
if debug; out.iter = it; varargout{1} = out; end

end

