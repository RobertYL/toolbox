function [C] = C(mu,r,v)
% CR3BP.C  Jacobi constant for spatial CR3BP

arguments
  mu (1,1) double
  r  (3,:) double
  v  (3,:) double
end

C = 2*((1-mu)./vecnorm(r+[mu;0;0]) + mu./vecnorm(r-[1-mu;0;0])) ...
    + sum(r(1:2,:).^2,1) - sum(v.^2,1);
end