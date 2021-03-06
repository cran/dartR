% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.read.dart.r
\name{utils.read.dart}
\alias{utils.read.dart}
\title{Import DarT data to R}
\usage{
utils.read.dart(
  filename,
  nas = "-",
  topskip = NULL,
  lastmetric = "RepAvg",
  verbose = 2
)
}
\arguments{
\item{filename}{path to file (csv file only currently)}

\item{nas}{a character specifying NAs (default is "-")}

\item{topskip}{a number specifying the number of rows to be skipped. If not provided the number of rows to be skipped are "guessed" by the number of rows with "*" at the beginning.}

\item{lastmetric}{specifies the last non genetic column (Default is "RepAvg"). Be sure to check if that is true, otherwise the number of individuals will not match. You can also specify the last column by a number.}

\item{verbose}{-- verbosity: 0, silent or fatal errors; 1, begin and end; 2, progress log ; 3, progress and results summary; 5, full report [default 2]}
}
\value{
a list of length 5. #dart format (one or two rows) #individuals, #snps, #non genetic metrics, #genetic data (still two line format, rows=snps, columns=individuals)
}
\description{
Internal function called by gl.read.dart
}
