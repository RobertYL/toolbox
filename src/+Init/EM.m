%% EM.m
% initialize Earth-Moon system parameters

% Gm [km^3/s^2]
%   source: supplementary material
Gm_Earth    = 398600.4415;
Gm_Moon     = 4902.8005821478;

mu = @(m1,m2) m2/(m1+m2);
mu = mu(Gm_Earth,Gm_Moon);

% l* [km]
%   source: supplementary material
l_ast = 384400;
l_nd2km = @(l_nd) l_nd*l_ast;

% t* [s]
t_ast = sqrt(l_ast^3/(Gm_Earth+Gm_Moon));
t_nd2h = @(t_nd) t_nd*t_ast/3600;
t_nd2d = @(t_nd) t_nd*t_ast/86400;
t_nd2y = @(t_nd) t_nd2d(t_nd)/365.25;

% libration points
L_pts = gen_L_pts(mu);

% for plotting
clr_Earth = "#559c33";
clr_Moon = "#999693";