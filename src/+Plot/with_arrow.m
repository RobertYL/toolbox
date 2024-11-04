function [plotHandle] = with_arrow(xdata, ydata, varargin)
% PLOT.WITH_ARROW  Plot data with arrows along the curve showing the direction
%   This function is meant to extend the abilities of the PLOT command by
%   adding arrowheads to the curve.
%
%   H = plotWithArrows(xdata, ydata) - plot the specified data with the default
%   options. The function returns the handle to the plot
%   
%   H = plotWithArrows(xdata, ydata, LineType) - plot the specified data with
%   the specified line type (e.g. 'b*' or '--r'). See PLOT help for more
%   details
%
%   H = plotWithArrows(xdata, ydata, LineType, ...) - Allows you to specify
%   additional options for the plot. See the OPTIONS section below for
%   details.
%
%   OPTIONS:
%
%       'Color'         -   color string | rgb array - The color of the
%                           data and arrowheads. Default is 'b'
%
%       'LineWidth'     -   a number specifying the width of the plotted
%                           line. See PLOT help for more details. Default
%                           is 1.25
%
%       'DisplayName'   -   a string for legend
%
%       'HandleVisibility'  'on' | 'off' - visible in legend
%
%       'NumArrows'     -   The number of arrowheads to place on the data.
%                           Default is 10
%
%       'AlignArrows'   -   'center' | 'start' | 'end' - alignment of
%                           arrows along trajectory.
%                           Default is 'center'
%
%       'FlipDir'       -   False | True - Whether or not to flip the
%                           direction of the arrowheads (e.g. if the data
%                           is listed in reverse time). Default is false
%
%       'ArrowScale'    -   Scale factor for the arrowheads. Default is 1
%
%
%   See also PLOT
%
%   Author: Andrew Cox
%   Version: January 30, 2014
%   Edited by: Robert Lee (October 13, 2024)
%

% TODO: add even time spacing

%% Set up Parsing
defLineWidth = 1.25;
defDisplayName = '';
defHandleVisibility = 'on';
defNumArr = 10;
defAlignArr = 'center';
defFlipDir = false;
defArrowScale = 1;
defLineType = '-';
defColor = gca().ColorOrder(gca().ColorOrderIndex,:);

p = inputParser;

validColor = @(x) (isnumeric(x) && length(x) == 3) || ischar(x) || isstring(x);
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

% Error checking
if(length(xdata) ~= length(ydata))
    error('xdata and ydata are different lengths!');
end

if(numArrows > length(xdata))
    error('Number of arrows exceeds number of data points! Cannot create arrows...');
end

% Make the color match a color specified in LineType
% letters = ischarprop(lineType, 'alpha'); %logical array: whether or not each char is a letter
letters = isletter(lineType);
if(sum(letters) > 0)
    color = lineType(letters);
end

%% Compute arrow directions and locations
arrows = zeros(numArrows, 4, 2);
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

% Range of x and y; use to choose size of arrowhead
xExtent = abs(max(xdata) - min(xdata));
yExtent = abs(max(ydata) - min(ydata));
avgExt = mean([xExtent, yExtent]);

% Compute dimensions
l = 0.04*avgExt*scale;      % Length of arrowhead
w = l;                      % Width of arrowhead
s = -0.5*l;                 % Distance from base point to bottom (flat edge) of arrowhead
m = 0.33*l;                 % Indent distance from bottom (flat edge) of arrowhead

for n = 1:numArrows
  ix = (n-1)*stepSize+stepStart;
  
  
  if(ix > length(xdata))
    break;
  end
  
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
    patch(arrows(n,:,1), arrows(n,:,2), 'r', 'FaceColor', color, ...
        'EdgeColor', color, 'HandleVisibility', 'off');
end

if(wasHolding)
    hold on;
else
    hold off;
end