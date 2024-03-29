% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/gl.merge.pop.r
\name{gl.merge.pop}
\alias{gl.merge.pop}
\title{Merges two or more populations in a genlight object into one population}
\usage{
gl.merge.pop(x, old = NULL, new = NULL, verbose = NULL)
}
\arguments{
\item{x}{Name of the genlight object containing SNP genotypes [required].}

\item{old}{A list of populations to be merged [required].}

\item{new}{Name of the new population [required].}

\item{verbose}{Verbosity: 0, silent or fatal errors; 1, begin and end; 2,
progress log; 3, progress and results summary; 5, full report
 [default 2 or as specified using gl.set.verbosity].}
}
\value{
A genlight object with the new population assignments.
}
\description{
Individuals are assigned to populations based on the specimen metadata data
file (csv) used with gl.read.dart().

This script assigns individuals from two nominated populations into a new
single population. It can also be used to rename populations.

The script returns a genlight object with the new population assignments.
}
\examples{
   gl <- gl.merge.pop(testset.gl, old=c('EmsubRopeMata','EmvicVictJasp'), new='Outgroup')
}
\author{
Custodian: Arthur Georges -- Post to
\url{https://groups.google.com/d/forum/dartr}
}
