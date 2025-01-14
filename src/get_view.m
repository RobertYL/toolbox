%% get_view.m
% print view of current 3D figure

[az,el] = view;
fprintf("view(%i,%i);\n",round(az/5)*5,round(el/5)*5);