% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/gl.read.dart.r
\name{gl.read.dart}
\alias{gl.read.dart}
\title{Import DarT data into R and conver it to a genlight object}
\usage{
gl.read.dart(
  filename,
  ind.metafile = NULL,
  recalc = FALSE,
  mono.rm = FALSE,
  nas = "-",
  topskip = NULL,
  lastmetric = "RepAvg",
  covfilename = NULL,
  probar = FALSE,
  verbose = NULL
)
}
\arguments{
\item{filename}{file containing the SNP data (csv file) [required]}

\item{ind.metafile}{file that contains additional information on individuals [required]}

\item{recalc}{force the recalculation of locus metrics, in case individuals have been manually deleted from the input csv file [FALSE]}

\item{mono.rm}{force the removal of monomorphic loci (including all NAs), in case individuals have been manually deleted from the input csv file [FALSE]}

\item{nas}{a character specifying NAs [nas = '-']}

\item{topskip}{a number specifying the number of rows to be skipped. If not provided the number of rows to be skipped are "guessed" by the number of rows with "*" at the beginning.}

\item{lastmetric}{specifies the last non genetic column (Default is "RepAvg"). Be sure to check if that is true, otherwise the number of individuals will not match. You can also specify the last column by a number.}

\item{covfilename}{use ind.metafile parameter [deprectiated, NULL]}

\item{probar}{show progress bar}

\item{verbose}{-- verbosity: 0, silent or fatal errors; 1, begin and end; 2, progress log ; 3, progress and results summary; 5, full report [default 2, or as set by gl.set.verbose()]}
}
\value{
a dart genlight object that contains individual metrics [if data were provided] and locus metrics [from a DArT report]. The dart genlight object can then be fed into a number of initial screening, export and export functions provided by the package. For some of the function it is necessary to have the metadata that was provided from DArT. Please check the vignette for more information. Additional information can also be found in the help documents for  \code{utils.read.dart}.
}
\description{
This function is a wrapper function that allows you to convert you dart file into a genlight object in one step. In previous versions you had to use read.dart and then dart2genlight. In case you have individual metadata for each individual/sample you can specify as before in the dart2genlight command the file that combines the data.
}
\examples{
{
dartfile <- system.file("extdata","testset_SNPs_2Row.csv", package="dartR")
metadata <- system.file("extdata","testset_metadata.csv", package="dartR")
gl <- gl.read.dart(dartfile, ind.metafile = metadata, probar=TRUE)
}
}
