/**
 * CR3BP.MEX_BOOST78  Propagate CR3BP using Boost RKF78
 *  Defaults to E-M system. (C++ MEX)
 *  
 *  Also supports batch and parallel evaluation. See extended usage.
 *
 *  USAGE:
 *    [t,s] = mex_boost78(tspan,s0)
 *    [t,s,Phi] = mex_boost78(tspan,s0)
 *    [...] = mex_boost78(...,opts)
 *
 *  EXTENDED USAGE:
 *    [sf,Phi] = mex_boost78([t0,tf],s0)
 *    [s,Phi] = mex_boost78(tspan,s0)
 *    
 */

#pragma warning(push)
#pragma warning(disable : 4996)

#include <boost/numeric/odeint.hpp>
#include <cmath>
#include <mex.hpp>
#include <mexAdapter.hpp>
#include "system.hpp"

#pragma warning(pop)

namespace mdata = matlab::data;
using margs_t = matlab::mex::ArgumentList;
namespace odeint = boost::numeric::odeint;

/**
 * Class for saving states during integration
 */
class IntegrationObserver
{
public:
  std::vector<double> t, s;

  void operator()(const CR3BP::state_t& s_cur, const double t_cur) {
    t.push_back(t_cur);
    for(size_t i = 0; i < 6; ++i)
      s.push_back(s_cur[i]);
  }
}; /* class IntegrationObserver */ 

class MexFunction : public matlab::mex::Function
{
public:
  void operator()(margs_t out, margs_t in) {
    validate_args(out, in);
    mdata::TypedArray<double> tspan_matlab = in[0],
                              s0_matlab = in[1];

    // Parse Input
    typedef std::vector<double> tspan_t;
    tspan_t tspan(tspan_matlab.begin(), tspan_matlab.end());
    const bool is_t0tf = tspan.size() == 2;
    const size_t N_s = s0_matlab.getDimensions()[0],
                 N_s0 = s0_matlab.getDimensions()[1];
    const bool has_stm = N_s == 42;

    // Parse Options
    double AbsTol = 1e-16,
           RelTol = 1e-13,
           InitStep = 1e-10,
           mu;
    bool has_mu = 0;

    if(in.size() == 3) {
      mdata::StructArray opts_matlab = in[2];
      auto substitute = [&opts_matlab](
          const std::string& name, double& val) -> bool {
        // Check existence
        bool found = 0;
        for(const auto& field : opts_matlab.getFieldNames())
          if(field == name) { found = 1; break; }
        if(!found) return 0;

        mdata::Array val_matlab = opts_matlab[0][name];
        if(val_matlab.getType() != mdata::ArrayType::DOUBLE
            || val_matlab.getNumberOfElements() != 1) return 0;

        val = mdata::TypedArray<double>(val_matlab)[0];
        return 1;
      };
      
      substitute("AbsTol", AbsTol);
      substitute("RelTol", RelTol);
      substitute("InitStep", InitStep);
      has_mu = substitute("mu", mu);
    }

    // Additional Initialization
    if(tspan[0] > tspan[1]) InitStep = -InitStep;
    CR3BP::system cr3bp = has_mu ? CR3BP::system(mu) : CR3BP::system();
    typedef odeint::runge_kutta_fehlberg78<CR3BP::state_t> rk78;

    // Propagate
    if(N_s0 == 1) { // Single IC
      CR3BP::state_t s0(s0_matlab.begin(), s0_matlab.end());
      IntegrationObserver obs;
      odeint::controlled_runge_kutta<rk78> stepper
          = odeint::make_controlled<rk78>(AbsTol, RelTol);

      if(is_t0tf)
        odeint::integrate_adaptive(
            stepper, cr3bp,
            s0, tspan[0], tspan[1],
            InitStep, std::ref(obs));
      else
        odeint::integrate_times(
            stepper, cr3bp,
            s0, tspan.begin(), tspan.end(),
            InitStep, std::ref(obs));

      // Parse Output
      mdata::ArrayFactory af;

      out[0] = af.createArray<std::vector<double>::iterator>(
          mdata::ArrayDimensions({1, obs.t.size()}),
          obs.t.begin(), obs.t.end());
      out[1] = af.createArray<std::vector<double>::iterator>(
          mdata::ArrayDimensions({6, obs.t.size()}),
          obs.s.begin(), obs.s.end(), mdata::InputLayout::COLUMN_MAJOR);
      if(has_stm)
        out[2] = af.createArray<CR3BP::state_t::iterator>(
            mdata::ArrayDimensions({6, 6}),
            s0.begin() + 6, s0.end(), mdata::InputLayout::COLUMN_MAJOR);
    } else { // Multiple ICs
      std::vector<CR3BP::state_t> s(N_s0);
      auto it = s0_matlab.begin();
      for(size_t i_s0 = 0; i_s0 < N_s0; ++i_s0) {
        s[i_s0] = CR3BP::state_t(it, it+N_s);
        it += N_s;
      }
      std::vector<IntegrationObserver> obs;
      if(!is_t0tf)
        obs.resize(N_s0);

      #pragma omp parallel
      {
        odeint::controlled_runge_kutta<rk78> stepper
            = odeint::make_controlled<rk78>(AbsTol, RelTol);

        #pragma omp for
        for(size_t i_s0 = 0; i_s0 < N_s0; ++i_s0) {
          if(is_t0tf)
            odeint::integrate_adaptive(
                stepper, cr3bp,
                s[i_s0], tspan[0], tspan[1],
                InitStep);
          else
            odeint::integrate_times(
                stepper, cr3bp,
                s[i_s0], tspan.begin(), tspan.end(),
                InitStep, std::ref(obs[i_s0]));
        }
      }

      // Parse Output
      mdata::ArrayFactory af;

      if(is_t0tf) {
        auto sf_matlab = af.createArray<double>({6, N_s0});
        auto it_sf = sf_matlab.begin();
        for(size_t i_s0 = 0; i_s0 < N_s0; ++i_s0, it_sf += 6)
          std::copy_n(s[i_s0].begin(), 6, it_sf);
        out[0] = std::move(sf_matlab);
      } else {
        const size_t N_t = tspan.size();
        auto s_matlab = af.createArray<double>({6, N_t, N_s0});
        auto it_s = s_matlab.begin();
        for(size_t i_s0 = 0; i_s0 < N_s0; ++i_s0, it_s += N_t*6)
          std::copy_n(obs[i_s0].s.begin(), N_t*6, it_s);
        out[0] = std::move(s_matlab);
      }

      if(has_stm) {
        auto Phi_matlab = af.createArray<double>({6, 6, N_s0});
        auto it_Phi = Phi_matlab.begin();
        for(size_t i_s0 = 0; i_s0 < N_s0; ++i_s0, it_Phi += 36)
          std::copy_n(s[i_s0].begin()+6, 36, it_Phi);
        out[1] = std::move(Phi_matlab);
      }
    }
  }

