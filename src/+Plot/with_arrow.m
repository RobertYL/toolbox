function [plotHandle,varargout] = with_arrow(xdata, ydata, varargin)
% PLOT.WITH_ARROW  Plot data with arrows along the curve showing the direction
%   This function is meant to extend the abilities of the PLOT command by
%   adding arrowheads to the curve.
%
%   H = Plot.with_arrow(xdata, ydata) - plot the specified data with the default
%   options. The function returns the handle to the plot
%   
%   H = Plot.with_arrow(xdata, ydata, LineType) - plot the specified data with
%   the specified line type (e.g. 'b*' or '--r'). See PLOT help for more
%   details
%
%   H = Plot.with_arrow(xdata, ydata, LineType, ...) - Allows you to specify
%   additional options for the plot. See the OPTIONS section below for
%   details.
%
%   OPTIONS:
%
%     'Color'             - color string | rgb array | "r" | ...
%                           the color of the data and arrowheads. default
%                           behavior follows colororder
%
%     'LineWidth'         - 1.25 (def) | positive value
%                           a number specifying the width of the plotted
%                           line. see PLOT3 help for more details
%
%     'DisplayName'       - a string for legend
%
%     'HandleVisibility'  - "on" | "off"
%                           visible in legend
%
%     'NumArrows'         - 3 (def) | positive integer
%                           number of arrowheads to place on the data
%
%     'AlignArrows'       - "center" (def) | "start" | "end" | "percent"
%                           alignment of arrows along trajectory
%
%     'FlipDir'           - false (def) | logical
%                           whether or not to flip the direction of the
%                           arrowheads (e.g. if the data is listed in
%                           reverse time)
%
%     'ArrowScale'        - 1 (def) | positive value
%                           scale factor for the arrowheads
%
%     'Time'              - vector
%                           time evolution of data. used for aligning
%                           arrows evenly in time
%
%     'Percent'           - vector
%                           percentage of data to align arrows to. can't be
%                           used with time (TODO: work with time)
%
%     'ArrowBase'         - -0.5 (def) | positive value
%                           distance from base point to bottom of arrow
%
%   See also PLOT
%
%   Author: Andrew Cox
%   Version: January 30, 2014
%   Edited by: Robert Lee (November 27, 2024)
%

%% Set up Parsing
defLineWidth = 1.25;
defDisplayName = '';
defHandleVisibility = 'on';
defNumArr = 3;
defAlignArr = 'center';
defFlipDir = false;
defArrowScale = 1;
defLineType = '-';
defColor = gca().ColorOrder(gca().ColorOrderIndex,:);
defTime = [];
defPct = [];
defArrowBase = -0.5;

p = inputParser;

validColor = @(x) (isnumeric(x) && (length(x) == 3 || length(x) == 4)) || ischar(x) || isstring(x);
notNegNum = @(x) isnumeric(x) && x >= 0;

addRequired(p, 'xdata', @isnumeric);
addRequired(p, 'ydata', @isnumeric);

addOptional(p, 'LineType', defLineType, @(x) ischar(x) || isstring(x));

addParameter(p, 'Color', defColor, validColor);
addParameter(p, 'LineWidth', defLineWidth, notNegNum);
addParameter(p, 'DisplayName', defDisplayName, @(x) ischar(x) || isstring(x));
addParameter(p, 'HandleVisibility', defHandleVisibility, @(x) ischar(x) || isstring(x));
addParameter(p, 'NumArrows', defNumArr, notNegNum);
addParameter(p, 'AlignArrows', defAlignArr, @(x) ischar(x) || isstring(x));
addParameter(p, 'FlipDir', defFlipDir, @islogical);
addParameter(p, 'ArrowScale', defArrowScale, notNegNum);
addParameter(p, 'Time', defTime, @isnumeric);
addParameter(p, 'Percent', defPct, @isnumeric);
addParameter(p, 'ArrowBase', defArrowBase, @isnumeric);

%% Parse
% Check to see if the first optional input could be a LineType
if(~isempty(varargin) > 0 && ((ischar(varargin{1}) && length(varargin{1}) < 5) || (isstring(varargin{1}) && strlength(varargin{1}) < 5)) )
    % It is, proceed normally
    parse(p, xdata, ydata, varargin{:});
else
    % It isn't, throw in the default to avoid errors and parse the optional
    % inputs as param-value pairs
    parse(p, xdata, ydata, defLineType, varargin{:});
end

color = p.Results.Color;
lineType = p.Results.LineType;
lineWidth = p.Results.LineWidth;
displayName = p.Results.DisplayName;
handleVisibility = p.Results.HandleVisibility;
numArrows = p.Results.NumArrows;
alignArrows = p.Results.AlignArrows;
flipDir = p.Results.FlipDir;
scale = p.Results.ArrowScale;
time = p.Results.Time;
pct = p.Results.Percent;
base = p.Results.ArrowBase;

