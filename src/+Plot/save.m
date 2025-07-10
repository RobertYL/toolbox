function save(fig,filename,options)
% PLOT.SAVE  Save figure to a file
%   Wrapper for EXPORTGRAPHICS and SAVEFIG
%
%   ARGUMENTS:
%     fig       - figure | axes | ...
%                 graphics object
%     filename  - string
%                 file name
%
%   OPTIONS:
%     'Resolution' | 'r'        - 300 (def) | positive integer
%                                 resolution (DPI)
%     'BackgroundColor' | 'bg'  - "#FFFFFF" (def) | "Pres" or "Pres-Spr" | string
%                                 background color
%     'Extensions' | 'e'        - ["png", "fig"] (def) | string array
%                                 file extensions to export to
%
%   See also EXPORTGRAPHICS
%

arguments
  fig                     (1,1) {ishghandle}
  filename                (1,1) string
  options.Resolution      (1,1) double = 300;
  options.r               (1,1) double
  options.BackgroundColor (1,1) string = "#FFFFFF";
  options.bg              (1,1) string
  options.Extensions      (1,:) string = ["png", "fig"];
  options.e               (1,:) string
end

% process name-value option shorthands
if isfield(options,"r"); options.Resolution = options.r; end
if isfield(options,"bg"); options.BackgroundColor = options.bg; end
if isfield(options,"e"); options.Extensions = options.e; end

% process color
if strcmpi(options.BackgroundColor,"Pres")
  options.BackgroundColor = "#FFFBFA";
elseif strcmpi(options.BackgroundColor,"Pres-Spr")
  options.BackgroundColor = "#F8F5F1";
elseif strcmpi(options.BackgroundColor,"Pres-Dark")
  options.BackgroundColor = "#262626";
end

% process filename extension
ext_pat = "^(.*)\.(\w+)$";
ext_eg = ["jpg","jpeg","png","tif","tiff","gif","pdf","emf","eps"];
ext_fg = "fig";
if regexp(filename,ext_pat)
  tok = regexp(filename,ext_pat,"tokens");
  filename = tok{1}(1);
  extensions = tok{1}(2);
else
  extensions=options.Extensions;
end

% check for valid extensions
ext_val = cell2mat(arrayfun(@(ext) strcmpi(ext,[ext_eg,ext_fg]), ...
  extensions.',UniformOutput=false));
if any(all(~ext_val,2)); error("Invalid filename extension provided"); end

% save figure
for extension = extensions
  fullname = filename+"."+extension;
  if strcmpi(extension, ext_fg)
    savefig(fig,fullname);
  else
    exportgraphics(fig,fullname, ...
      Resolution=options.Resolution, ...
      BackgroundColor=options.BackgroundColor);
  end
end

