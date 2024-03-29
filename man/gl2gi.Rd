% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/gl2gi.r
\name{gl2gi}
\alias{gl2gi}
\title{Converts a genlight object to genind object}
\usage{
gl2gi(x, probar = FALSE, verbose = NULL)
}
\arguments{
\item{x}{A genlight object [required].}

\item{probar}{If TRUE, a progress bar will be displayed for long loops
[default TRUE].}

\item{verbose}{Verbosity: 0, silent or fatal errors; 1, begin and end; 2,
progress log; 3, progress and results summary; 5, full report
[default 2 or as specified using gl.set.verbosity].}
}
\value{
A genind object, with all slots filled.
}
\description{
Converts a genlight object to genind object
}
\details{
This function uses a faster version of df2genind (from the adegenet
 package)
}
\author{
Bernd Gruber (Post to \url{https://groups.google.com/d/forum/dartr})
}
