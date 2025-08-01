function format_traj(mu,options)
% PLOT.FORMAT_TRAJ  Format trajectory plot
%   Formatting for plots of planar trajectories
%
%   ARGUMENTS:
%     mu  - scalar
%           mass ratio
%
%   OPTIONS:
%     'LPoints' | 'pt'          - [1,2,3,4,5] (def) | positive integers
%                                 libration point(s) to plot
%     'LColor' | 'LColorDark'   - "#444444" | string
%                                 libration point marker color
%     'Primary' | 'pri'         - [1,2] | positive integers
%                                 primar(y/ies) to plot
%     'PrimaryColors'           - ["#559c33","#999693"] | strings
%                                 primary marker colors
%     'PrimaryNames'            - ["Earth","Moon"] | strings
%                                 name of primaries
%
%     'LabelFlag'               - true (def) | false
%                                 label points and primaries
%     'HandleVisibility' | 'hv' - "on" (def) | "off"
%                                 set handle visibility
%     'XTicks' | 'x'            - vector of increasing values
%     'YTicks' | 'y'              set x/y-axis tick values and limits. by
%                                 default, scales wrt points and primaries
%     'Theme'                   - "Light" (def) | "Dark"
%                                 figure window color theme
%     
%     'Scale'                   - false (def) | true
%                                 plot primaries to scale
%     'PrimaryRadii'            - [0.01634...,0.00445...] | vector
%                                 nondimensional radii of primaries
% 
%   See also Plot.format_traj3
%

arguments
    mu                      (1,1) double  = 0.012150585609624;

    options.LPoints         (1,:) int8    = [1,2,3,4,5];
    options.pt              (1,:) int8
    options.LColor          (1,1) string  = "#444444";
    options.LColorDark      (1,1) string  = "#CCCCCC";

    options.Primary         (1,:) int8    = [1,2];
    options.pri             (1,:) int8
    options.PrimaryColors   (1,2) string  = ["#559c33","#999693"];
    options.PrimaryNames    (1,2) string  = ["Earth","Moon"];

    options.LabelFlag       (1,1) logical = true;
    options.HandleVisibility(1,1) string = "on";
    options.hv              (1,1) string
    options.XTicks          (1,:) double
    options.x               (1,:) double
    options.YTicks          (1,:) double
    options.y               (1,:) double

    options.Scale           (1,1) logical = false;
    options.PrimaryRadii    (1,2) double = [0.016348347331173, ...
                                            0.004458266936616];

    options.Theme       (1,1) string = "Light";
end

% process name-value option shorthands
if isfield(options,"pt"); options.LPoints = options.pt; end
if isfield(options,"pri"); options.Primary = options.pri; end
if isfield(options,"hv"); options.HandleVisibility = options.hv; end
if isfield(options,"x"); options.XTicks = options.x; end
if isfield(options,"y"); options.YTicks = options.y; end

% parse inputs
if strcmpi(options.Theme,"Light")
  is_dark = false;
elseif strcmpi(options.Theme,"Dark")
  is_dark = true;
else
  error("Invalid figure theme selected")
end

pt = options.LPoints;
if ~is_dark
  L_clr = options.LColor;
  mkr_edge = 'w';
else
  L_clr = options.LColorDark;
  mkr_edge = 'k';
end
pri = options.Primary;
pri_clrs = options.PrimaryColors;
pri_names = options.PrimaryNames;
if ~any(pri == 1) && ~any(pt == [3;4;5],"all")
  if ~any(pt == 2)
    x_ticks = (0.7:0.1:1.1);
    y_ticks = (-0.2:0.1:0.2);
  elseif ~any(pt == 1)
    x_ticks = (0.9:0.1:1.3);
    y_ticks = (-0.2:0.1:0.2);
  else
    x_ticks = (0.7:0.1:1.3);
    y_ticks = (-0.3:0.1:0.3);
  end
else
  x_ticks = (-1.6:0.4:1.6);
  y_ticks = (-1.6:0.4:1.6);
end
if isfield(options,"XTicks"); x_ticks = options.XTicks; end
if isfield(options,"YTicks"); y_ticks = options.YTicks; end
handle_vis = options.HandleVisibility;
scale = options.Scale;
pri_radii = options.PrimaryRadii;

held = ishold;
if ~held; hold("on"); end

% add primaries
if scale
  th = linspace(0,2*pi,201);
  for i = 1:2
    patch(-mu+i-1+pri_radii(i)*sin(th(2:end)),pri_radii(i)*cos(th(2:end)), ...
        hex2rgb(pri_clrs(i)),EdgeColor=mkr_edge,LineWidth=1.25, ...
        DisplayName=pri_names(i),HandleVisibility=handle_vis);
  end
else
  if any(pri == 1)
    scatter(-mu,0,72,'ko', ...
      MarkerFaceColor=pri_clrs(1),MarkerEdgeColor=mkr_edge,LineWidth=1.25, ...
      DisplayName=pri_names(1),HandleVisibility=handle_vis);
  end
  if any(pri == 2)
    scatter(1-mu,0,36,'ko', ...
      MarkerFaceColor=pri_clrs(2),MarkerEdgeColor=mkr_edge,LineWidth=1.25, ...
      DisplayName=pri_names(2),HandleVisibility=handle_vis);
  end
end

% add libration points
if ~isempty(pt)
  if isscalar(pt)
    display_name = sprintf("$L_%i$",pt);
  else
    display_name = "L points";
  end
  pt = gen_L_pts(mu,Points=pt);
  scatter(pt(1,:),pt(2,:),108,'x', ...
    MarkerEdgeColor=L_clr,LineWidth=1.5,DisplayName=display_name, ...
    HandleVisibility=handle_vis);
end

axis("equal"); grid("on");
set(gca,Layer="bottom"); % TODO: make this a setting

% update axis labels
if options.LabelFlag
  xlabel("$x$ [LU]");
  ylabel("$y$ [LU]");
end

% update ticks
xlim([min(x_ticks),max(x_ticks)]);
xticks(x_ticks);
ylim([min(y_ticks),max(y_ticks)]);
yticks(y_ticks);

if ~held; hold("off"); end
end