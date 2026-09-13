# utf8.R - make sure the session uses a UTF-8 character locale, so the project's
# UTF-8 source files and labels (dashes, bullets, sigma) read and render correctly.
# Rscript started with LANG unset runs in the plain C locale, where
# source(encoding = "UTF-8") can't convert those characters and stops reading the
# file early. Every entry point sources this file first; it is ASCII-only itself.

use_utf8_locale <- function() {
  if (isTRUE(l10n_info()[["UTF-8"]])) return(invisible(TRUE))
  for (loc in c("C.UTF-8", "en_US.UTF-8", "UTF-8")) {
    if (nzchar(suppressWarnings(Sys.setlocale("LC_CTYPE", loc)))) return(invisible(TRUE))
  }
  warning("No UTF-8 locale available; some labels may not display correctly.", call. = FALSE)
  invisible(FALSE)
}

use_utf8_locale()
