% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dartR.r
\name{rbind.dartR}
\alias{rbind.dartR}
\title{adjust rbind for dartR}
\usage{
\method{rbind}{dartR}(...)
}
\arguments{
\item{...}{list of dartR objects}
}
\value{
A genlight object
}
\description{
rbind is a bit lazy and does not take care for the metadata (so data in the
other slot is lost). You can get most of the loci metadata back using
 gl.compliance.check.
}
\examples{
t1 <- platypus.gl
class(t1) <- "dartR"
t2 <- rbind(t1[1:5,],t1[6:10,])
}
