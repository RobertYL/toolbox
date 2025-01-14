function [plotHandle] = with_arrow3(data, varargin)
% PLOT.WITH_ARROW3  Plot data with arrows along the curve showing the direction
%   This function is meant to extend the abilities of the PLOT3 command by
%   adding arrowheads to the curve.
%
%   H = Plot.with_arrow3(data) - plot the specified data with the default
%   options. The function returns the handle to the plot
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
%     'NumArrows'         - 2 (def) | positive integer
%                           number of arrowheads to place on the data
%
%     'AlignArrows'       - "center" (def) | "start" | "end"
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
%     'BaseColor'         - color string | rgb array | "r" | ...
%                           color on the base of arrowheads. default
%                           behavior scales 'Color' by 0.7
%
%     'NumFaces'          - 16 | positive integer
%                           number of faces per side of the arrow
%
%     'Time'              - vector
%                           time evolution of data. used for aligning
%                           arrows evenly in time
%
%   See also PLOT3
%
%   Author: Robert Lee
%   Version: November 14, 2024
%

%% Set up Parsing
defLineWidth = 1.25;
defDisplayName = '';
defHandleVisibility = 'on';
defNumArr = 2;
defAlignArr = 'center';
defFlipDir = false;
defArrowScale = 1;
defLineType = '-';
defColor = gca().ColorOrder(gca().ColorOrderIndex,:);
defBaseColor = rgb2hsv(defColor);
defBaseColor(3) = 0.7*defBaseColor(3);
defBaseColor = hsv2rgb(defBaseColor);
defNumFaces = 16;
defTime = [];

p = inputParser;

validData = @(x) isnumeric(x) && size(x,1) == 3;
validColor = @(x) (isnumeric(x) && length(x) == 3) || ischar(x) || isstring(x);
notNegNum = @(x) isnumeric(x) && x >= 0;

addRequired(p, 'data', validData);

addOptional(p, 'LineType', defLineType, @(x) ischar(x) || isstring(x));

addParameter(p, 'Color', defColor, validColor);
addParameter(p, 'LineWidth', defLineWidth, notNegNum);
addParameter(p, 'DisplayName', defDisplayName, @(x) ischar(x) || isstring(x));
addParameter(p, 'HandleVisibility', defHandleVisibility, @(x) ischar(x) || isstring(x));
addParameter(p, 'NumArrows', defNumArr, notNegNum);
addParameter(p, 'AlignArrows', defAlignArr, @(x) ischar(x) || isstring(x));
addParameter(p, 'FlipDir', defFlipDir, @islogical);
addParameter(p, 'ArrowScale', defArrowScale, notNegNum);
addParameter(p, 'BaseColor', defBaseColor, validColor);
addParameter(p, 'NumFaces', defNumFaces, notNegNum);
addParameter(p, 'Time', defTime, @isnumeric);

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
lineType = p.Results.LineType;
lineWidth = p.Results.LineWidth;
displayName = p.Results.DisplayName;
handleVisibility = p.Results.HandleVisibility;
numArrows = p.Results.NumArrows;
alignArrows = p.Results.AlignArrows;
flipDir = p.Results.FlipDir;
scale = p.Results.ArrowScale;
if any(strcmpi(p.UsingDefaults,'Color'))
  baseColor = p.Results.BaseColor;
else
  if isstring(color) || ischar(color)
    color = hex2rgb(color);
  end
  baseColor = rgb2hsv(color);
  baseColor(3) = 0.7*baseColor(3);
  baseColor = hsv2rgb(baseColor);
end
numFaces = p.Results.NumFaces;
time = p.Results.Time;

% Error checking
if(~isempty(time) && size(data,2) ~= length(time))
    error('Data and time columns do not match');
end

if(numArrows > length(data))
    error(['Number of arrows exceeds number of data points! ' ...
      'Cannot create arrows...']);
end

xdata = data(1,:);
ydata = data(2,:);
zdata = data(3,:);

% Make the color match a color specified in LineType
% letters = ischarprop(lineType, 'alpha'); %logical array: whether or not each char is a letter
letters = isletter(lineType);
if(sum(letters) > 0)
    color = lineType(letters);
end

%% Compute arrow directions and locations
arrows = zeros(numArrows, numFaces+2, 3);
if isempty(time)
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
else
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
end

% Range of x,y,z; use to choose size of arrowhead
xExtent = abs(max(xdata) - min(xdata));
yExtent = abs(max(ydata) - min(ydata));
zExtent = abs(max(zdata) - min(zdata));
avgExt = mean([xExtent, yExtent, zExtent]);

% Compute dimensions
l = 0.04*avgExt*scale;  % Length of arrowhead
w = l;                  % Width of arrowhead
s = -0.5*l;             % Distance from base point to bottom (flat edge) of arrowhead
m = 0.2*l;              % Indent distance from bottom (flat edge) of arrowhead

for n = 1:numArrows
  ix = ixArr(n);
  if(ix > length(xdata)); break; end
  
  loc = [xdata(ix), ydata(ix), zdata(ix)];
  
  if(ix < length(xdata))
    dir = [xdata(ix+1), ydata(ix+1), zdata(ix+1)] - loc;
  else
    dir = loc - [xdata(ix-1), ydata(ix-1), zdata(ix-1)];
  end
  
  % Normalize length of dir and flip it if desired
  dir = (-1)^flipDir * dir/norm(dir);
  
  % Generate perpendicular direction
  % source: https://math.stackexchange.com/a/4112622
  s_xz = sign((sign(dir(1))+0.5)*(sign(dir(3))+0.5));
  s_yz = sign((sign(dir(2))+0.5)*(sign(dir(3))+0.5));
  prp = [s_xz*dir(3), s_yz*dir(3), -s_xz*dir(1) - s_yz*dir(2)];
  prp = (w/2)*prp/norm(prp);

  arrows(n,1,:) = loc + (s+l)*dir;
  arrows(n,2,:) = loc + (s+m)*dir;
  % NumFaces points along base circle; use patch3() to fill these points later
  th = linspace(0,2*pi,numFaces);
  for i = 1:numFaces
    % Axis-angle rotation
    % source: https://en.wikipedia.org/wiki/Rodrigues%27_rotation_formula
    arrows(n,i+2,:) = loc + s*dir ...
      + prp*cos(th(i)) + cross(dir,prp)*sin(th(i)) + dir*dot(dir,prp)*(1-cos(th(i)));
  end
end

%% Plotting

% are we holding?
held = ishold;

if(~ishold); hold on; end

figure(gcf);
plotHandle = plot3(xdata, ydata, zdata, lineType, ...
  'Color', color, ...
  'LineWidth', lineWidth, ...
  'HandleVisibility', handleVisibility, ...
  'DisplayName', displayName);
for n = 1:size(arrows,1)
  % draw bottom
  patch('Vertices', squeeze(arrows(n,:,:)), ...
    'Faces', [2,(1:numFaces)+2,2], ...
    'FaceColor', baseColor, ...
    'LineStyle', 'none', ...
    'HandleVisibility', 'off');
  % draw top
  patch('Vertices', squeeze(arrows(n,:,:)), ...
    'Faces', [1,(1:numFaces)+2,1], ...
    'FaceColor', color, ...
    'EdgeColor', color, ...
    'HandleVisibility', 'off');
end

if(held); hold on; else; hold off; end