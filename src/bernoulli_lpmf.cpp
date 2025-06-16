// [[Rcpp::depends(RcppParallel)]]
#include <Rcpp.h>
#include <RcppParallel.h>

using namespace Rcpp;
using namespace RcppParallel;

#include <cmath>
#include <vector>
#include <algorithm>

double bernoulli_lpmf_function(double y, double theta) {
  // Ensure theta is within the valid range (0, 1)
  //theta = std::clamp(theta, 0.0, 1.0);

  if (y == 1) {
    return std::log(theta);
  } else if (y == 0) {
    return std::log(1.0 - theta);
  } else {
    return -INFINITY; // Handle cases where y is not 0 or 1
  }
}


struct BernoulliLpmf : public Worker {
  // source matrix
  const RVector<double> x;
  const RVector<double> y;
  // destination vector
  RVector<double> output;
  // initialize with source and destination
  BernoulliLpmf(const NumericVector x,
                const NumericVector y,
                NumericVector output)
    : x(x), y(y), output(output) {}
  // take the square root of the range of elements requested
  void operator()(std::size_t begin, std::size_t end) {
    // The functor should be inside the void operator

    std::transform(y.begin()  + begin,
                   y.begin()  + end,
                   x.begin() + begin,
                   output.begin() + begin,
                   bernoulli_lpmf_function
                   //[](double a, double b) { return bernoulli_lpmf(b, a); }
    );
  }
};

// [[Rcpp::export(.bernoulli_lpmf)]]
NumericVector bernoulli_lpmf(NumericVector x, NumericVector y ) {
  // allocate the output matrix
  NumericVector output(x.size());
  // SquareRoot functor (pass input and output matrixes)
  BernoulliLpmf bernoulliLpmf(x, y, output);
  // call parallelFor to do the work
  parallelFor(0, x.length(), bernoulliLpmf);
  // return the output matrix
  return output;
}
