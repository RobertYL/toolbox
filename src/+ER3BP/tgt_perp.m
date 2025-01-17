function [success,r0,v0,varargout] = tgt_perp(p,r0,v0,options)
% ER3BP.TGT_PERP  Target perpendicular crossing for given initial guess
%   Target perpendicular crossing of x-z plane for the initial guess R0 and
%   V0 in ER3BP with mass ratio P.MU and eccentricity P.E.
%
%   Uses eccentricity continuation.
%
%   ARGUMENTS:
%     p   - model parameters
%     r0  - initial position. MUST be on x-z plane
%     v0  - initial velocity. MUST be parallel to y-axis
%
%   RETURNS:
%     success - successfully converged
%     r0      - initial position of solution
%     v0      - initial velocity of solution
%     out     - (OPTIONAL) struct with iteration information
%       .iter   - number of iterations per e step
%       .traj   - struct array of trajectories for each iteration
%         .f      - true anomaly
%         .r      - position series
%         .v      - velocity series
%
%   OPTIONS:
%
%     'ESteps'      - number of eccentricity continuation steps
%                     default : 5
%
%     'AbsTol'      - absolute tolerance for final x-z velocity and y
%                     position for convergence
%                     default : 1e-10
%
%     'IterMax'     - maximum number of iterations per e step
%                     default : 10
%
%     'M','N'       - target resonance of solution
%                     default : 1,1
%
%     'Integrator'  - integrator
%                     default : "89"
%
%     'IntOptions'  - integrator options. event function will be overridden
%                     default : odeset(RelTol=1e-13,AbsTol=1e-16)
%
%     'Debug'       - output all iterations for debugging
%                     options : "none" | "iter"
%

% TODO: add for nd. time based model (see ER3BP.ode)
% TODO: add switch for f0 = 0/pi
% TODO? add ode45
% TODO: make opt.N/M required?

arguments
  p  (1,1) struct
  r0 (3,1) double
  v0 (3,1) double
  options.ESteps (1,1) double = 5;
  options.AbsTol (1,1) double = 1e-10;
  options.IterMax (1,1) double = 10;
  options.M (1,1) double = 1;
  options.N (1,1) double = 1;
  options.Integrator (1,1) string = "89"
  options.IntOptions (1,1) struct = odeset(RelTol=1e-13,AbsTol=1e-16);
  options.Debug (1,1) string = "none";
end

% check for valid IC guess
assert(r0(2) == 0);
assert(norm(v0([1,3])) == 0);

% unpack arguments
e_steps = options.ESteps;
tol = options.AbsTol;
it_max = options.IterMax;
M = options.M;
N = options.N;
ode_opt = options.IntOptions;
if strcmpi(options.Integrator,"89")
  ode_int = @(e,r0,v0) ER3BP.odef89(struct(mu=p.mu,e=e),[0,pi*N],r0,v0, ...
    options=ode_opt,STM=true);
else
  error("Invalid integrator option selected");
end
if strcmpi(options.Debug,"none")
  debug = 0;
elseif strcmpi(options.Debug,"iter")
  debug = 1;
elseif strcmpi(options.Debug,"all") % TODO: not an option right now
  debug = 2;
else
  error("Invalud debug option selected");
end

% validate for CR3BP
opt_CR3BP = struct(AbsTol=options.AbsTol(1),IterMax=options.IterMax, ...
  T0=2*pi*(N/M),Integrator=options.Integrator, ...
  IntOptions=options.IntOptions);
opt_cell = namedargs2cell(opt_CR3BP);
[success,r0,v0,T] = CR3BP.tgt_perp(p.mu,r0,v0,opt_cell{:});
assert(success);
assert(abs(T-2*pi*(N/M)) < 1e-1); % TODO: hard coded

% initialize
success = false;
if debug
  out = struct(iter=zeros(1,e_steps), ...
    r0=zeros(3,e_steps+1),v0=zeros(3,e_steps+1));
  out.r0(:,1) = r0;
  out.v0(:,1) = v0;
end

% before iteration, set free variables
if r0(3) ~= 0
  i_free = [1,3,5];
  i_tgt = [2,4,6];
else
  i_free = [1,5];
  i_tgt = [2,4];
end

% run first case
[f,r,v,phi] = ode_int(0,r0,v0);

% iterate
e = linspace(p.e/e_steps,p.e,e_steps);
for e_it = 1:e_steps
  ds0 = zeros(6,1);
  it_success = false;

  for it = 1:it_max
    % update correction
    s_f = [r(:,end);v(:,end)];
    Ds0 = phi(i_tgt,i_free) \ (-s_f(i_tgt));
    ds0(i_free) = ds0(i_free) + Ds0; % Ds0 doesn't store full state!!!
    
    % simulate new guess
    [f,r,v,phi] = ode_int(e(e_it),r0+ds0(1:3),v0+ds0(4:6));
  
    % check success
    if norm([r(2,end);v([1,3],end)]) < tol
      it_success = true;
      break;
    end
  end

  if ~it_success
    break;
  elseif e_it == e_steps
    success = true;
  end

  % save solution
  r0 = r0+ds0(1:3);
  v0 = v0+ds0(4:6);

  % save debug
  if debug
    out.iter(e_it) = it;
    out.r0(:,e_it+1) = r0;
    out.v0(:,e_it+1) = v0;
  end
end

% package debug
if debug; varargout{1} = out; end

end