  /**
   * Validate input and output arguments
   */
  void validate_args(margs_t out, margs_t in) {

    // Validate Input
    if(in.size() < 2)
      error_matlab("Too few arguments");
    if(in.size() > 3)
      error_matlab("Too many arguments");

    const auto tspan_numel = in[0].getNumberOfElements();
    if(in[0].getType() != mdata::ArrayType::DOUBLE || tspan_numel < 2)
      error_matlab("Invalid tspan");

    const auto s_dims = in[1].getDimensions();
    if(in[1].getType() != mdata::ArrayType::DOUBLE
        || s_dims.size() != 2 || (s_dims[0] != 6 && s_dims[0] != 42))
      error_matlab("Invalid s0");

    if(in.size() == 3 && in[2].getType() != mdata::ArrayType::STRUCT)
      error_matlab("Invalid options struct");

    // Validate Output
    const bool has_stm = s_dims[0] == 42,
               is_batch = s_dims[1] > 1;
    if(out.size() != 1 + has_stm + (!is_batch))
      error_matlab("Incorrect number of output variables");
  }

  /**
   * Helper function for throwing MATLAB errors
   */
  void error_matlab(const std::string& msg) {
    mdata::ArrayFactory af;
    std::shared_ptr<matlab::engine::MATLABEngine> engine_ptr = getEngine();
    engine_ptr->feval(u"error", 0,
        std::vector<mdata::Array>({af.createScalar(
            "CR3BP.MEX_BOOST78: " + msg)}));
  }
}; /* class MexFunction */ 
