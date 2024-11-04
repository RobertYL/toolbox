function format_traj(mu,options)
% PLOT.FORMAT_TRAJ  Format trajectory plot

arguments
    mu                      (1,1) double  = 0.012150585350562;

    options.LPoints         (1,:) int8    = [1,2,3,4,5];
    options.LColor          (1,1) string  = "#509920";

    options.PrimaryColors   (1,2) string  = ["#559c33","#999693"];
    options.PrimaryNames    (1,2) string  = ["Earth","Moon"];
    options.PrimaryFlag     (1,:) int8    = [1,2];

    options.LabelFlag       (1,1) logical = true;
    options.XTicks          (1,:) double  = (-1.6:0.4:1.6);
    options.YTicks          (1,:) double  = (-1.6:0.4:1.6);
end

held = ishold;
if ~held; hold("on"); end

% add primaries
if any(options.PrimaryFlag == 1)
  scatter(-mu,0,72,'ko',MarkerFaceColor=options.PrimaryColors(1), ...
    DisplayName=options.PrimaryNames(1));
end
if any(options.PrimaryFlag == 2)
  scatter(1-mu,0,36,'ko',MarkerFaceColor=options.PrimaryColors(2), ...
    DisplayName=options.PrimaryNames(2));
end

% add libration points
if ~isempty(options.LPoints)
  if isscalar(options.LPoints)
    display_name = sprintf("$L_%i$",options.LPoints);
  else
    display_name = "L points";
  end
  L_pts = gen_L_pts(mu,Points=options.LPoints);
  scatter(L_pts(1,:),L_pts(2,:),144,'x', ...
    MarkerEdgeColor=options.LColor,LineWidth=1.5,DisplayName=display_name);
end

axis("equal"); grid("on");

% update axis labels
if options.LabelFlag
  xlabel("$x$ [$l^\ast$]");
  ylabel("$y$ [$l^\ast$]");
end

% update ticks
if ~isempty(options.XTicks)
  xlim([min(options.XTicks),max(options.XTicks)]);
  xticks(options.XTicks);
end
if ~isempty(options.YTicks)
  ylim([min(options.YTicks),max(options.YTicks)]);
  yticks(options.YTicks);
end

if ~held; hold("off"); end
end