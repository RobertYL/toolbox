function [v,isterm,dir] = event_xcross(~,s)
% EVENT_XCROSS  Event function for x-axis crossing in PCR3BP
%   Terminating event function
%
%   Works for (P)CR3BP.ode and (P)CR3BP.ode_STM

v = s(2);
isterm = 1;
dir = 0;
end

