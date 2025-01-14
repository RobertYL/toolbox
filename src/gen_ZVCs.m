function [n_ZVCs,r_ZVCs] = gen_ZVCs(C,mu,ds,options)
% GEN_ZVCS  Generate zero velocity curves at JC
%
%   USAGE:
%     [n_ZVCs,r_ZVCs] = gen_ZVCs(C,mu,ds)
%   
%   ARGUMENTS:
%     C         - positive value
%                 Jacobi constant for ZVC
%     mu        - positive value
%                 mass ratio
%     ds        - positive value
%                 nondimensional step size
%
%   OPTIONS:
%     'Method'  - "NPC" (def) | "PAC"
%                 continuation method: natural parameter, pseudo-arclength
%

arguments
    C (1,1) double
    mu (1,1) double
    ds (1,1) double
    options.Method string = "NPC"
end

% TODO: move this into PCR3BP
% TODO: add Uast to PCR3BP
% TODO: stress test C equal to exactly collinear points

% find Jacobi constants for each libration point
L_pts = gen_L_pts(mu);
C_L = PCR3BP.C(mu,L_pts,zeros(2,5));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Casework and find initial point along each ZVC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AUX stores helper functions for N-R to solve along x and y
aux.x = @(r) r(1);
aux.fx = @(r0) @(x) 2*Uast([x;r0(2)],mu) - C;
aux.fxp = @(r0) @(x) 2*PCR3BP.gradUast([x;r0(2)],mu,'x');

aux.y = @(r) r(2);
aux.fy = @(r0) @(y) 2*Uast([r0(1);y],mu) - C;
aux.fyp = @(r0) @(y) 2*PCR3BP.gradUast([r0(1);y],mu,'y');

if C >= C_L(1)
  n_ZVCs = 3;
  r_ZVCs = {};
  % m1 curve
  r_ZVCs{1} = [NR(aux.fx([nan,0]),aux.fxp([nan,0]), ...
    aux.x(L_pts(:,1)/2));0];
  % m2 curve
  r_ZVCs{2} = [NR(aux.fx([nan,0]),aux.fxp([nan,0]), ...
    aux.x(([1-mu;0]+L_pts(:,2))/2));0];
  % outer curve
  r_ZVCs{3} = [NR(aux.fx([nan,0]),aux.fxp([nan,0]), ...
    aux.x(2*L_pts(:,2)-[1-mu;0]));0];
elseif C >= C_L(2)
  n_ZVCs = 2;
  % m1+m2 curve
  r_ZVCs{1} = [NR(aux.fx([nan,0]),aux.fxp([nan,0]), ...
    aux.x(([1-mu;0]+L_pts(:,2))/2));0];
  % outer curve
  r_ZVCs{2} = [NR(aux.fx([nan,0]),aux.fxp([nan,0]), ...
    aux.x(2*L_pts(:,2)-[1-mu;0]));0];
elseif C > C_L(3)
  n_ZVCs = 1;
  r_ZVCs{1} = [NR(aux.fx([nan,0]),aux.fxp([nan,0]), ...
    aux.x(L_pts(:,3)/2));0];
elseif C >= C_L(4)
  n_ZVCs = 2;
  x0 = L_pts(1,4);
  % L4 curve
  r_ZVCs{1} = [x0;NR(aux.fy([x0,nan]),aux.fyp([x0,nan]), ...
    aux.y(L_pts(:,4)./[1;2]))];
  % L5 curve
  r_ZVCs{2} = [x0;NR(aux.fy([x0,nan]),aux.fyp([x0,nan]), ...
    aux.y(L_pts(:,5)./[1;2]))];
else
  n_ZVCs = 0;
  r_ZVCs = {};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Natural parameter continuation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if options.Method == "NPC"
for i = 1:n_ZVCs
  if abs(r_ZVCs{i}(2)) < eps
    % if ZVC start point is along x-axis, start NPC along +y direction
    dir='y'; sgn=+1;
  else
    % else ZVC is L4/L5, start NPC along +/-x direction depending on y
    dir='x'; sgn=sign(r_ZVCs{i}(2));
  end
  r_ZVCs{i} = gen_ZVC_NPC(r_ZVCs{i},dir,sgn,ds,aux);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Pseudo-arclength continuation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif options.Method == "PAC"
for i = 1:n_ZVCs
  % no need to specify direction for PAC, continuation along null space
  r_ZVCs{i} = gen_ZVC_PAC(r_ZVCs{i},C,mu,ds);
