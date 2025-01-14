function [t,r,v,varargout] = ode89(mu,tspan,r0,v0,options)
% PCR3BP.ODE89  ode89 wrapper for PCR3BP
%   Made to help with unpacking states and various odes
%
%   When STM is specified, only returns FINAL STM
%
%   [t,r,v] = PCR3BP.ode89(mu,tspan,r0,v0)
%
%   [t,r,v,phi] = PCR3BP.ode89(mu,tspan,r0,v0,STM=true)
%
%   If an event function is provided, [te,re,ve,ie] are appended to return

arguments
  mu      (1,1) double
  tspan   (1,:) double
  r0      (2,1) double
  v0      (2,1) double
  options.options   (1,1) struct = odeset(RelTol=1e-13,AbsTol=1e-16);
  options.STM       (1,1) logical = false;
end

has_event = ~isempty(options.options.Events);

if ~options.STM
  if has_event
    [t,s,te,se,ie] = ode89(@(~,s)PCR3BP.ode(s,mu),tspan,[r0;v0],options.options);
  else
    [t,s] = ode89(@(~,s)PCR3BP.ode(s,mu),tspan,[r0;v0],options.options);
  end
else
  if has_event
    [t,s,te,se,ie] = ode89(@(~,s)PCR3BP.ode_STM(s,mu),tspan, ...
      [r0;v0;reshape(eye(4),[16,1])],options.options);
    se = se(:,1:4);
  else
    [t,s] = ode89(@(~,s)PCR3BP.ode_STM(s,mu),tspan, ...
      [r0;v0;reshape(eye(4),[16,1])],options.options);
  end
  varargout{1} = reshape(s(end,5:20),[4,4]);
  s = s(:,1:4);
end

t = t';
s = s';
r = s(1:2,:);
v = s(3:4,:);

if has_event
  varargout{1+options.STM} = te;
  if numel(se) == 0
    varargout{2+options.STM} = [];
    varargout{3+options.STM} = [];
  else
    varargout{2+options.STM} = se(:,1:2)';
    varargout{3+options.STM} = se(:,3:4)';
  end
  varargout{4+options.STM} = ie;
end
end

