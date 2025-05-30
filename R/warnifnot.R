#' Test the Truth of R Expressions and Warn
#'
#' @param ...,exprs any number of R expressions, which should each evaluate to (a logical vector of all) TRUE.
#' @param exprObject alternative to exprs or ...: an ‘expression-like’ object, typically an expression, but also a call, a name, or atomic constant such as TRUE.
#' @param local  (only when exprs is used:) indicates the environment in which the expressions should be evaluated; by default the one from where stopifnot() has been called.
#'
warnifnot <- function (..., exprs, exprObject, local = TRUE)
{
  n <- ...length()
  if ((has.e <- !missing(exprs)) || !missing(exprObject)) {
    if (n || (has.e && !missing(exprObject)))
      stop("Only one of 'exprs', 'exprObject' or expressions, not more")
    envir <- if (isTRUE(local))
      parent.frame()
    else if (isFALSE(local))
      .GlobalEnv
    else if (is.environment(local))
      local
    else stop("'local' must be TRUE, FALSE or an environment")
    E1 <- if (has.e && is.call(exprs <- substitute(exprs)))
      exprs[[1]]
    cl <- if (is.symbol(E1) && E1 == quote(`{`)) {
      exprs[[1]] <- quote(stopifnot)
      exprs
    }
    else as.call(c(quote(stopifnot), if (!has.e) exprObject else as.expression(exprs)))
    names(cl) <- NULL
    return(eval(cl, envir = envir))
  }
  Dparse <- function(call, cutoff = 60L) {
    ch <- deparse(call, width.cutoff = cutoff)
    if (length(ch) > 1L)
      paste(ch[1L], "....")
    else ch
  }
  head <- function(x, n = 6L) x[seq_len(if (n < 0L) max(length(x) +
                                                          n, 0L) else min(n, length(x)))]
  abbrev <- function(ae, n = 3L) paste(c(head(ae, n), if (length(ae) >
                                                          n) "...."), collapse = "\n  ")
  for (i in seq_len(n)) {
    r <- ...elt(i)
    if (!(is.logical(r) && !anyNA(r) && all(r))) {
      dots <- match.call()[-1L]
      if (is.null(msg <- names(dots)) || !nzchar(msg <- msg[i])) {
        cl.i <- dots[[i]]
        msg <- if (is.call(cl.i) && identical(1L, pmatch(quote(all.equal),
                                                         cl.i[[1]])) && (is.null(ni <- names(cl.i)) ||
                                                                         length(cl.i) == 3L || length(cl.i <- cl.i[!nzchar(ni)]) ==
                                                                         3L))
          sprintf(gettext("%s and %s are not equal:\n  %s"),
                  Dparse(cl.i[[2]]), Dparse(cl.i[[3]]), abbrev(r))
        else sprintf(ngettext(length(r), "%s is not TRUE",
                              "%s are not all TRUE"), Dparse(cl.i))
      }
      warning(simpleError(msg, call = if (p <- sys.parent(1L))
        sys.call(p)))
    }
  }
  invisible()
}

