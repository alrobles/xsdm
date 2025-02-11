#' Check environmental data list coordinate reference system
#' Check if all elements in the env_data list have equal coords
#'
#' @param envData An list with environmental data time serires as elements.
#' @return If all the raster time serires are the same, return the crs string. If not
#' returns FALSE
check_envdata_timestep_consistency <- function(envData){

  tstep <- function(raster_ts){
    tinfo <- terra::timeInfo(raster_ts)
    tinfo$step
  }

  timeStart <- function(raster_ts){
    tinfo <- terra::time(raster_ts)
    tinfo[1]
  }

  timeEnd <- function(raster_ts){
    tinfo <- terra::time(raster_ts)
    tinfo[length(tinfo)]
  }

  tstep_increment <- function(raster_ts){
    check_sequence_increment(terra::time(raster_ts))
  }


  FlagMsg <- function(flag, msg = "test"){
    if(is.logical(flag) && !flag){
      Msg <- msg
    } else {Msg = ""}
    return(Msg)
  }

  nlyrFlag      <- Reduce(idem,  Map(terra::nlyr, envData))
  nlyrMsg <- FlagMsg(nlyrFlag, "Number of layers differs. ")

  tstepFlag <- Reduce(idem,  Map(tstep, envData) )
  tstepMsg <- FlagMsg(tstepFlag, "Time step in layers differs. ")

  incrementFlag <- Reduce(idem,  Map(tstep_increment, envData) )
  incrementMsg <- FlagMsg(incrementFlag, "Time steps are not consecutive. ")

  timeStartFlag <- Reduce(idem,  Map(timeStart, envData) )
  timeStartMsg <- FlagMsg(timeStartFlag, "Starting date is not the same in envData. ")

  Flags <- list(nlyrFlag,
       tstepFlag,
       incrementFlag,
       timeStartFlag)

  Msgs <- list(nlyrMsg,
                tstepMsg,
                incrementMsg,
                timeStartMsg)

  FlagsVect <- Reduce(c, Map(f = is.logical, Flags))


  if( any(FlagsVect) ){

    outputFlag <- Reduce(any, Flags[FlagsVect])
    outputMsg <- paste(Msgs, collapse = "")
    outputMsg <- sub("\\s$", "", outputMsg)


    return(list(flag = outputFlag,
                msg = outputMsg))
  } else {
    return(list(flag = TRUE,
                msg = ""))

  }
}
