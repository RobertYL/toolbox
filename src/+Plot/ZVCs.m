function ZVCs(n_ZVCs,r_ZVCs,options)
% PLOT.ZVCS  Plot zero velocity curves with associated formatting

arguments
    n_ZVCs            (1,1) double
    r_ZVCs            (1,:) cell
    options.C         (1,1) double
    options.ZVCColor  (1,1) string = "#D95319";
end

held = ishold;
if ~held; hold("on"); end

if ~isfield(options,"C")
  label = "ZVC";
else
  label = sprintf("ZVC: $C = %.4f$",options.C);
end

for i = 1:n_ZVCs
    line_ZVC = plot(r_ZVCs{i}(1,:),r_ZVCs{i}(2,:), ...
        Color=options.ZVCColor,DisplayName=label);
    if i ~= 1; set(line_ZVC,HandleVisibility="off"); end
end

axis("equal"); grid("on");

if ~held; hold("off"); end
end