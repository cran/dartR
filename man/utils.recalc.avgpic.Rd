% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.recalc.avgpic.r
\name{utils.recalc.avgpic}
\alias{utils.recalc.avgpic}
\title{A utility script to recalculate the OneRatioRef, OneRatioSnp, PICRef, PICSnp,
 and AvgPIC by locus after some individuals or populations have been deleted.}
\usage{
utils.recalc.avgpic(x, verbose = NULL)
}
\arguments{
\item{x}{Name of the genlight object containing the SNP data [required].}

\item{verbose}{Verbosity: 0, silent or fatal errors; 1, begin and end; 2,
progress log; 3, progress and results summary; 5, full report [default 2].}
}
\value{
The modified genlight object.
}
\description{
The locus metadata supplied by DArT has OneRatioRef, OneRatioSnp, PICRef,
 PICSnp, and AvgPIC included, but the allelic composition will change when
 some individuals,or populations, are removed from the dataset and so the
 initial statistics will no longer apply. This script recalculates these
 statistics and places the recalculated values in the appropriate place in
 the genlight object.
}
\details{
If the locus metadata OneRatioRef|Snp, PICRef|Snp and/or AvgPIC do not exist,
 the script creates and populates them.
}
\examples{
#out <- utils.recalc.avgpic(testset.gl)
}
\seealso{
\code{utils.recalc.metrics} for recalculating all metrics,
\code{utils.recalc.callrate} for recalculating CallRate,
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
