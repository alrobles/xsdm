// [[Rcpp::depends(RcppParallel)]]
#include <Rcpp.h>
#include <RcppParallel.h>

using namespace Rcpp;
using namespace RcppParallel;

#include <cmath>
#include <vector>
#include <algorithm>

double response_func(const double x, const double param1, const double param2, const double param3)
{
  double u = x - param1;
  double v =  u < 0 ?  u/param2 : u/param3;
  double response = -0.5 * v * v;
  return response;
}

struct ResponseFunctor  {
  double param1;
  double param2;
  double param3;

  ResponseFunctor(double p1, double p2, double p3) : param1(p1), param2(p2), param3(p3) {}

  double operator()(double x) const {
    return response_func(x, param1, param2, param3);
  }
};

struct Response : public Worker {
  // source matrix
  const RMatrix<double> input;
  double par1;
  double par2;
  double par3;

  // destination matrix
  RMatrix<double> output;

  // initialize with source and destination
  Response(const NumericMatrix input,
           double p1,
           double p2,
           double p3,
           NumericMatrix output)
    : input(input), par1(p1), par2(p2), par3(p3), output(output) {}



  // take the square root of the range of elements requested
  void operator()(std::size_t begin, std::size_t end) {
    // The functor should be inside the void operator
    ResponseFunctor resFunctor(par1, par2, par3);

    std::transform(input.begin()  + begin,
                   input.begin()  + end,
                   output.begin() + begin,
                   resFunctor);
  }
};

// [[Rcpp::export(.response)]]
NumericMatrix response(NumericMatrix x, double param1, double param2, double param3) {

  // allocate the output matrix
  NumericMatrix output(x.nrow(), x.ncol());

  // SquareRoot functor (pass input and output matrices)
  Response response(x, param1, param2, param3,
                    output);

  // call parallelFor to do the work
  parallelFor(0, x.length(), response);

  // return the output matrix
  return output;
}
