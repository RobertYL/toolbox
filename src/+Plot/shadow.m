function [plotHandles] = shadow(data, varargin)
% PLOT.SHADOW  Plot shadow of 3D curve
%   This function is meant to supplement PLOT.WITH_ARROW3 by adding shadows
%   to the 3D trajectories.
%
%   H = Plot.with_arrow3(data) - plot the specified data with the default
%   options. The function returns the handles to the plots
%   
%   H = Plot.with_arrow3(data, LineSpec) - plot the specified data with
%   the specified line type (e.g. 'b*' or '--r'). See PLOT3 help for more
%   details
%
%   H = Plot.with_arrow3(data, LineSpec, ...) - Allows you to specify
%   additional options for the plot. See the OPTIONS section below for
%   details.
%
%   OPTIONS:
%
%     'Color'             - grey (def) | color string | rgb array | "r" | ...
%                           the color of the data
%
%     'LineWidth'         - 1.25 (def) | positive value
%                           a number specifying the width of the plotted
%                           line. see PLOT3 help for more details
%
%     'Lims'              - auto (def) | 1x3 double
%                           axes limits to shadow onto
%
%     'DisplayName'       - a string for legend
%
%     'HandleVisibility'  - "on" (def) | "off"
%                           visible in legend
%
%   See also PLOT.WITH_ARROW3
%
%   Author: Robert Lee
%   Version: February 17, 2026
%

%% Set up Parsing
defLineWidth = 1.25;
defLims = nan;
defDisplayName = '';
defHandleVisibility = 'on';
defLineType = '-';
defColor = [0.5,0.5,0.5];

p = inputParser;

validData = @(x) isnumeric(x) && size(x,1) == 3;
validColor = @(x) (isnumeric(x) && any(length(x) == [3, 4])) || ischar(x) || isstring(x);
notNegNum = @(x) isnumeric(x) && x >= 0;

addRequired(p, 'data', validData);

addOptional(p, 'LineType', defLineType, @(x) ischar(x) || isstring(x));

addParameter(p, 'Color', defColor, validColor);
addParameter(p, 'LineWidth', defLineWidth, notNegNum);
addParameter(p, 'Lims', defLims, @(x) isnan(x) || (isnumeric(x) && numel(x) == 3));
addParameter(p, 'DisplayName', defDisplayName, @(x) ischar(x) || isstring(x));
addParameter(p, 'HandleVisibility', defHandleVisibility, @(x) ischar(x) || isstring(x));

%% Parse
% Check to see if the first optional input could be a LineType
if(~isempty(varargin) > 0 && ((ischar(varargin{1}) && length(varargin{1}) < 5) || (isstring(varargin{1}) && strlength(varargin{1}) < 5)) )
    % It is, proceed normally
    parse(p, data, varargin{:});
else
    % It isn't, throw in the default to avoid errors and parse the optional
    % inputs as param-value pairs
    parse(p, data, defLineType, varargin{:});
end

color = p.Results.Color;
if isstring(color) || ischar(color)
  color = hex2rgb(color);
end
lineType = p.Results.LineType;
lineWidth = p.Results.LineWidth;
lims = p.Results.Lims;
if isnan(lims)
  lims = nan(1,3);
  [az,el] = view;
  az = mod(mod(az,360)+360,360);
  if az < 180; lims(1) = min(xlim); else; lims(1) = max(xlim); end
  if 90 < az && az < 270; lims(2) = min(ylim); else; lims(2) = max(ylim); end
  if el > 0; lims(3) = min(zlim); else; lims(3) = max(zlim); end
end
displayName = p.Results.DisplayName;
handleVisibility = p.Results.HandleVisibility;

xdata = data(1,:);
ydata = data(2,:);
zdata = data(3,:);
lim = ones(size(xdata));

% Make the color match a color specified in LineType
% letters = ischarprop(lineType, 'alpha'); %logical array: whether or not each char is a letter
letters = isletter(lineType);
if(sum(letters) > 0)
    color = lineType(letters);
end

%% Plotting

% are we holding?
held = ishold;

if(~ishold); hold on; end

figure(gcf);
plotHandles(1) = plot3(xdata, ydata, lim*lims(3), lineType, ...
  'Color', color, ...
  'LineWidth', lineWidth, ...
  'HandleVisibility', handleVisibility, ...
  'DisplayName', displayName);

plotHandles(2) = plot3(xdata, lim*lims(2), zdata, lineType, ...
  'Color', color, ...
  'LineWidth', lineWidth, ...
  'HandleVisibility', handleVisibility, ...
  'DisplayName', displayName);

plotHandles(3) = plot3(lim*lims(1), ydata, zdata, lineType, ...
  'Color', color, ...
  'LineWidth', lineWidth, ...
  'HandleVisibility', handleVisibility, ...
  'DisplayName', displayName);

if(held); hold on; else; hold off; end