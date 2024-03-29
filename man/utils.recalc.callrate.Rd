% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.recalc.callrate.r
\name{utils.recalc.callrate}
\alias{utils.recalc.callrate}
\title{A utility script to recalculate the callrate by locus after some populations
have been deleted}
\usage{
utils.recalc.callrate(x, verbose = NULL)
}
\arguments{
\item{x}{Name of the genlight object containing the SNP data [required].}

\item{verbose}{Verbosity: 0, silent or fatal errors; 1, begin and end; 2,
progress log ; 3, progress and results summary; 5, full report [default 2].}
}
\value{
The modified genlight object
}
\description{
SNP datasets generated by DArT have missing values primarily arising from
failure to call a SNP because of a mutation at one or both of the
restriction enzyme recognition sites. The locus metadata supplied by DArT has
 callrate included, but the call rate will change when some individuals are
 removed from the dataset. This script recalculates the callrate and places
 these recalculated values in the appropriate place in the genlight object.
 It sets the Call Rate flag to TRUE.
}
\examples{
#out <- utils.recalc.callrate(testset.gl)
}
\seealso{
\code{utils.recalc.metrics} for recalculating all metrics,
\code{utils.recalc.avgpic} for recalculating avgPIC,
\code{utils.recalc.freqhomref} for recalculating frequency of homozygous
reference, \code{utils.recalc.freqhomsnp} for recalculating frequency of
homozygous alternate, \code{utils.recalc.freqhet} for recalculating frequency
 of heterozygotes, \code{gl.recalc.maf} for recalculating minor allele
 frequency, \code{gl.recalc.rdepth} for recalculating average read depth
}
\author{
Custodian: Luis Mijangos (Post to
 \url{https://groups.google.com/d/forum/dartr})
}
