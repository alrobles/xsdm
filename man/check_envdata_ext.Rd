% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/check_envdata_ext.R
\name{check_envdata_ext}
\alias{check_envdata_ext}
\title{Check environmental data list extent
Check if all elements in the env_data list have equal extent}
\usage{
check_envdata_ext(envData)
}
\arguments{
\item{envData}{An list with environmental data time serires as elements.}
}
\value{
If all the raster time serires are the same, return the crs string. If not
returns FALSE
}
\description{
Check environmental data list extent
Check if all elements in the env_data list have equal extent
}
