%% init.m
% initialize plotting params

% dimensions for default plot
plt_pos = [50 200 650 500];

% default plot colors
plt_clr = rgb2hex(lines);

% gradient of colors for plotting targeter iterations
clr_grad = @(n) gen_clr_grad(n);
function clr_grad = gen_clr_grad(n)
  clr_grad_lim = rgb2hsv(hex2rgb(["#6469e8","#fa7970"]));
  clr_grad = rgb2hex(hsv2rgb(interp1([1,2],clr_grad_lim,linspace(1,2,n))));
end

% manifold colors: stable, unstable, center
clr_man = ["#2544F5","#EB3324","#CC1FCC"];