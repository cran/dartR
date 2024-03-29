% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/gl.amova.r
\name{gl.amova}
\alias{gl.amova}
\title{Performs AMOVA using genlight data}
\usage{
gl.amova(x, distance = NULL, permutations = 100, verbose = NULL)
}
\arguments{
\item{x}{Name of the genlight containing the SNP genotypes, with
population information [required].}

\item{distance}{Distance matrix between individuals (if not provided NeisD
from StAMPP::stamppNeisD is calculated) [default NULL].}

\item{permutations}{Number of permutations to perform for hypothesis
testing [default 100]. Please note should be set to 1000 for analysis.}

\item{verbose}{Verbosity: 0, silent or fatal errors; 1, begin and end; 2,
progress log ; 3, progress and results summary; 5, full report
[default 2, unless specified using gl.set.verbosity].}
}
\value{
An object of class 'amova' which is a list with a table of sums of
square deviations (SSD), mean square deviations (MSD), and the number of
degrees of freedom, and a vector of variance components.
}
\description{
This script performs an AMOVA based on the genetic distance matrix from
stamppNeisD() [package StAMPP] using the amova() function from the package
PEGAS for exploring within and between population variation. For detailed
information use their help pages: ?pegas::amova, ?StAMPP::stamppAmova. Be
aware due to a conflict of the amova functions from various packages I had
to 'hack' StAMPP::stamppAmova to avoid a namespace conflict.
}
\examples{
#permutations should be higher, here set to 1 because of speed
out <- gl.amova(bandicoot.gl, permutations=1)

}
\author{
Bernd Gruber (bugs? Post to 
\url{https://groups.google.com/d/forum/dartr})
}
