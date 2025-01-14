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
LU = 384400;
LU2km = @(l_nd) l_nd*LU;

% t* [s]
TU = sqrt(LU^3/(Gm_Earth+Gm_Moon));
TU2h = @(t_nd) t_nd*TU/3600;
TU2d = @(t_nd) t_nd*TU/86400;
TU2y = @(t_nd) TU2d(t_nd)/365.25;

% radii [km] -> [LU]
R_Earth = 6371.0/LU;
R_Moon  = 1737.4/LU;

% libration points
L_pts = gen_L_pts(mu);

% for plotting
clr_Earth = "#559c33";
clr_Moon = "#999693";