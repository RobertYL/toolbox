function [t,r,v,f,varargout] = ode89(p,tspan,r0,v0,f0,options)
% ER3BP.ODE89  ode89 wrapper for ER3BP
%   Made to help with unpacking states and various odes
%
%   [t,r,v,f] = ER3BP.ode89(p,tspan,r0,v0,f0)
%
%   If an event function is provided, [te,re,ve,fe,ie] are appended to return
%
%   TODO: add STM support

arguments
  p       (1,1) struct
  tspan   (1,:) double
  r0      (3,1) double
  v0      (3,1) double
  f0      (1,1) double
  options.options   (1,1) struct = odeset(RelTol=1e-13,AbsTol=1e-16);
  % options.STM       (1,1) logical = false;
end

has_event = ~isempty(options.options.Events);

if has_event
  [t,s,te,se,ie] = ode89(@(~,s)ER3BP.ode(s,p),tspan,[r0;v0;f0],options.options);
else
  [t,s] = ode89(@(~,s)ER3BP.ode(s,p),tspan,[r0;v0;f0],options.options);
end

t = t';
s = s';
r = s(1:3,:);
v = s(4:6,:);
f = s(7,:);

if has_event
  varargout{1} = te;
  varargout{2} = se(:,1:3)';
  varargout{3} = se(:,4:6)';
  varargout{4} = se(:,7)';
  varargout{5} = ie;
end
end

