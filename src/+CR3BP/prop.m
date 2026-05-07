function varargout = prop(varargin)
% CR3BP.PROP  Propagate CR3BP dynamics
%   Propagate CR3BP dynamics for various ODE integrators
%
%   Also supports batch and parallel evaluation. See extended usage.
%
%   USAGE:
%     [t,r,v]        = prop(tspan,r0,v0)
%     [t,s]          = prop(tspan,s0)
%     [...,Phi]      = prop(...,STM=true)
%     [...,te,se,ie] = prop(...,odeopt=odeset(...,Events=...))
%
%   EXTENDED USAGE: (Events are not supported)
%     [rf,vf]   = prop([t0,tf],r0,v0)
%     [sf]      = prop([t0,tf],s0)
%     [s]       = prop(tspan,s0)
%     [...,Phi] = prop(...,STM=true)
%
%   OPTIONS:
%     'mu'          - CR3BP.Cfg.mu (def) | scalar
%                     mass ratio
%     'STM'         - false (def) | true
%                     compute final time STM
%     'Integrator'  - "Boost78" (def) | "ode89" (def w/ event) | "ode45"
%                     integrator
%     'IntOptions'  - Cfg.odeset (def) | struct
%                     integrator options
%     'MEX'         - true (def) | false
%                     use MEX functions
%
%   See also ODE89, CR3BP.ODE89
%

% TODO: add support for MEXed events <04-18-26>
%       related: support for batched events? <05-07-26>
% TODO: add support for straight MATLAB propagation <04-18-26>

%% Parse Input

% Parse main input
assert(numel(varargin{1}) >= 2 ...
        && isrow(varargin{1}) ...
        && isa(varargin{1},"double"), ...
        "CR3BP.prop: Invalid tspan");
tspan = varargin{1};
if(size(varargin{2},1) == 6)
  assert(isa(varargin{2},"double"), ...
          "CR3BP.prop: Invalid s0");
  s0 = varargin{2};
  iargin = 3;
  has_r0v0 = false;
else
  assert(size(varargin{2},1) == 3 && isa(varargin{2},"double") ...
          && size(varargin{3},1) == 3 && isa(varargin{3},"double"), ...
          "CR3BP.prop: Invalid r0 or v0");
  assert(size(varargin{2},2) == size(varargin{3},2), ...
          "CR3BP.prop: r0 and v0 are not the same size");
  s0 = [varargin{2};varargin{3}];
  iargin = 4;
  has_r0v0 = true;
end

% Set default options
opts.mu = CR3BP.Cfg.mu;
opts.STM = false;
opts.Integrator = "Boost78"; % NOTE: unused <04-18-26>
opts.IntOptions = Cfg.odeset;
opts.MEX = true;

% Parse options
while iargin <= nargin
  opts.(varargin{iargin}) = varargin{iargin+1};
  iargin = iargin + 2;
end

%% Propagate

has_mu = opts.mu ~= CR3BP.Cfg.mu;

has_STM = opts.STM;
has_event = ~isempty(opts.IntOptions.Events);

is_batch = size(s0,2) >= 2;
assert(~(is_batch && has_event),"CR3BP.prop: Does not support batched events");

% TODO: only covers some call cases, fix when necessary <04-18-26>
assert(opts.MEX,"CR3BP.prop: Does not support non-MEX");

if opts.STM
  s0 = [s0;repmat(reshape(eye(6),[36,1]),[1,size(s0,2)])];
end

if has_event
  if ~opts.STM; ode = @CR3BP.mex_ode; else; ode = @CR3BP.mex_ode_STM; end
  if has_mu
    [t,s,te,se,ie] = ode89(ode,tspan,s0,opts.IntOptions,opts.mu);
  else
    [t,s,te,se,ie] = ode89(ode,tspan,s0,opts.IntOptions);
  end
  t = t.'; s = s.'; te = te.'; se = se.'; ie = ie.';
  if opts.STM
    se = se(1:6,:);
    Phi = reshape(s(7:42,end),[6,6]);
    s = s(1:6,:);
  end
else
  if has_mu; opts.IntOptions.mu = opts.mu; end
  if ~is_batch
    if ~opts.STM
      [t,s] = CR3BP.mex_boost78(tspan,s0,opts.IntOptions);
    else
      [t,s,Phi] = CR3BP.mex_boost78(tspan,s0,opts.IntOptions);
    end
  else
    if ~opts.STM
      [s] = CR3BP.mex_boost78(tspan,s0,opts.IntOptions);
    else
      [s,Phi] = CR3BP.mex_boost78(tspan,s0,opts.IntOptions);
    end
  end
end

%% Parse Output

if ~is_batch
  varargout{1} = t;
end

if has_r0v0
  if ismatrix(s)
    varargout{1+~is_batch} = s(1:3,:);
    varargout{2+~is_batch} = s(4:6,:);
  else
    varargout{1+~is_batch} = s(1:3,:,:);
    varargout{2+~is_batch} = s(4:6,:,:);
  end
else
  varargout{1+~is_batch} = s;
end

if has_STM
  varargout{2+~is_batch+has_r0v0} = Phi;
end

if has_event
  varargout{3+has_r0v0+has_STM} = te;
  if has_r0v0
    varargout{5+has_STM} = se(1:3,:);
    varargout{6+has_STM} = se(4:6,:);
  else
    varargout{4+has_STM} = se;
  end
  varargout{5+2*has_r0v0+has_STM} = ie;
end

