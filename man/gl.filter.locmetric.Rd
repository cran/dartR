% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/gl.filter.locmetric.r
\name{gl.filter.locmetric}
\alias{gl.filter.locmetric}
\title{Filter loci on the basis of numeric information stored in other$loc.metrics in a genlight \{adegenet\} object}
\usage{
gl.filter.locmetric(x, metric, upper, lower, keep = "within", verbose = 2)
}
\arguments{
\item{x}{-- name of the genlight object containing the SNP data [required]}

\item{metric}{-- name of the metric to be used for filtering [required]}

\item{upper}{-- filter upper threshold [required]}

\item{lower}{-- filter lower threshold  [required]}

\item{keep}{-- whether keep loci within of upper and lower thresholds or keep loci outside of upper and lower thresholds [within]}

\item{verbose}{-- verbosity: 0, silent or fatal errors; 1, begin and end; 2, progress log ; 3, progress and results summary; 5, full report [default 2, unless specified using gl.set.verbosity]}
}
\value{
The reduced genlight dataset
}
\description{
This script uses any field with numeric values stored in $other$loc.metrics to filter loci. The loci to keep can be within the upper and lower thresholds ("within") or outside of the upper and lower thresholds ("outside").
The fields that are included in dartR, and a short description, are found below. Optionally, the user can also set his/her own filter by adding a vector into $other$loc.metrics as shown in the example.
}
\details{
- SnpPosition - position (zero is position 1) in the sequence tag of the defined SNP variant base 
- CallRate - proportion of samples for which the genotype call is non-missing (that is, not '-' ) 
- OneRatioRef - proportion of samples for which the genotype score is 0 
- OneRatioSnp - proportion of samples for which the genotype score is 2 
- FreqHomRef - proportion of samples homozygous for the Reference allele 
- FreqHomSnp - proportion of samples homozygous for the Alternate (SNP) allele 
- FreqHets - proportion of samples which score as heterozygous, that is, scored as 1 
- PICRef - polymorphism information content (PIC) for the Reference allele 
- PICSnp - polymorphism information content (PIC) for the SNP 
- AvgPIC - average of the polymorphism information content (PIC) of the Reference and SNP alleles 
- AvgCountRef - sum of the tag read counts for all samples, divided by the number of samples with non-zero tag read counts, for the Reference allele row 
- AvgCountSnp - sum of the tag read counts for all samples, divided by the number of samples with non-zero tag read counts, for the Alternate (SNP) allele row 
- RepAvg - proportion of technical replicate assay pairs for which the marker score is consistent
}
\examples{
# adding dummy data
test <- testset.gl
test$other$loc.metrics$test <- 1:nLoc(test)
result <- gl.filter.locmetric(x=test, metric= "test", upper=255, 
lower=200, keep= "within", verbose=3)
}
\author{
Luis Mijangos (Post to \url{https://groups.google.com/d/forum/dartr})
}
