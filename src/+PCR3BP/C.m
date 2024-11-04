function [C] = C(r,v,mu)
% PCR3BP.C  Jacobi constant for planar CR3BP

C = 2*((1-mu)./vecnorm(r+[mu;0]) + mu./vecnorm(r-[1-mu;0])) ...
    + sum(r.^2,1) - sum(v.^2,1);
end