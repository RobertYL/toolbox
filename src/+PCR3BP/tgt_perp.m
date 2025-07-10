function [success,r0,v0,T,varargout] = tgt_perp(mu,r0,v0,options)
% PCR3BP.TGT_PERP  Target perpendicular crossing for given initial guess
%   Target perpendicular crossing of x-axis for the initial guess R0 and V0
%   in PCR3BP with mass ratio MU.
%
%   ARGUMENTS:
%     mu  - mass ratio
%     r0  - initial position. MUST be on x-axis
%     v0  - initial velocity. MUST be parallel to y-axis
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
%     'Mode'        - fixed parameter
%                     options : "x0" | "ydot0"
%
%     'AbsTol'      - absolute tolerance of final x velocity for
%                     convergence
%                     default : 1e-10
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
%                     options : "89" | "45"
%
%     'IntOptions'  - integrator options. event function will be overridden
%                     default : odeset(AbsTol=1e-13,RelTol=1e-16)
%
%     'Debug'       - output all iterations for debugging
%                     options : "none" | "iter" | "all"
%

arguments
  mu (1,1) double
  r0 (2,1) double
  v0 (2,1) double
  options.Mode (1,1) string = "x0";
  options.AbsTol (1,1) double = 1e-10;
  options.IterMax (1,1) double = 15;
  options.T0 (1,1) double = 10;
  options.TScale (1,1) double = 2;
  options.Integrator (1,1) string = "89"
  options.IntOptions (1,1) struct = odeset(RelTol=1e-13,AbsTol=1e-16);
  options.Debug (1,1) string = "none";
end

% check for valid IC guess
if r0(2) ~= 0
  warning("Non-zero y0, snapping to 0");
  r0(2) = 0;
end
if v0(1) ~= 0
  warning("Non-zero xdot0, snapping to 0");
  v0(1) = 0;
end

% unpack arguments
if strcmpi(options.Mode,"x0")
  i_free = 4;
elseif strcmpi(options.Mode,"ydot0")
  i_free = 1;
else
  error("Invalid mode selected");
end
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
ds0 = zeros(4,1);
for it = 1:it_max
  % update correction
  sdot = PCR3BP.ode([r(:,end);v(:,end)],mu);
  Ds0 = -sdot(1)/(phi(3,i_free)-phi(2,i_free)*(sdot(3)/sdot(2)));
  ds0(i_free) = ds0(i_free) + Ds0; % Ds0 doesn't store full state!!!
  
  % simulate new guess
  [t,r,v,phi,te,~,~,~] = ode_int(r0+ds0(1:2),v0+ds0(3:4),t(end)*T_sc);

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
r0 = r0+ds0(1:2);
v0 = v0+ds0(3:4);
T = t(end)*2;

% package debug
if debug; out.iter = it; varargout{1} = out; end

end

function [v,isterm,dir] = event_xcross(~,s)
% EVENT_XCROSS  Event function for x-axis crossing in PCR3BP
%   Terminating event function

v = s(2);
isterm = 1;
dir = 0;
end

