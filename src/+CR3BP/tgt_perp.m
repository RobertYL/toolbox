function [success,r0,v0,T,varargout] = tgt_perp(mu,r0,v0,options)
% CR3BP.TGT_PERP  Target perpendicular crossing for given initial guess
%   Target perpendicular crossing of x-z plane for the initial guess R0 and
%   V0 in CR3BP with mass ratio MU.
%
%   ARGUMENTS:
%     mu  - mass ratio
%     r0  - initial position. MUST be on x-z plane
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
%                     options : "x0" | "z0" | "ydot0"
%
%     'AbsTol'      - absolute tolerance of final x-z velocity for
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
%                     default : odeset(RelTol=1e-13,AbsTol=1e-16)
%
%     'Debug'       - output all iterations for debugging
%                     options : "none" | "iter" | "all"
%

arguments
  mu (1,1) double
  r0 (3,1) double
  v0 (3,1) double
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
assert(r0(2) == 0);
assert(norm(v0([1,3])) == 0);

% check if planar
if r0(3) == 0
  if strcmpi(options.Mode,"z0"); options.Mode = "x0"; end
  opt_cell = namedargs2cell(options);
  if strcmpi(options.Debug,"none")
    [success,r0,v0,T] = PCR3BP.tgt_perp(mu,r0(1:2),v0(1:2), ...
      opt_cell{:});
  else
    [success,r0,v0,T,varargout] = PCR3BP.tgt_perp(mu,r0(1:2),v0(1:2), ...
      opt_cell{:});
  end
  r0 = [r0;0];
  v0 = [v0;0];
  return;
end

% unpack arguments
if strcmpi(options.Mode,"x0")
  i_free = [3,5];
elseif strcmpi(options.Mode,"z0")
  i_free = [1,5];
elseif strcmpi(options.Mode,"ydot0")
  i_free = [1,3];
else
  error("Invalid mode selected");
end
tol = options.AbsTol;
it_max = options.IterMax;
T0 = options.T0;
T_sc = options.TScale;
ode_opt = options.IntOptions;
ode_opt.Events = @event_xzcross;
if strcmpi(options.Integrator,"45")
  ode_int = @(r0,v0,T) CR3BP.ode45(mu,[0,T],r0,v0, ...
    options=ode_opt,STM=true);
elseif strcmpi(options.Integrator,"89")
  ode_int = @(r0,v0,T) CR3BP.ode89(mu,[0,T],r0,v0, ...
    options=ode_opt,STM=true);
else
  error("Invalid integrator option selected");
end
if strcmpi(options.Debug,"none")
  debug = 0;
elseif strcmpi(options.Debug,"iter")
  debug = 1;
elseif strcmpi(options.Debug,"all")
  debug = 2;
else
  error("Invalud debug option selected");
end

% initialize
success = false;
if debug; out = struct(); end

% check if initial guess is valid
[t,r,v,phi,te,~,~,~] = ode_int(r0,v0,T0);
if isempty(te)
  error("Does not return to x-z plane in time");
end
% save debug
if debug >= 2; out.traj = struct(t=t,r=r,v=v,phi=phi); end

% iterate
ds0 = zeros(6,1);
for it = 1:it_max
  % update correction
  sdot = CR3BP.ode([r(:,end);v(:,end)],mu);
  Ds0 = (phi([4,6],i_free)-phi(2,i_free).*sdot([4,6])/sdot(2)) ...
    \ (-sdot([1,3]));
  ds0(i_free) = ds0(i_free) + Ds0; % Ds0 doesn't store full state!!!
  
  % simulate new guess
  [t,r,v,phi,te,~,~,~] = ode_int(r0+ds0(1:3),v0+ds0(4:6),t(end)*T_sc);

  % save debug
  if debug >= 2; out.traj(it+1) = struct(t=t,r=r,v=v,phi=phi); end

  % check for crossing
  if isempty(te)
    break;
  end

  if norm(v([1,3],end)) < tol
    success = true;
    break
  end
end

% return solution
r0 = r0+ds0(1:3);
v0 = v0+ds0(4:6);
T = t(end)*2;

% package debug
if debug; out.iter = it; varargout{1} = out; end

end

function [v,isterm,dir] = event_xzcross(~,s)
% EVENT_XZCROSS  Event function for x-z plane crossing in CR3BP
%   Terminating event function

v = s(2);
isterm = 1;
dir = 0;
end

