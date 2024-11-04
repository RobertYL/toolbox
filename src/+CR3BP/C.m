function [C] = C(r,v,mu)
% CR3BP.C  Jacobi constant for spatial CR3BP

C = 2*((1-mu)./vecnorm(r+[mu;0;0]) + mu./vecnorm(r-[1-mu;0;0])) ...
    + sum(r(1:2,:).^2,1) - sum(v.^2,1);
end