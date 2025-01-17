function [f,r,v,varargout] = odef89(p,fspan,r0,v0,options)
% ER3BP.ODEF89  ode89 wrapper for ER3BP
%   Made to help with unpacking states and various odes
%
%   When STM is specified, only returns FINAL STM
%
%   [f,r,v] = ER3BP.odef89(p,fspan,r0,v0)
%
%   [f,r,v,phi] = ER3BP.odef89(p,fspan,r0,v0,STM=true)
%
%   If an event function is provided, [fe,re,ve,ie] are appended to return

arguments
  p       (1,1) struct
  fspan   (1,:) double
  r0      (3,1) double
  v0      (3,1) double
  options.options   (1,1) struct = odeset(RelTol=1e-13,AbsTol=1e-16);
  options.STM       (1,1) logical = false;
end

has_event = ~isempty(options.options.Events);

if ~options.STM
  if has_event
    [f,s,fe,se,ie] = ode89(@(f,s)ER3BP.odef(f,s,p),fspan,[r0;v0],options.options);
  else
    [f,s] = ode89(@(f,s)ER3BP.odef(f,s,p),fspan,[r0;v0],options.options);
  end
else
  if has_event
    [f,s,fe,se,ie] = ode89(@(f,s)ER3BP.odef_STM(f,s,p),fspan, ...
      [r0;v0;reshape(eye(6),[36,1])],options.options);
    se = se(:,1:6);
  else
    [f,s] = ode89(@(f,s)ER3BP.odef_STM(f,s,p),fspan, ...
      [r0;v0;reshape(eye(6),[36,1])],options.options);
  end
  varargout{1} = reshape(s(end,7:42),[6,6]);
  s = s(:,1:6);
end

f = f';
s = s';
r = s(1:3,:);
v = s(4:6,:);

if has_event
  varargout{1+options.STM} = fe;
  varargout{2+options.STM} = se(:,1:3)';
  varargout{3+options.STM} = se(:,4:6)';
  varargout{4+options.STM} = ie;
end
end

