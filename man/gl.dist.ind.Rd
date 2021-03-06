% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/gl.dist.ind.r
\name{gl.dist.ind}
\alias{gl.dist.ind}
\title{Calculate a distance matrix for individuals defined in an \{adegenet\} genlight object}
\usage{
gl.dist.ind(x, method = NULL, plot = TRUE, verbose = NULL)
}
\arguments{
\item{x}{-- name of the genlight containing the SNP genotypes [required]}

\item{method}{-- Specify distance measure [SNP: Euclidean; P/A: Simple]}

\item{plot}{-- if TRUE, display a histogram and a boxplot of the genetic distances [TRUE]}

\item{verbose}{-- verbosity: 0, silent or fatal errors; 1, begin and end; 2, progress log ; 3, progress and results summary; 5, full report [default 2 or as specified using gl.set.verbosity]}
}
\value{
An object of class 'dist' giving distances between individuals
}
\description{
This script calculates various distances between individuals based on allele frequencies. The distances are
calculated by scripts in the {stats} or {vegan} libraries, with the exception of the pcfixed (percent fixed
differences) distance.
}
\details{
The distance measure for SNP data can be one of 

 Euclidean -- Euclidean distance as computed by dist() in {stat}
 locus.count -- number of loci for which individuals differ, as implemented by dist.gene() in {ape}
 allele.count -- number of allelic differences between two individuals, as implemented by diss.dist() in {poppr}
 relatedness -- genetic relatedness between individuals (G matrix), as implemented by A.mat() in {rrBLUP}
 
The distance measure for Tag P/A data (binary) can be one of
 
 Simple -- simple matching, both 1 or both 0 = 0; one 1 and the other 0 = 1. Presence and absence equally weighted.
 Jaccard -- ignores matching 0, both 1 = 0; one 1 and the other 0 = 1. Absences could be for different reasons.
 Dice -- both 0 = 0; both 1 = 2; one 1 and the other 0 = 1. Absences could be for different reasons. Sometimes called the Czekanowski or Sorensen distance.
 Phi -- binary analogue of the Pearson Correlation coefficient.
 
Refer to the documentation in the relevant packages listed above.
}
\examples{
gl.dist.pop(testset.gl, method="euclidean")
}
\author{
Arthur Georges (Post to \url{https://groups.google.com/d/forum/dartr})
}