end

end
end

function [r_ZVC] = gen_ZVC_NPC(r_ZVC,dir0,sgn0,ds,aux)
% GEN_ZVC_NPC  Generate ONE zero velocity curve given initial point and
%              direction using natural parameter continuation

dir = dir0; sgn = sgn0;
while 1
  if dir == 'x'
    % if moving in +/-x, step with size ds and use N-R along y
    r0_new = r_ZVC(:,end)+sgn*[ds;0];
    r_ZVC(:,end+1) = [r0_new(1);NR(aux.fy(r0_new),aux.fyp(r0_new),aux.y(r0_new))];
  elseif dir == 'y'
    % if moving in +/-y, step with size ds and use N-R along x
    r0_new = r_ZVC(:,end)+sgn*[0;ds];
    r_ZVC(:,end+1) = [NR(aux.fx(r0_new),aux.fxp(r0_new),aux.x(r0_new));r0_new(2)];
  end
  % check if ZVC has closed by looking at the initial direction and the
  % initial point has been crossed.
  % assumes ZVC crosses x/y only twice
  if dir == dir0 && sgn == sgn0 && ( ...
      ( ...
        dir == 'y' ...
        && r_ZVC(2,1) < max(r_ZVC(2,end-1:end)) ...
        && r_ZVC(2,1) > min(r_ZVC(2,end-1:end)) ...
      ) || ( ...
        dir == 'x' ...
        && r_ZVC(1,1) < max(r_ZVC(1,end-1:end)) ...
        && r_ZVC(1,1) > min(r_ZVC(1,end-1:end)) ...
      ))
    break;
  end
  % update step direction
  [dir,sgn] = closest_unit(diff(r_ZVC(:,end-1:end),1,2));
end
r_ZVC(:,end) = r_ZVC(:,1);
end

function [r_ZVC] = gen_ZVC_PAC(r_ZVC,C,mu,ds)
% GEN_ZVC_PAC  Generate ONE zero velocity curve given initial point and
%              direction using pseudo-arclength continuation

while 1
  % get step direction by rotating gradient vector 90 deg
  dir = [0,1;-1,0]*PCR3BP.gradUast(r_ZVC(:,end),mu,'n');
  r0_new = r_ZVC(:,end)+dir*ds;
  F = @(r) [2*Uast(r,mu)-C;dot(dir,r-r_ZVC(:,end))-ds];
  JF = @(r) [2*PCR3BP.gradUast(r,mu),dir]';

  % solve multi-variate N-R
  r_ZVC(:,end+1) = NR_MV(F,JF,r0_new);

  % check if ZVC has closed
  if dot(r_ZVC(:,2)-r_ZVC(:,1),r_ZVC(:,end)-r_ZVC(:,1)) > 0 ...
      && dot(r_ZVC(:,2)-r_ZVC(:,1),r_ZVC(:,end-1)-r_ZVC(:,1)) < 0
    break;
  end
end
r_ZVC(:,end) = r_ZVC(:,1);
end

function [dir,sgn] = closest_unit(v)
% CLOSEST_UNIT  Return the nearest unit vector +/- x/y by angle

if abs(v(1)) > abs(v(2))
  dir = 'x'; sgn = sign(v(1));
else
  dir = 'y'; sgn = sign(v(2));
end
end

function [x] = NR(f,fp,x0)
% NR  Newton-Raphson solver for a single variable function
%   Find x such that f(x) = 0, starting at initial guess x0 with update
%   equation x := x - f(x)/fp(x), until |f(x)| < tol

x = x0;
tol = 1e-14;
while abs(f(x)) > tol
  x = x - f(x)/fp(x);
end
end

function [x] = NR_MV(F,JF,x0)
% NR_MV  Newton-Raphson solver for a R^n -> R^n function
%   Find root x of F : R^n -> R^n starting at initial guess x0 with update
%   equation x := x - (JF^-1)*F(x), until |F(x)| < tol

x = x0;
tol = 1e-14;
while norm(F(x)) > tol
  x = x - JF(x)\F(x);
end
end

function [Uast] = Uast(r,mu)
% UAST  Pseudo-potential for planar CR3BP

r_13 = r+[mu;0];
r_23 = r-[1-mu;0];
U = (1-mu)/norm(r_13)+(mu)/norm(r_23);
Uast = sum(r.^2,1)/2 + U;
end