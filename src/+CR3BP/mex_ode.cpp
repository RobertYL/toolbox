/**
 * CR3BP.MEX_ODE  First-order differential equation for spatial CR3BP
 *  Defaults to E-M system. (C MEX)
 *
 *  USAGE:
 *    ds = mex_ode(t,s)
 *    ds = mex_ode(t,s,mu)
 *    ds = mex_ode(s,mu)
 *    ds = mex_ode(s)
 */

#include <cmath>
#include <mex.h>

void ode(const double* s, double* ds, double mu) {
  const double um = 1.0 - mu,
               d = sqrt((s[0]+mu)*(s[0]+mu) + s[1]*s[1] + s[2]*s[2]),
               d3 = d*d*d,
               r = sqrt((s[0]-um)*(s[0]-um) + s[1]*s[1] + s[2]*s[2]),
               r3 = r*r*r;

  ds[0] = s[3];
  ds[1] = s[4];
  ds[2] = s[5];

  ds[3] = -(um*(s[0]+mu)/d3) - (mu*(s[0]-um)/r3) + (2*s[4]) + s[0];
  ds[4] = -((um/d3           + mu/r3)*s[1])      - (2*s[3]) + s[1];
  ds[5] = -((um/d3           + mu/r3)*s[2]);
}

void mexFunction(int nlhs, mxArray* plhs[],
                 int nrhs, const mxArray* prhs[]) {

  // parse MU
  bool has_mu = (nrhs == 2 && mxGetM(prhs[1]) == 1 && mxGetN(prhs[1]) == 1)
                 || nrhs == 3;
  double mu = 0.012150585609624;
  if(has_mu) mu = *mxGetPr(prhs[nrhs-1]);

  // parse S
  double* s = mxGetPr(prhs[nrhs-1 - has_mu]);

  // evaluate ode
  plhs[0] = mxCreateDoubleMatrix((mwSize) 6, (mwSize) 1, mxREAL);
  ode(s, mxGetPr(plhs[0]), mu);
}
