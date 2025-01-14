function [cb] = colorbar(options)
% PLOT.COLORBAR  Setup colorbar
%   
%   ARGUMENTS: NONE
%
%   OPTIONS:
%     'Ticks'     - vector
%                   tick values
%     'Label'     - string
%                   color bar label
%     'Reverse'   - false (def) | true
%                   direction of color scale
%     'Center'    - false (def) | true [DOES NOT WORK]
%                   alignment of tick labels. typically true for discrete
%                   color maps
%     'ColorMap'  - hex code | rgb triplet
%                   color map colors. default behavior from figure
%
%   See also COLORBAR
%

% TODO: set colorbar location
% TODO: discrete color maps

arguments
  options.Ticks     (1,:) double
  options.Label     (1,1) string
  options.Reverse   (1,1) logical = false;
  options.Center    (1,1) logical = false;
  options.ColorMap
end

if isfield(options,"ColorMap")
  if isa(options.ColorMap,"string")
    options.ColorMap = hex2rgb(options.ColorMap);
  end
  colormap(options.ColorMap);
end

if ~options.Reverse; dir = "normal"; else; dir = "reverse"; end

cb = colorbar(YDir=dir);

if isfield(options,"Ticks")
  cb.Ticks = options.Ticks;
end
if isfield(options,"Label")
  cb.Label.String = options.Label;
end
cb.Label.Interpreter = "latex";
cb.Label.FontSize = 14;

end

