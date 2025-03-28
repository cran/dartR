% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/gl.report.secondaries.r
\name{gl.report.secondaries}
\alias{gl.report.secondaries}
\title{Reports loci containing secondary SNPs in sequence tags and calculates
  number of invariant sites}
\usage{
gl.report.secondaries(
  x,
  nsim = 1000,
  taglength = 69,
  plot.out = TRUE,
  plot_theme = theme_dartR(),
  plot_colors = two_colors,
  save2tmp = FALSE,
  verbose = NULL
)
}
\arguments{
\item{x}{Name of the genlight object containing the SNP data [required].}

\item{nsim}{The number of simulations to estimate the mean of the Poisson
distribution [default 1000].}

\item{taglength}{Typical length of the sequence tags [default 69].}

\item{plot.out}{Specify if plot is to be produced [default TRUE].}

\item{plot_theme}{Theme for the plot. See Details for options [default
theme_dartR()].}

\item{plot_colors}{List of two color names for the borders and fill of the
plots [default two_colors].}

\item{save2tmp}{If TRUE, saves any ggplots and listings to the session
temporary directory (tempdir) [default FALSE].}

\item{verbose}{Verbosity: 0, silent or fatal errors; 1, begin and end; 2,
progress log; 3, progress and results summary; 5, full report
[default 2, unless specified using gl.set.verbosity].}
}
\value{
A data.frame with the list of parameter values
\itemize{
  \item n.total.tags Number of sequence tags in total
  \item n.SNPs.secondaries Number of secondary SNP loci that would be removed
  on filtering
  \item n.invariant.tags Estimated number of invariant sequence tags
  \item n.tags.secondaries Number of sequence tags with secondaries
  \item n.inv.gen Number of invariant sites in sequenced tags
  \item mean.len.tag Mean length of sequence tags
  \item n.invariant Total Number of invariant sites (including invariant
  sequence tags)
  \item k Lambda: mean of the Poisson distribution of number of SNPs in the
  sequence tags
}
}
\description{
SNP datasets generated by DArT include fragments with more than
  one SNP (that is, with secondaries). They are recorded separately with the
  same CloneID (=AlleleID). These multiple SNP loci within a fragment are
  likely to be linked, and so you may wish to remove secondaries.

  This function reports statistics associated with secondaries, and the
  consequences of filtering them out, and provides three plots. The first is
  a boxplot, the second is a barplot of the frequency of secondaries per
  sequence tag, and the third is the Poisson expectation for those
  frequencies including an estimate of the zero class (no. of sequence tags
  with no SNP scored).
}
\details{
The function \code{\link{gl.filter.secondaries}} will filter out the
  loci with secondaries retaining only one sequence tag.

  Heterozygosity as estimated by the function
  \code{\link{gl.report.heterozygosity}} is in a sense relative, because it
  is calculated against a background of only those loci that are polymorphic
  somewhere in the dataset. To allow intercompatibility across studies and
  species, any measure of heterozygosity needs to accommodate loci that are
  invariant (autosomal heterozygosity. See Schmidt et al 2021). However, the
  number of invariant loci are unknown given the SNPs are detected as single
  point mutational variants and invariant sequences are discarded, and
  because of the particular additional filtering pre-analysis. Modelling the
  counts of SNPs per sequence tag as a Poisson distribution in this script
  allows estimate of the zero class, that is, the number of invariant loci.
  This is reported, and the veracity of the estimate can be assessed by the
  correspondence of the observed frequencies against those under Poisson
  expectation in the associated graphs. The number of invariant loci can then
  be optionally provided to the function
  \code{\link{gl.report.heterozygosity}} via the parameter n.invariants.

  In case the calculations for the Poisson expectation of the number of
  invariant sequence tags fail to converge, try to rerun the analysis with a
  larger \code{nsim} values.

  This function now also calculates the number of invariant sites (i.e.
  nucleotides) of the sequence tags (if \code{TrimmedSequence} is present in
  \code{x$other$loc.metrics}) or estimate these by assuming that the average
  length of the sequence tags is 69 nucleotides. Based on the Poisson
  expectation of the number of invariant sequence tags, it also estimates the
  number of invariant sites for these to eventually provide an estimate of
  the total number of invariant sites.

 \strong{Note}, previous version of
  \code{dartR} would only return an estimate of the number of invariant
  sequence tags (not sites).

  Plots are saved to the session temporary directory (tempdir).

  Examples of other themes that can be used can be consulted in:
   \itemize{
  \item \url{https://ggplot2.tidyverse.org/reference/ggtheme.html} and \item
  \url{https://yutannihilation.github.io/allYourFigureAreBelongToUs/ggthemes/}
   }
}
\examples{
require("dartR.data")
test <- gl.filter.callrate(platypus.gl,threshold = 1)
n.inv <- gl.report.secondaries(test)
gl.report.heterozygosity(test, n.invariant = n.inv[7, 2])
}
\references{
Schmidt, T.L., Jasper, M.-E., Weeks, A.R., Hoffmann, A.A., 2021.
  Unbiased population heterozygosity estimates from genome-wide sequence
  data. Methods in Ecology and Evolution n/a.
}
\seealso{
\code{\link{gl.filter.secondaries}},\code{\link{gl.report.heterozygosity}},
\code{\link{utils.n.var.invariant}}

Other report functions: 
\code{\link{gl.report.bases}()},
\code{\link{gl.report.callrate}()},
\code{\link{gl.report.diversity}()},
\code{\link{gl.report.hamming}()},
\code{\link{gl.report.hwe}()},
\code{\link{gl.report.ld.map}()},
\code{\link{gl.report.locmetric}()},
\code{\link{gl.report.maf}()},
\code{\link{gl.report.monomorphs}()},
\code{\link{gl.report.overshoot}()},
\code{\link{gl.report.pa}()},
\code{\link{gl.report.parent.offspring}()},
\code{\link{gl.report.rdepth}()},
\code{\link{gl.report.replicates}()},
\code{\link{gl.report.reproducibility}()},
\code{\link{gl.report.sexlinked}()},
\code{\link{gl.report.taglength}()}
}
\author{
Custodian: Arthur Georges (Post to
  \url{https://groups.google.com/d/forum/dartr})
}
\concept{report functions}
