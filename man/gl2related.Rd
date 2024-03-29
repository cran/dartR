% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/gl2related.r
\name{gl2related}
\alias{gl2related}
\title{Converts a genlight object to format suitable to be run with Coancestry}
\usage{
gl2related(
  x,
  outfile = "related.txt",
  outpath = tempdir(),
  save = TRUE,
  verbose = NULL
)
}
\arguments{
\item{x}{Name of the genlight object containing the SNP data [required].}

\item{outfile}{File name of the output file (including extension)
[default 'related.txt'].}

\item{outpath}{Path where to save the output file [default tempdir()].}

\item{save}{A switch if you want to save the file or not. This might be
useful for someone who wants to use the coancestry function to calculate
relatedness and not export to coancestry. See the example below
[default TRUE].}

\item{verbose}{Verbosity: 0, silent or fatal errors; 1, begin and end; 2,
progress log; 3, progress and results summary; 5, full report
[default 2, unless specified using gl.set.verbosity].}
}
\value{
A data.frame that can be used to run with the related package
}
\description{
The output txt file contains the SNP data and an additional column with the
names of the individual. The file then can be used and loaded into coancestry
or - if installed - run with the related package. Be aware the related
package was crashing in previous versions, but in general is using the same
code as coancestry and therefore should have identical results. Also running
coancestry with thousands of SNPs via the GUI seems to be not reliable and
therefore for comparisons between coancestry and related we suggest to use
the command line version of coancestry.
}
\examples{
gtd <- gl2related(bandicoot.gl[1:10,1:20], save=FALSE)
\dontrun{
##running with the related package
#install.packages('related', repos='http://R-Forge.R-project.org')
library(related)
coan <- coancestry(gtd, wang=1)
head(coan$relatedness)
##check ?coancestry for information how to use the function.
}
}
\references{
Jack Pew, Jinliang Wang, Paul Muir and Tim Frasier (2014).
related: related: an R package for analyzing pairwise relatedness
 data based on codominant molecular markers.
 R package version 0.8/r2.
  \url{https://R-Forge.R-project.org/projects/related/}
}
\author{
Bernd Gruber (bugs? Post to
\url{https://groups.google.com/d/forum/dartr})
}
