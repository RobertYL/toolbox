function [color] = get_color(options)
% PLOT.GET_COLOR  Color retrieval for various plotting applications
%   
%   ARGUMENTS: NONE
%
%   OPTIONS:
%     'Mode'        - "Qual" (def) | "Div" | "Seq"
%                     color scheme application
%     'Scheme'      - {"Qual"} : "Bright" (def) | "Vibrant" | "Muted"
%                                | "Manifold"
%                     {"Div"}  : "Sunset" (def) | "Nightfall"
%                     {"Seq"}  : "Rainbow" (def) | "YlOrBr" | "Incandescent"
%                     color scheme. the chosen scheme supercedes the mode
%     'Value' | 'v' - {"Qual"}      : 1 (def) | positive integer | vector
%                     {"Div","Seq"} : 1 (def) | nonnegative value | vector
%                     value of color(s) to return
%     'Range'       - {"Div","Seq"} : [0,1] (def) | [lower upper]
%                     range of values to interpolate. ignored for "Qual" mode
%     'All'         - false (def) | true
%                     return all colors in scheme. overrides specified value(s)
%
%   Sources: https://sronpersonalpages.nl/~pault/#sec:qualitative
%            https://colorbrewer2.org/
%

% TODO: add reversing colormap

arguments
  options.Mode   (1,1) string;
  options.Scheme (1,1) string;
  options.Value  (1,:) double;
  options.v      (1,:) double;
  options.Range  (1,2) double = [0,1];
  options.All    (1,1) logical = false;
end

modes.qual = ["Bright","Vibrant","Muted","Manifold"];
modes.div  = ["Sunset","Nightfall","BuYlRd","GYPi"];
modes.seq  = ["Rainbow","YlOrBr","BrOrYl","Incandescent","BuPu"];

%% parse input

% process name-value option shorthands
if isfield(options,"v"); options.Value = options.v; end

% parse color mode and scheme
if isfield(options,"Scheme")
  scheme = options.Scheme;
  assert(any(strcmpi(scheme,[modes.qual,modes.div,modes.seq])), ...
    "Invalid scheme selected");
  if any(strcmpi(options.Scheme,modes.qual))
    mode = "Qual";
  elseif any(strcmpi(options.Scheme,modes.div))
    mode = "Div";
  else
    mode = "Seq";
  end
else
  if ~isfield(options,"Mode")
    mode = "Qual";
  else
    mode = options.Mode;
    assert(any(strcmpi(mode,["Qual","Div","Seq"])), ...
      "Invalid mode selected");
  end
  scheme = modes.(lower(mode))(1);
end

% parse values (and value range)
if isfield(options,"Value")
  value = options.Value;
else
  value = 1;
end
if strcmpi(mode,"Qual")
  assert(all(mod(value,1) == 0),"Invalid values provided");
else
  range = options.Range;
  assert(min(range) <= min(value) && max(value) <= max(range), ...
    "Values provided out of range");
end

%% return colors

if strcmpi(mode,"Qual")
  if strcmpi(scheme,"Bright")
    n = 6;
    % blue, salmon, yellow, green, cyan, purple
    colors = ["#4477AA","#EE6677","#CCBB44","#228833","#66CCEE","#AA3377"];
    % omitted grey: "#BBBBBB"
  elseif strcmpi(scheme,"Vibrant")
    n = 6;
    colors = ["#EE7733","#0077BB","#33BBEE","#EE3377","#CC3311","#009988"];
    % omitted grey: "#BBBBBB"
  elseif strcmpi(scheme,"Muted")
    n = 9;
    colors = ["#CC6677","#332288","#DDCC77","#117733","#88CCEE", ...
      "#882255","#44AA99","#999933","#AA4499"];
    % bad data: "#DDDDDD"
  elseif strcmpi(scheme,"Manifold")
    n = 4;
    % stable,unstable,center,orbit
    colors = ["#2544F5","#EB3324","#CC1FCC","#509920"];
  end

elseif strcmpi(mode,"Div")
  if strcmpi(scheme,"Sunset")
    n = 11;
    colors = ["#364B9A","#4A7BB7","#6EA6CD","#98CAE1","#C2E4EF", ...
      "#EAECCC","#FEDA8B","#FDB366","#F67E4B","#DD3D2D","#A50026"];
  elseif strcmpi(scheme,"Nightfall")
    n = 17;
    colors = ["#125A56","#00767B","#238F9D","#42A7C6","#60BCE9", ...
      "#9DCCEF","#C6DBED","#DEE6E7","#ECEADA","#F0E6B2","#F9D576", ...
      "#FFB954","#FD9A44","#F57634","#E94C1F","#D11807","#A01813"];
  elseif strcmpi(scheme,"BuYlRd")
    n = 9;
    colors = ["#4575b4","#74add1","#abd9e9","#e0f3f8","#ffffbf", ...
      "#fee090","#fdae61","#f46d43","#d73027"];
  elseif strcmpi(scheme,"GYPi")
    n = 9;
    colors = ["#4d9221","#7fbc41","#b8e186","#e6f5d0","#f7f7f7", ...
      "#fde0ef","#f1b6da","#de77ae","#c51b7d"];
  end
  
elseif strcmpi(mode,"Seq")
  if strcmpi(scheme,"Rainbow")
    n = 11;
    colors = ["#6469E8","#659EEA","#66D3EC","#68EDD2","#69EF9F", ...
      "#6AF16C","#9EF36B","#D5F56C","#F6E16E","#F8AD6F","#FA7970"];
  elseif strcmpi(scheme,"YlOrBr")
    n = 9;
    colors = ["#FFFFE5","#FFF7BC","#FEE391","#FEC44F","#FB9A29", ...
      "#EC7014","#CC4C02","#993404","#662506"];
  elseif strcmpi(scheme,"BrOrYl")
    n = 9;
    colors = ["#662506","#993404","#CC4C02","#EC7014","#FB9A29", ...
      "#FEC44F","#FEE391","#FFF7BC","#FFFFE5"];
  elseif strcmpi(scheme,"Incandescent")
    n = 11;
    colors = ["#CEFFFF","#C6F7D6","#A2F49B","#BBE453","#D5CE04", ...
      "#E7B503","#F19903","#F6790B","#F94902","#E40515","#A80003"];
  elseif strcmpi(scheme,"BuPu")
    n = 9;
    colors = ["#023858","#045a8d","#0570b0","#3690c0","#74a9cf", ...
      "#a6bddb","#d0d1e6","#ece7f2","#fff7fb"];
  end
end

if options.All
  color = colors;
else
  if strcmpi(mode,"Qual")
    color = colors(mod(value-1,n)+1);
  else
    color = rgb2hex(interp1(linspace(range(1),range(2),n), ...
      hex2rgb(colors),value))';
  end
end

end