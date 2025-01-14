function [L_pts] = gen_L_pts(mu,options)
% GEN_L_PTS  Generate libration points
%   Find the libration points in the PCR3BP with mass ratio MU
%
%   USAGE:
%     L_pts = gen_L_pts(mu)
%
%   ARGUMENTS:
%     mu        - positive value
%                 mass ratio
%
%   OPTIONS:
%     'Points'  - [1 2 3 4 5] (def) | positive integers
%                 libration point numbers
%     'AbsTol'  - 1e-15 (def) | positive value
%                 NR solver absolute tolerance
%     'Planar'  - false (def) | true
%                 return (2,:) or (3,:) points

arguments
  mu (1,1) double
  options.Points (1,:) int8 = [1,2,3,4,5];
  options.AbsTol (1,1) double = 1e-15;
  options.Planar (1,1) logical = true;
end

% TODO: split this into +PCR3BP and +CR3BP

pts = options.Points;
assert(1 <= min(pts) && max(pts) <= 5);
tol = options.AbsTol;

L_pts = zeros(2,length(pts));

if any(pts == 1)
  f1  = @(ga) (1-mu-ga) - (1-mu)/((1-ga)^2) + mu/(ga^2);
  f1p = @(ga) -1 - 2*(1-mu)/((1-ga)^3) - 2*mu/(ga^3);
  ga1 = NR(f1,f1p,1e-1,tol);
  L_pts(1,pts==1) = 1-mu-ga1;
end

if any(pts == 2)
  f2  = @(ga) (1-mu+ga) - (1-mu)/((1+ga)^2) - mu/(ga^2);
  f2p = @(ga) 1 + 2*(1-mu)/((1+ga)^3) + 2*mu/(ga^3);
  ga2 = NR(f2,f2p,1e-1,tol);
  L_pts(1,pts==2) = 1-mu+ga2;
end

if any(pts == 3)
  f3  = @(ga) (mu+ga) - (1-mu)/(ga^2) - mu/((1+ga)^2);
  f3p = @(ga) 1 + 2*(1-mu)/(ga^3) + 2*mu/((1+ga)^3);
  ga3 = NR(f3,f3p,1,tol);
  L_pts(1,pts==3) = -mu-ga3;
end

if any(pts == 4)
  L_pts(:,pts==4) = [1/2-mu;sqrt(3)/2];
end

if any(pts == 5)
  L_pts(:,pts==5) = [1/2-mu;-sqrt(3)/2];
end

if ~options.Planar
  L_pts(3,:) = 0;
end

end

function [x] = NR(f,fp,x0,tol)
% NR  Newton-Raphson solver
%   Find x such that f(x) = 0, starting at initial guess x0 with update
%   equation x := x - f(x)/fp(x), until |f(x)| < tol

arguments
  f (1,1) function_handle
  fp (1,1) function_handle
  x0 (1,1) double
  tol (1,1) double = 1e-15;
end

x = x0;
while abs(f(x)) > tol
    x = x - f(x)/fp(x);
end
end