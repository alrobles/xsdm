% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/envGridArray.R
\name{envGridArray}
\alias{envGridArray}
\title{Environmental Grid Array. Returns an array of environmental
combinations from a grid with a length out split.
It can be used to get the probability of detection along
a list of environmental time series}
\usage{
envGridArray(envData, lenght = 100)
}
\arguments{
\item{envData}{A list with environmental raster time series}

\item{lenght}{Number of grid splits}
}
\value{
An array with environmental combinations from a grid
}
\description{
Environmental Grid Array. Returns an array of environmental
combinations from a grid with a length out split.
It can be used to get the probability of detection along
a list of environmental time series
}
\examples{
bio1 <- terra::unwrap(cmcc_cm_bio1)
bio12 <- terra::unwrap(cmcc_cm_bio12)
envData <- list(bio01 = bio1, bio12 = bio12)
envGridArray(envData)
}