% Error checking
if(length(xdata) ~= length(ydata))
    error('xdata and ydata are different lengths!');
end

if(~isempty(time) && length(xdata) ~= length(time))
    error('Data and time columns do not match');
end

if(strcmpi(alignArrows,"percent") && numel(pct) ~= numArrows)
    error('Number of arrows not equal to percentages provided');
end

if(numArrows > length(xdata))
    error('Number of arrows exceeds number of data points! Cannot create arrows...');
end

% Make the color match a color specified in LineType
% letters = ischarprop(lineType, 'alpha'); %logical array: whether or not each char is a letter
% letters = isletter(lineType);
% if(sum(letters) > 0)
%     color = lineType(letters);
% end
if isstring(color) || ischar(color)
  color = hex2rgb(color);
end
% TODO: fix this to better (skip) capture of "--o" linetypes

%% Compute arrow directions and locations
arrows = zeros(numArrows, 4, 2);
if ~strcmpi(alignArrows,"percent") && isempty(time)
  stepSize = floor(length(xdata)/numArrows);
  if strcmpi(alignArrows,"center")
    stepStart = floor(length(xdata)/(2*numArrows))+1;
  elseif strcmpi(alignArrows,"start")
    stepStart = 1;
  elseif strcmpi(alignArrows,"end")
    stepStart = length(xdata) - (numArrows-1)*stepSize;
  else
    error("Invalid arrow alignment specified");
  end
  ixArr = (0:numArrows-1)*stepSize+stepStart;
elseif ~strcmpi(alignArrows,"percent")
  timeStep = (time(end)-time(1))/numArrows;
  if strcmpi(alignArrows,"center")
    times = linspace(time(1)+timeStep/2,time(end)-timeStep/2,numArrows);
  elseif strcmpi(alignArrows,"start")
    times = linspace(time(1),time(end)-timeStep,numArrows);
  elseif strcmpi(alignArrows,"end")
    times = linspace(time(1)+timeStep,time(end),numArrows);
  else
    error("Invalid arrow alignment specified");
  end
  ixArr = interp1(time,1:length(time),times,"nearest"); 
else
  ixArr = interp1(linspace(0,1,length(xdata)),1:length(xdata),pct,"nearest");
end

% Range of x and y; use to choose size of arrowhead
xExtent = abs(max(xdata) - min(xdata));
yExtent = abs(max(ydata) - min(ydata));
avgExt = mean([xExtent, yExtent]);

% Compute dimensions
l = 0.04*avgExt*scale;      % Length of arrowhead
w = l;                      % Width of arrowhead
s = base*l;                 % Distance from base point to bottom (flat edge) of arrowhead
m = 0.33*l;                 % Indent distance from bottom (flat edge) of arrowhead

for n = 1:numArrows
  ix = ixArr(n);
  if(ix > length(xdata)); break; end
  
  loc = [xdata(ix), ydata(ix)];
  
  if(ix < length(xdata))
    dir = [xdata(ix+1), ydata(ix+1)] - loc;
  else
    dir = loc - [xdata(ix-1), ydata(ix-1)];
  end
  
  % Normalize length of dir and flip it if desired
  dir = 0.1*(-1)^flipDir * dir/norm(dir);
  
  % Angle between x-axis and direction vector
  phi = atan2(dir(2), dir(1));
  
  % Four points of arrow head; use patch() to fill these points later
  arrows(n,:,:) = [loc(1) + (s+l)*cos(phi), loc(2) + (s+l)*sin(phi);...
    loc(1) + (s*cos(phi) + w/2*sin(phi)), loc(2) + (s*sin(phi)-w/2*cos(phi));...
    loc(1) + (s+m)*cos(phi), loc(2) + (s+m)*sin(phi);...
    loc(1) + (s*cos(phi) - w/2*sin(phi)), loc(2) + (s*sin(phi)+w/2*cos(phi))];
end

%% Plotting

% are we holding?
wasHolding = ishold;

if(~ishold)
    hold on;
end

figure(gcf); hold on;
plotHandle = plot(xdata, ydata, lineType, 'Color', color, ...
    'LineWidth', lineWidth, 'HandleVisibility', ...
    handleVisibility, 'DisplayName', displayName);
for n = 1:size(arrows,1)
    patchHandle(n) = patch(arrows(n,:,1), arrows(n,:,2), 'r', ...
        'FaceColor', color(1:3), 'EdgeColor', color(1:3), 'HandleVisibility', 'off');
end

if nargout == 2
  varargout{1} = patchHandle;
end

if(wasHolding)
    hold on;
else
    hold off;
end