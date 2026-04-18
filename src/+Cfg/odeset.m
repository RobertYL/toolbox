function options = odeset()
% CFG.ODESET  Default integrator tolerances
  options = odeset(RelTol=1e-13,AbsTol=1e-16);
end

