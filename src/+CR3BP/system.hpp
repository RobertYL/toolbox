#pragma once

#include <cmath>
#include <vector>

namespace CR3BP
{

typedef std::vector<double> state_t;

class system
{
public:
  system(double mu = 0.012150585609624) : mu(mu), um(1-mu) {}
  virtual ~system() = default;

  /**
   * @brief ODE for state (+ STM)
   */
  void operator()(const state_t& s, state_t& ds, const double t) const {
    (void) t;

    // compute state
    const double d = sqrt((s[0]+mu)*(s[0]+mu) + s[1]*s[1] + s[2]*s[2]),
                 d3 = d*d*d,
                 r = sqrt((s[0]-um)*(s[0]-um) + s[1]*s[1] + s[2]*s[2]),
                 r3 = r*r*r;

    ds[0] = s[3];
    ds[1] = s[4];
    ds[2] = s[5];

    ds[3] = -(um*(s[0]+mu)/d3) - (mu*(s[0]-um)/r3) + (2*s[4]) + s[0];
    ds[4] = -((um/d3           + mu/r3)*s[1])      - (2*s[3]) + s[1];
    ds[5] = -((um/d3           + mu/r3)*s[2]);

    if(s.size() == 6) return;

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

private:
  double mu, um;
}; /* class system */

} /* namespace CR3BP */ 
