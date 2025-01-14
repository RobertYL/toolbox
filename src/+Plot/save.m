function save(fig,filename,options)
% PLOT.SAVE  Save figure to a file
%   Wrapper for EXPORTGRAPHICS
%
%   ARGUMENTS:
%     fig       - figure | axes | ...
%                 graphics object
%     filename  - string
%                 file name
%
%   OPTIONS:
%     'Resolution'  - 300 (def) | positive integer
%                     resolution (DPI)
%
%   See also EXPORTGRAPHICS
%

arguments
  fig                 (1,1) {ishghandle}
  filename            (1,1) string
  options.Resolution  (1,1) double = 300;
end

exportgraphics(fig,filename, ...
  Resolution=options.Resolution, ...
  BackgroundColor=get(fig,"defaultAxesColor"));

end

