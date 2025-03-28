% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.outflank.r
\name{utils.outflank}
\alias{utils.outflank}
\title{OutFLANK:  An Fst outlier approach by Mike Whitlock and Katie Lotterhos,
University of British Columbia.}
\usage{
utils.outflank(
  FstDataFrame,
  LeftTrimFraction = 0.05,
  RightTrimFraction = 0.05,
  Hmin = 0.1,
  NumberOfSamples,
  qthreshold = 0.05
)
}
\arguments{
\item{FstDataFrame}{A data frame that includes a row for each locus, with
columns as follows:
\itemize{
                  \item $LocusName: a character string that uniquely names
                  each locus.
                   \item $FST: Fst calculated for this locus. (Kept here to
                    report the unbased Fst of the results)
                   \item $T1: The numerator of the estimator for Fst
                   (necessary, with $T2, to calculate mean Fst)
                   \item $T2: The denominator of the estimator of Fst
                   \item $FSTNoCorr: Fst calculated for this locus without
                   sample size correction. (Used to find outliers)
                   \item $T1NoCorr: The numerator of the estimator for Fst
                   without sample size correction (necessary, with $T2, to
                   calculate mean Fst)
                   \item $T2NoCorr: The denominator of the estimator of Fst
                   without sample size correction
                   \item $He: The heterozygosity of the locus (used to screen
                   out low heterozygosity loci that have a different distribution)
                   }}

\item{LeftTrimFraction}{The proportion of loci that are trimmed from the
lower end of the range of Fst before the likelihood funciton is applied
[default 0.05].}

\item{RightTrimFraction}{The proportion of loci that are trimmed from the
upper end of the range of Fst before the likelihood funciton is applied
[default 0.05].}

\item{Hmin}{The minimum heterozygosity required before including calculations
from a locus [default 0.1].}

\item{NumberOfSamples}{The number of spatial locations included in the data
set.}

\item{qthreshold}{The desired false discovery rate threshold for calculating
q-values [default 0.05].}
}
\value{
The function returns a list with seven elements:
\itemize{
\item FSTbar: the mean FST inferred from loci not marked as outliers
\item FSTNoCorrbar: the mean FST (not corrected for sample size -gives an
upwardly biased estimate of FST)
\item dfInferred: the inferred number of degrees of freedom for the
chi-square distribution of neutral FST
\item numberLowFstOutliers: Number of loci flagged as having a significantly
low FST (not reliable)
\item numberHighFstOutliers: Number of loci identified as having
significantly high FST
\item results: a data frame with a row for each locus. This data frame
includes all the original columns in the
                   data set, and six new ones:
                   \itemize{
             \item $indexOrder (the original order of the input data set),
             \item $GoodH (Boolean variable which is TRUE if the expected
              heterozygosity is greater than the Hemin set by input),
             \item $OutlierFlag (TRUE if the method identifies the locus as
             an outlier, FALSE otherwise), and
             \item $q (the q-value for the test of neutrality for the locus)
             \item $pvalues (the p-value for the test of neutrality for the
             locus)
             \item $pvaluesRightTail the one-sided (right tail) p-value for
              a locus
             }
 }
}
\description{
This function is the original implementation of Outflank by Whitlock and
Lotterhos. dartR simply provides a convenient wrapper around their functions
and an easier install being an r package (for information please refer to
their github repository)
}
\details{
This method looks for Fst outliers from a list of Fst's for different loci.
It assumes that each locus has been genotyped in all populations with
approximately equal coverage.

OutFLANK estimates the distribution of Fst based on a trimmed sample of Fst's.
It assumes that the majority of loci in the center of the distribution are
neutral and infers the shape of the distribution of neutral Fst using a
trimmed set of loci. Loci with the highest and lowest Fst's are trimmed from
the data set before this inference, and the distribution of Fst df/(mean Fst)
is assumed to'follow a chi-square distribution. Based on this inferred
distribution, each locus is given a q-value based on its quantile in the
inferred null'distribution.

The main procedure is called OutFLANK -- see comments in that function
immediately below for input and output formats. The other functions here are
necessary and must be uploaded, but are not necessarily needed by the user
directly.

Steps:
}
\author{
Bernd Gruber (bugs? Post to
 \url{https://groups.google.com/d/forum/dartr}); original implementation of
  Whitlock & Lotterhos
}
