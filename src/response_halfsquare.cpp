// [[Rcpp::depends(RcppParallel)]]
#include <Rcpp.h>
#include <RcppParallel.h>

using namespace Rcpp;
using namespace RcppParallel;

#include <cmath>
#include <vector>
#include <algorithm>

double square(const double x)
{
  double v =  x * x;
  return v;
}

struct Response_HalfSquare : public Worker {
  // source matrix
  const RMatrix<double> input;


  // transition matrix
  RMatrix<double> pivot;
  // destination matrix
  RMatrix<double> output;

  // initialize with source and destination
  Response_HalfSquare(const NumericMatrix input,
                 NumericMatrix pivot,
                 NumericMatrix output)
    : input(input), pivot(pivot), output(output) {}



  // take the square root of the range of elements requested
  void operator()(std::size_t begin, std::size_t end) {
    // The functor should be inside the void operator

    for (std::size_t i = begin; i < end; i++) {
      for(std::size_t j = 0; j < input.ncol(); j++){
        double x  = input(i, j);
        pivot(i, j) = square(x);
      }
    }

    // to check if can be done inside the previous for

    for (std::size_t i = begin; i < end; i++) {
      RMatrix<double>::Row row_vec = pivot.row(i);
      double result = std::accumulate(row_vec.begin(), row_vec.end(), 0.0);
      output(i, 0) = -0.5*result;
    }

  }
};

// [[Rcpp::export(.response_halfsquare)]]
NumericMatrix response_halfsquare(NumericMatrix x) {

  // allocate the pivot matrix
  NumericMatrix pivot(x.nrow(), x.ncol());

  // allocate the output matrix
  NumericMatrix output(x.nrow(), 1);

  // SquareRoot functor (pass input and output matrices)
  Response_HalfSquare response_halfSquare(x, pivot, output);

  // call parallelFor to do the work
  parallelFor(0, x.nrow(), response_halfSquare);

  // return the output matrix
  return output;
}
