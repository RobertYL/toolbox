/**
 * CR3BP.MEX_ODE_STM  First-order differential equation for spatial CR3BP STM
 *  Defaults to E-M system. (C MEX)
 *
 *  USAGE:
 *    ds = mex_ode_STM(t,s)
 *    ds = mex_ode_STM(t,s,mu)
 *    ds = mex_ode_STM(s,mu)
 *    ds = mex_ode_STM(s)
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

  // compute stm
  const double d5 = d*d*d*d*d,
               r5 = r*r*r*r*r;
  const double
    U_xx = 1 - um/d3 - mu/r3 + 3*(um*(s[0]+mu)*(s[0]+mu)/d5
                                  + mu*(s[0]-um)*(s[0]-um)/r5),
    U_yy = 1 - um/d3 - mu/r3 + 3*(um/d5 + mu/r5)*s[1]*s[1],
    U_zz =   - um/d3 - mu/r3 + 3*(um/d5 + mu/r5)*s[2]*s[2],
    U_xy = 3*(um*(s[0]+mu)/d5 + mu*(s[0]-um)/r5)*s[1],
    U_xz = 3*(um*(s[0]+mu)/d5 + mu*(s[0]-um)/r5)*s[2],
    U_yz = 3*(um/d5           + mu/r5)*s[1]*s[2];

  const double A[3][6] = {
    {U_xx, U_xy, U_xz,  0.0, +2.0, 0.0},
    {U_xy, U_yy, U_yz, -2.0,  0.0, 0.0},
    {U_xz, U_yz, U_zz,  0.0,  0.0, 0.0},
  };

  for(int i = 0; i < 3; ++i)
    for(int j = 0; j < 6; ++j)
      ds[6 + i + j*6] = s[6 + (i+3) + j*6];
  for(int i = 3; i < 6; ++i)
    for(int j = 0; j < 6; ++j) {
      double& Phi_ij = ds[6 + i + j*6];
      Phi_ij = 0.0;
      for(int k = 0; k < 6; ++k)
        Phi_ij += A[i-3][k] * s[6 + k + j*6];
    }
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
  plhs[0] = mxCreateDoubleMatrix((mwSize) 42, (mwSize) 1, mxREAL);
  ode(s, mxGetPr(plhs[0]), mu);
}
