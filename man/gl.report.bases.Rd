% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/gl.report.bases.r
\name{gl.report.bases}
\alias{gl.report.bases}
\title{Summary of base pair frequencies}
\usage{
gl.report.bases(x, plot = TRUE, verbose = NULL)
}
\arguments{
\item{x}{-- name of the genlight object containing the SNP or presence/absence data [required]}

\item{plot}{-- if TRUE, histograms of base composition are produced [default TRUE]}

\item{verbose}{-- verbosity: 0, silent or fatal errors; 1, begin and end; 2, progress log ; 3, progress and results summary; 5, full report [default 2 or as specified using gl.set.verbosity]}
}
\value{
returns a matrix containing the percent frequencies of each base (A,C,T,G) and the transition and transversion frequencies.

returns a named vector of base frequencies and the transversion and transitions. I also returns the plot as an ggplot object, which can be further customised. See example.
}
\description{
This script calculates the frequencies of the four bases, and the frequency of transitions and
transversions in a DArT genlight object.
}
\details{
The script checks if trimmed sequences are included in the locus metadata, and if so, tallies up
the numbers of A,T,G and C bases. Only the reference state at the SNP locus is counted. Counts of transitions
and transversions assume that there is no directionality, that is C>T is the same as T>C, because
the reference state is arbitrary.

For presence/absence data (SilicoDArT), it is not possible to count transitions and tranversions or tv/ts ratio
because the SNP data is not available, only a single sequence tag.
}
\examples{
# SNP data
  out <- gl.report.bases(testset.gl)
  out$freq
  out$plotbases
  out$plottvts
# Tag P/A data
  out <- gl.report.bases(testset.gs)
  out
}
\author{
Arthur Georges (Post to \url{https://groups.google.com/d/forum/dartr})
}
