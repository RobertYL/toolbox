/**
 * CR3BP.MEX_BOOST78  Propagate CR3BP using Boost RKF78
 *  Defaults to E-M system. (C++ MEX)
 *
 *  USAGE:
 *    [t,s] = mex_boost78(tspan,s0)
 *    [t,s,Phi] = mex_boost78(tspan,s0)
 *    [...] = mex_boost78(...,opts)
 */

// TODO: add custom mu <04-18-26>

#pragma warning(push)
#pragma warning(disable : 4996)

#include <boost/numeric/odeint.hpp>
#include <cmath>
#include <mex.hpp>
#include <mexAdapter.hpp>
#include "system.hpp"

#pragma warning(pop)

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
  void operator()(matlab::mex::ArgumentList out,
      matlab::mex::ArgumentList in) {
    validate_args(out, in);

    matlab::data::TypedArray<double> 
        tspan_matlab = (matlab::data::TypedArray<double>)(in[0]),
        s0_matlab = (matlab::data::TypedArray<double>)(in[1]);

    // Parse Input
    typedef std::vector<double> tspan_t;
    tspan_t tspan(tspan_matlab.begin(), tspan_matlab.end());
    CR3BP::state_t s0(s0_matlab.begin(), s0_matlab.end());

    // Parse Options
    double AbsTol = 1e-16,
           RelTol = 1e-13,
           InitStep = 1e-10;

    if(in.size() == 3) {
      matlab::data::StructArray opts_matlab = in[2];
      auto substitute = [&opts_matlab](
          const std::string& name, double& val) -> void {
        // Check existence
        bool found = 0;
        for(const auto& field : opts_matlab.getFieldNames())
          if(field == name) { found = 1; break; }
        if(!found) return;

        matlab::data::Array val_matlab = opts_matlab[0][name];
        if(val_matlab.getType() != matlab::data::ArrayType::DOUBLE
            || val_matlab.getNumberOfElements() != 1) return;

        val = matlab::data::TypedArray<double>(val_matlab)[0];
      };
      
      substitute("AbsTol", AbsTol);
      substitute("RelTol", RelTol);
      substitute("InitStep", InitStep);
    }

    // Propagate
    CR3BP::system cr3bp;
    IntegrationObserver obs;
    
    typedef boost::numeric::odeint::runge_kutta_fehlberg78<CR3BP::state_t> rk78;
    boost::numeric::odeint::controlled_runge_kutta<rk78> stepper
        = boost::numeric::odeint::make_controlled<rk78>(AbsTol, RelTol);

    if(tspan.size() == 2)
      boost::numeric::odeint::integrate_adaptive(
          stepper, cr3bp, s0, tspan[0], tspan[1], InitStep, std::ref(obs));
    else
      boost::numeric::odeint::integrate_times(
          stepper, cr3bp, s0, tspan.begin(), tspan.end(), InitStep, std::ref(obs));

    // Parse Output
    matlab::data::ArrayFactory af;

    out[0] = af.createArray<std::vector<double>::iterator>(
        matlab::data::ArrayDimensions({1, obs.t.size()}),
        obs.t.begin(), obs.t.end());
    out[1] = af.createArray<std::vector<double>::iterator>(
        matlab::data::ArrayDimensions({6, obs.t.size()}),
        obs.s.begin(), obs.s.end(), matlab::data::InputLayout::COLUMN_MAJOR);
    if(s0.size() == 42)
      out[2] = af.createArray<CR3BP::state_t::iterator>(
          matlab::data::ArrayDimensions({6, 6}),
          s0.begin() + 6, s0.end(), matlab::data::InputLayout::COLUMN_MAJOR);
  }

  /**
   * Validate input and output arguments
   */
  void validate_args(matlab::mex::ArgumentList out,
      matlab::mex::ArgumentList in) {

    // Validate Input
    if(in.size() < 2)
      error_matlab("Too few arguments");
    if(in.size() > 3)
      error_matlab("Too many arguments");

    if(in[0].getType() != matlab::data::ArrayType::DOUBLE
        || in[0].getNumberOfElements() < 2)
      error_matlab("Invalid tspan");

    if(in[1].getType() != matlab::data::ArrayType::DOUBLE
        || (in[1].getDimensions() != matlab::data::ArrayDimensions({6, 1})
        && in[1].getDimensions() != matlab::data::ArrayDimensions({42, 1})))
      error_matlab("Invalid s0");

    if(in.size() == 3 && in[2].getType() != matlab::data::ArrayType::STRUCT)
      error_matlab("Invalid options struct");

    // Validate Output
    const bool has_stm
        = in[1].getDimensions() == matlab::data::ArrayDimensions({42, 1});
    if((!has_stm && out.size() != 2) || (has_stm && out.size() != 3))
      error_matlab("Incorrect number of output variables");
  }

  /**
   * Helper function for throwing MATLAB errors
   */
  void error_matlab(const std::string& msg) {
    matlab::data::ArrayFactory af;
    std::shared_ptr<matlab::engine::MATLABEngine> engine_ptr = getEngine();
    engine_ptr->feval(u"error", 0,
        std::vector<matlab::data::Array>({af.createScalar(
            "CR3BP.MEX_BOOST78: " + msg)}));
  }
}; /* class MexFunction */ 

