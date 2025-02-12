// [[Rcpp::depends(RcppParallel)]]
#include <Rcpp.h>
#include <RcppParallel.h>

using namespace Rcpp;
using namespace RcppParallel;

#include <cmath>
#include <vector>
#include <algorithm>

double inv_logit(double loglam, double c) {
  // Ensure theta is within the valid range (0, 1)
  //double invlogit = 1/(1 + std::exp(0.5*loglam + c));
  //return pd * invlogit;
  double x = loglam - c;
  return 1/(1 + exp(-x));

}

struct InvLogitFunctor  {
  double param1;
  double param2;

  InvLogitFunctor(double p1, double p2) : param1(p1), param2(p2) {}

  double operator()(double x) const {
    return param2*inv_logit(x, param1);
  }
};


struct InvLogit : public Worker {

  // source matrix
  const RMatrix<double> input;
  double par1;
  double par2;

  // destination vector
  RMatrix<double> output;

  // initialize with source and destination
  InvLogit(const NumericMatrix input,
           double p1,
           double p2,
           NumericMatrix output)
    : input(input),  par1(p1), par2(p2), output(output) {}

  // take the square root of the range of elements requested
  void operator()(std::size_t begin, std::size_t end) {
    // The functor should be inside the void operator
    InvLogitFunctor invlogitFunctor(par1, par2);

    std::transform(input.begin()  + begin,
                   input.begin()  + end,
                   output.begin() + begin,
                   invlogitFunctor);
  }
};

// [[Rcpp::export(.invLogit)]]
NumericMatrix inverse_logit(NumericMatrix input, double param1, double param2) {

  // allocate the output matrix
  NumericMatrix output(input.nrow(), 1);

  // inv logit functor (pass params to input and output matrices)
  InvLogit invLogit(input, param1, param2, output);

  // call parallelFor to do the work
  parallelFor(0, input.nrow(), invLogit);

  // return the output matrix
  return output;
}
