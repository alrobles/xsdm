#include <Rcpp.h>
#include <algorithm>
using namespace Rcpp;

#include <RcppParallel.h>
using namespace RcppParallel;

struct ParallelMean : public Worker {
  // input matrix to read from
  const RMatrix<double> mat;

  // output matrix to write to
  RMatrix<double> rmat;

  ParallelMean(const NumericMatrix mat, NumericMatrix rmat)
    : mat(mat), rmat(rmat) {}

  void operator()(std::size_t begin, std::size_t end) {
    for (std::size_t i = begin; i < end; i++) {

      RMatrix<double>::Row v1 = mat.row(i);
      double result = std::accumulate(v1.begin(), v1.end(), 0.0)/v1.size();
      rmat(i, 0) = result;
    }
  }
};

// [[Rcpp::export(.meanRow)]]
NumericMatrix meanRow(NumericMatrix mat) {

  // allocate the matrix we will return,
  NumericMatrix rmat(mat.nrow(), 1);

  // create the worker
  ParallelMean parallelMean(mat, rmat);

  // call it with parallelFor
  parallelFor(0, mat.nrow(), parallelMean);

  return rmat;
}
