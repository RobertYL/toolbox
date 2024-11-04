function export_table(T,file_name,options)
% EXPORT_TABLE  Export table to LaTeX
%
%   ARGUMENTS:
%
%     T           - table
%     file_name   - export file name. include ".txt" extension
%   
%   OPTIONS:
%
%     'HeadLabels'    - array of strings for header row. by default uses
%                       the variables names in T
%
%     'HeadMathMode'  - array of logicals if header cell is in math mode
%                       default : false
%
%     'HeadUnits'     - array of strings for appending units to header row.
%                       skipped for empty string
%                       default : ""
%
%     'ColFormat'     - array of formats for each column. must be valid
%                       format specification (a la sprintf)
%                       default : "%.4e"
%
%     'ColAlign'      - array of alignment formats for each column. must be
%                       valid tabular alignment (in LaTeX). automatically
%                       detects for siunitx S column
%                       default : "S"
%
%     'Skip'          - boolean array for columns to skip

% TODO: add support for complex numbers
% TODO: possibly add math mode body cells

arguments
  T                    (:,:) table
  file_name            (1,1) string
  options.HeadLabels   (1,:) string  = string(T.Properties.VariableNames);
  options.HeadMathMode (1,:) logical = false(1,size(T,2))
  options.HeadUnits    (1,:) string  = repmat("",1,size(T,2));
  options.ColFormat    (1,:) string  = repmat("%.4e",1,size(T,2));
  options.ColAlign     (1,:) string  = repmat("S",1,size(T,2));
  options.Skip         (1,:) logical = false(1,size(T,2));
end

%% parse input
[n,m] = size(T);

h_labels = options.HeadLabels;
h_mm = options.HeadMathMode;
h_units = options.HeadUnits;
c_fmt = options.ColFormat;
c_align = options.ColAlign;
c_skip = options.Skip;

% check valid input
assert(isequal([1,m],size(h_labels)));
assert(isequal([1,m],size(h_mm)));
assert(isequal([1,m],size(h_units)));
assert(isequal([1,m],size(c_fmt)));
assert(isequal([1,m],size(c_align)));

%% convert all headers into strings
% convert to math mode
i_mm = find(h_mm);
h_labels(i_mm) = strcat("\(",h_labels(i_mm),"\)");

% append units
i_has_units = find(~strcmpi(h_units,""));
h_labels(i_has_units) = strcat(h_labels(i_has_units), ...
                          "~[",h_units(i_has_units),"]");

% wrap all headers with curly braces
h_labels = strcat("{",h_labels,"}");

%% convert all columns into strings

b_content = repmat("",n,m);
for i = 1:n
  for j = 1:m
    if c_skip(j); continue; end
    if isnan(T{i,j})
      b_content(i,j) = "{}";
    else
      b_content(i,j) = sprintf(c_fmt(j),T{i,j});
    end
  end
end

%% generate S column format

for j = 1:m
  if c_skip(j); continue; end
  if ~strcmpi(c_align(j),"S"); continue; end
  
  is_neg = 0;
  l_mntsa_pre = 1;
  l_mntsa_suf = 0;
  is_neg_exp = 0;
  l_exp = 0;

  for i = 1:n
    if isnan(T{i,j}); continue; end
    [a,b,c,d,e] = parse_num(b_content(i,j));
    is_neg      = max(is_neg,a);
    l_mntsa_pre = max(l_mntsa_pre,b);
    l_mntsa_suf = max(l_mntsa_suf,c);
    is_neg_exp  = max(is_neg_exp,d);
    l_exp       = max(l_exp,e);
  end
  
  alg = "";
  if is_neg; alg = strcat(alg,"-"); end
  alg = strcat(alg,int2str(l_mntsa_pre));
  if l_mntsa_suf
    alg = strcat(alg,".",int2str(l_mntsa_suf));
  end
  if l_exp
    alg = strcat(alg,"e");
    if is_neg_exp; alg = strcat(alg,"-"); end
    alg = strcat(alg,int2str(l_exp));
  end
  c_align(j) = strcat("S[table-format=",alg,"]");
end

%% create table and export

fid = fopen(file_name,'w');

fprintf(fid,"\\begin{table}\n");
fprintf(fid,"\t\\centering\n");
fprintf(fid,"\t\\caption{}\n");
fprintf(fid,"\t\\label{tab:}\n");
fprintf(fid,"\t\\begin{tabular}\n");
fprintf(fid,"\t{\n");
for j = 1:m
  if c_skip(j); continue; end
  fprintf(fid,"\t\t%s\n",c_align(j));
end
fprintf(fid,"\t}\n");
fprintf(fid,"\t\t\\toprule\n");
fprintf(fid,"\t\t");
for j = 1:m
  if c_skip(j); continue; end
  fprintf(fid,"%s",h_labels(j));
  if j ~= m; fprintf(fid," & "); end % TODO: fix bug
end
fprintf(fid," \\\\\n");
fprintf(fid,"\t\t\\midrule\n");
for i = 1:n
  fprintf(fid,"\t\t");
  for j = 1:m
    if c_skip(j); continue; end
    fprintf(fid,"%s",b_content(i,j));
    if j ~= m; fprintf(fid," & "); end % TODO: fix bug
  end
  fprintf(fid," \\\\\n");
end
fprintf(fid,"\t\t\\bottomrule\n");
fprintf(fid,"\t\\end{tabular}\n");
fprintf(fid,"\\end{table}\n");

fclose(fid);

end

%% helper functions

function [is_neg,l_mntsa_pre,l_mntsa_suf,is_neg_exp,l_exp] = parse_num(num)
% PARSE_NUM  Parse a number string

expr = "^(-?)0*(\d+)(\.\d*)?(e[-+]\d+)?$";
expr_exp = "^e[-+]0*(\d+)$";
match = regexp(num,expr,'tokens');
assert(~isempty(match));
match_exp = regexp(match{1}(4),expr_exp,'tokens');

is_neg = strcmpi(match{1}(1),"-");
l_mntsa_pre = strlength(match{1}(2));
l_mntsa_suf = max(0,strlength(match{1}(3))-1);
is_neg_exp = contains(match{1}(4),"-");
if ~isempty(match_exp)
  l_exp = strlength(match_exp{1}(1));
else
  l_exp = 0;
end

end