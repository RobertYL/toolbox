function format_traj3(mu,options)
% PLOT.FORMAT_TRAJ3  Format trajectory plot in 3D

arguments
    mu                      (1,1) double  = 0.012150585350562;

    options.LPoints         (1,:) int8    = [1,2,3,4,5];
    options.LColor          (1,1) string  = "#509920";

    options.PrimaryColors   (1,2) string  = ["#559c33","#999693"];
    options.PrimaryNames    (1,2) string  = ["Earth","Moon"];
    options.PrimaryFlag     (1,:) int8    = [1,2];

    options.LabelFlag       (1,1) logical = true;
    options.XTicks          (1,:) double
    options.YTicks          (1,:) double
    options.ZTicks          (1,:) double
end

% parse inputs
L_pts = options.LPoints;
L_clr = options.LColor;
pri_clrs = options.PrimaryColors;
pri_names = options.PrimaryNames;
pri_flag = options.PrimaryFlag;
if ~any(pri_flag == 1) && ~any(L_pts == [3;4;5],"all")
  if ~any(L_pts == 2)
    x_ticks = (0.7:0.1:1.1);
    y_ticks = (-0.2:0.1:0.2);
    z_ticks = (-0.2:0.1:0.2);
  elseif ~any(L_pts == 1)
    x_ticks = (0.9:0.1:1.3);
    y_ticks = (-0.2:0.1:0.2);
    z_ticks = (-0.2:0.1:0.2);
  else
    x_ticks = (0.7:0.1:1.3);
    y_ticks = (-0.3:0.1:0.3);
    z_ticks = (-0.2:0.1:0.2);
  end
else
  x_ticks = (-1.6:0.4:1.6);
  y_ticks = (-1.6:0.4:1.6);
  z_ticks = (-0.8:0.4:0.8);
end
if isfield(options,"XTicks"); x_ticks = options.XTicks; end
if isfield(options,"YTicks"); y_ticks = options.YTicks; end
if isfield(options,"ZTicks"); z_ticks = options.ZTicks; end


held = ishold;
if ~held; hold("on"); end

% add primaries
if any(pri_flag == 1)
  scatter3(-mu,0,0,72,'ko',MarkerFaceColor=pri_clrs(1), ...
    DisplayName=pri_names(1));
end
if any(pri_flag == 2)
  scatter3(1-mu,0,0,36,'ko',MarkerFaceColor=pri_clrs(2), ...
    DisplayName=pri_names(2));
end

% add libration points
if ~isempty(L_pts)
  if isscalar(L_pts)
    disp_name = sprintf("$L_%i$",L_pts);
  else
    disp_name = "L points";
  end
  L_pts = gen_L_pts(mu,Points=L_pts,Planar=false);
  scatter3(L_pts(1,:),L_pts(2,:),L_pts(3,:),108,'x', ...
    MarkerEdgeColor=L_clr,LineWidth=1.5,DisplayName=disp_name);
end

axis("equal"); grid("on"); box("on");

% update axis labels
if options.LabelFlag
  xlabel("$x$ [LU]");
  ylabel("$y$ [LU]");
  zlabel("$z$ [LU]");
end

% update ticks
xlim([min(x_ticks),max(x_ticks)]);
xticks(x_ticks);
ylim([min(y_ticks),max(y_ticks)]);
yticks(y_ticks);
zlim([min(z_ticks),max(z_ticks)]);
zticks(z_ticks);

if ~held; hold("off"); end
end