function [fig,varargout] = figure(options)
% PLOT.FIGURE  Setup figure
%
%   USAGE:
%     fig = Plot.figure()
%     [fig,tcl] = Plot.figure(Grid=___)
%     [fig,tcl,clr] = Plot.figure(Grid=___,ColorMode=___)
%
%   ARGUMENTS: NONE
%
%   OPTIONS:
%     'Position' | 'p'  - [50 200 650 500] (def) | [left bottom width height]
%                         location and size of drawable area
%     'Units'           - "pixels" (def) | "inches"
%                         unit of measurement
%     'Grid' | 'g'      - [1 1] (def) | [rows columns]
%                         number of rows and columns
%     'Theme'           - "Light" (def) | "Dark"
%                         figure window color theme
%     'ColorMode'       - "Qual" | string
%                         color scheme application. see PLOT.GET_COLOR
%     'ColorScheme'     - "Bright" | string
%                         color scheme for plotting. see PLOT.GET_COLOR
%     'ColorRange'      - [0,1] | vector
%                         range of values to interpolate colors from
%
%   See also FIGURE
%

% TODO: add reversing colormap

arguments
  options.Position                 = [50 200 650 500];
  options.p
  options.Units       (1,1) string = "pixels";
  options.Grid        (1,2) double = [1,1];
  options.g           (1,2) double
  options.Theme       (1,1) string = "Light";
  options.ColorMode   (1,1) string = "Qual";
  options.ColorScheme (1,1) string = "Bright";
  options.ColorRange  (1,2) double = [0,1];
end

% process name-value option shorthands
if isfield(options,"p"); options.Position = options.p; end
if isfield(options,"g"); options.Grid = options.g; end

% parse inputs
if isa(options.Position,"string")
  if strcmpi(options.Position,"Tall")
    options.Position = [50 100 650 750];
  elseif strcmpi(options.Position,"Wide")
    options.Position = [50 200 900 500];
  elseif strcmpi(options.Position,"Big")
    options.Position = [50 100 800 750];
  elseif strcmpi(options.Position,"Small")
    options.Position = [50 300 400 300];
  else
    options.Position = [50 200 650 500];
  end
end
config.Units = options.Units;
config.Position = options.Position;

config.defaultAxesColorOrder = hex2rgb(Plot.get_color( ...
  Mode=options.ColorMode,Scheme=options.ColorScheme,All=true));
if ~strcmpi(options.ColorMode,"Qual")
  config.ColorMap = hex2rgb(Plot.get_color( ...
    Mode=options.ColorMode,Scheme=options.ColorScheme, ...
    Value=linspace(0,1,256)));
  config.defaultAxesCLimMode = "manual";
  config.defaultAxesCLim = options.ColorRange;
end

if strcmpi(options.Theme,"Light")
  colors = ones(4,3).*[1;0.85;0.15;0];
elseif strcmpi(options.Theme,"Dark")
  colors = ones(4,3).*[0;0.15;0.85;1];
  config.defaultAxesGridAlpha = 0.4;
else
  error("Invalid figure theme selected")
end
config.Color = colors(2,:);
config.defaultAxesColor = colors(1,:);
config.defaultAxesXColor = colors(3,:);
config.defaultAxesYColor = colors(3,:);
config.defaultAxesZColor = colors(3,:);
config.defaultAxesGridColor = colors(3,:);
config.defaultColorBarColor = colors(4,:);
config.defaultTextColor = colors(4,:);

fig = figure(config);

i_argout = 1;

if ~isequal(options.Grid,[1,1])
  varargout{i_argout} = tiledlayout(options.Grid(1),options.Grid(2));
  i_argout = i_argout+1;
end

if ~strcmpi(options.ColorMode,"Qual")
  varargout{i_argout} = @(value) Plot.get_color(Mode=options.ColorMode, ...
    Scheme=options.ColorScheme,Range=options.ColorRange,Value=value);
  % i_argout = i_argout+1;
end

end

