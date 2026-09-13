# transforms.R — resolve `provider: transform` registry entries.
#
# A transform entry carries a `formula` string. Where every input token is a
# FRED series id (e.g. "WALCL - WTREGEN - RRPONTSYD"), we fetch each from FRED,
# align them onto a common date grid by last-observation-carried-forward (so
# weekly/quarterly inputs combine with daily ones), then evaluate the formula.
#
# Transforms whose inputs are NOT all FRED ids (copper/gold, froth composite,
# China credit impulse, anything needing scraped/market inputs) raise a clear
# "pending" condition until those providers land in a later phase.

# Align a named list of (date,value) frames onto the union date grid, LOCF.
.align_locf <- function(series, ids) {
  all_dates <- sort(unique(do.call(c, lapply(series, function(s) s$date))))
  out <- tibble::tibble(date = all_dates)
  for (id in ids) {
    s   <- dplyr::arrange(series[[id]], date)
    idx <- findInterval(all_dates, s$date)        # largest s$date <= grid date
    v   <- rep(NA_real_, length(all_dates))
    has <- idx >= 1
    v[has] <- s$value[idx[has]]
    out[[id]] <- v
  }
  out
}

#' Resolve a transform entry to a (date, value) tibble, or stop("pending: ...").
resolve_transform <- function(entry, start, end, ttl = 6 * 3600) {
  formula <- entry$formula
  if (is.null(formula)) stop("pending: transform has no formula", call. = FALSE)

  # FRED ids look like an uppercase letter then >=2 alphanumerics.
  toks <- unique(regmatches(formula, gregexpr("[A-Z][A-Z0-9]{2,}", formula))[[1]])
  if (!length(toks)) {
    stop("pending: transform inputs are not FRED ids (needs another provider)", call. = FALSE)
  }

  # The formula comes from the registry YAML, so it is only ever evaluated as plain
  # arithmetic over the fetched series: identifiers, numbers, + - * / ( ) and spaces.
  # Anything else (other names, $, backticks, assignment, ...) is refused before any
  # network request or evaluation happens.
  if (!grepl("^[A-Za-z0-9_ .+*/()-]+$", formula)) {
    stop("pending: transform formula contains disallowed characters", call. = FALSE)
  }
  idents <- unique(regmatches(formula, gregexpr("[A-Za-z_][A-Za-z0-9_.]*", formula))[[1]])
  if (length(setdiff(idents, toks))) {
    stop("pending: transform formula needs non-FRED inputs", call. = FALSE)
  }

  # Fetch each token from FRED; a token that isn't a real FRED id means this
  # transform can't resolve yet.
  series <- lapply(toks, function(t) {
    tryCatch(fred_series(t, as.Date(start) - 400, end, ttl = ttl),
             error = function(e)
               stop(sprintf("pending: transform input '%s' is not a resolvable FRED series", t),
                    call. = FALSE))
  })
  names(series) <- toks

  wide <- .align_locf(series, toks)
  val  <- tryCatch(eval(parse(text = formula), envir = as.list(wide[toks]), enclos = baseenv()),
                   error = function(e)
                     stop("pending: transform formula could not be evaluated", call. = FALSE))

  tibble::tibble(date = wide$date, value = as.numeric(val)) |>
    dplyr::filter(!is.na(value), date >= as.Date(start)) |>
    dplyr::arrange(date)
}
