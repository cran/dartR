% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/gl.report.taglength.r
\name{gl.report.taglength}
\alias{gl.report.taglength}
\title{Report summary of sequence tag length across loci in a genlight {adegenet} object}
\usage{
gl.report.taglength(x, boxplot = "adjusted", range = 1.5, verbose = NULL)
}
\arguments{
\item{x}{-- name of the genlight object containing the SNP data [required]}

\item{boxplot}{-- if 'standard', plots a standard box and whisker plot; if 'adjusted',
plots a boxplot adjusted for skewed distributions [default 'adjusted']}

\item{range}{-- specifies the range for delimiting outliers [default = 1.5 interquartile ranges]}

\item{verbose}{-- verbosity: 0, silent or fatal errors; 1, begin and end; 2, progress log ; 3, progress and results summary; 5, full report [default 2 or as specified using gl.set.verbosity]}
}
\value{
-- dataframe with loci that are outliers
}
\description{
SNP datasets generated by DArT typically have sequence tag lengths ranging from 20 to 69 base pairs.
}
\details{
The minimum, maximum and mean of tag length are provided. Output also is a histogram of tag length, accompanied by a box and 
whisker plot presented either in standard (boxplot="standard") or adjusted for skewness (boxplot=adjusted). 

Refer to Tukey (1977, Exploratory Data Analysis. Addison-Wesley) for standard
Box and Whisker Plots and Hubert & Vandervieren (2008), An Adjusted Boxplot for Skewed
Distributions, Computational Statistics & Data Analysis 52:5186-5201) for adjusted
Box and Whisker Plots.
}
\examples{
out <- gl.report.taglength(testset.gl)
}
\author{
Arthur Georges (Post to \url{https://groups.google.com/d/forum/dartr})
}
