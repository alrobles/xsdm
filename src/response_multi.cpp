// [[Rcpp::depends(RcppParallel)]]
#include <Rcpp.h>
#include <RcppParallel.h>

using namespace Rcpp;
using namespace RcppParallel;

#include <cmath>
#include <vector>
#include <algorithm>

double response_func(const double x, const double sigl, const double sigr)
{
  double v =  x < 0 ?  x/(sigl*sigl) : x/(sigr*sigr);
  return v;
}

struct Response_Multi : public Worker {
  // source matrix
  const RMatrix<double> input;
  const RVector<double> sigmal;
  const RVector<double> sigmar;

  // destination matrix
  RMatrix<double> output;

  // initialize with source and destination
  Response_Multi(const NumericMatrix input,
                 const NumericVector sigmal,
                 const NumericVector sigmar,
                 NumericMatrix output)
    : input(input), sigmal(sigmal), sigmar(sigmar), output(output) {}



  //
  void operator()(std::size_t begin, std::size_t end) {
    // The functor should be inside the void operator

    for (std::size_t i = begin; i < end; i++) {
      for(std::size_t j = 0; j < input.ncol(); j++){
        double x  = input(i, j);
        output(i, j) = response_func(x, sigmal[j], sigmar[j]);
      }
    }

    // to check if can be done inside the previous for

    // for (std::size_t i = begin; i < end; i++) {
    //   RMatrix<double>::Row row_vec = pivot.row(i);
    //   double result = std::accumulate(row_vec.begin(), row_vec.end(), 0.0);
    //   output(i, 0) = result;
    // }

  }
};

// [[Rcpp::export(.response_multi)]]
NumericMatrix response_multi(NumericMatrix x, NumericVector sigl, NumericVector sigr) {


  // allocate the output matrix
  NumericMatrix output(x.nrow(), x.ncol());

  // SquareRoot functor (pass input and output matrices)
  Response_Multi response_multi(x, sigl, sigr, output);

  // call parallelFor to do the work
  parallelFor(0, x.nrow(), response_multi);

  // return the output matrix
  return output;
}
