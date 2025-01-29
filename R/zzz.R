# .onLoad <- function(libname, pkgname)
# {
#   library.dynam("xsdm", pkgname, libname)
# }

xsdmStartupMessage <- function()
{
  # Startup message obtained as
  # > figlet -f slant MCLUST
  msg <- c(paste0(
    "              _
__  _____  __| |_ __ ___
\\ \\/ / __|/ _` | '_ ` _ \\
 >  <\\__ \\ (_| | | | | | |
/_/\\_\\___/\\__,_|_| |_| |_|    version ",
    packageVersion("xsdm")),
    "\nType 'citation(\"xsdm\")' for citing this R package in publications.")
  return(msg)
}

.onAttach <- function(lib, pkg)
{
  # unlock .xsdm variable allowing its modification
  unlockBinding("xsdm", asNamespace("xsdm"))
  # startup message
  msg <- xsdmStartupMessage()
  if(!interactive())
    msg[1] <- paste("Package 'xsdm' version", packageVersion("xsdm"))
  packageStartupMessage(msg)
  invisible()
}
