% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/gl2shp.R
\name{gl2shp}
\alias{gl2shp}
\title{Converts a genlight object to ESRI shapefiles or kml files}
\usage{
gl2shp(
  x,
  type = "shp",
  proj4 = "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs",
  outfile = "gl",
  outpath = tempdir(),
  verbose = NULL
)
}
\arguments{
\item{x}{Name of the genlight object containing the SNP data and location
data, lat longs [required].}

\item{type}{Type of output 'kml' or 'shp' [default 'shp'].}

\item{proj4}{Proj4string of data set (see spatialreference.org for
projections) [default WGS84].}

\item{outfile}{Name (path) of the output shape file [default 'gl']. shp
extension is added automatically.}

\item{outpath}{Path where to save the output file
[default tempdir(), mandated by CRAN]. Use outpath=getwd() or outpath='.'
when calling this function to direct output files to your working directory.}

\item{verbose}{Verbosity: 0, silent or fatal errors; 1, begin and end; 2,
progress log; 3, progress and results summary; 5, full report
[default 2 or as specified using gl.set.verbosity].}
}
\value{
returns a SpatVector file
}
\description{
This function exports coordinates in a genlight object to a point shape file
 (including also individual meta data if available).
Coordinates are provided under x@other$latlon and assumed to be in WGS84
coordinates, if not proj4 string is provided.
}
\examples{
out <- gl2shp(testset.gl)
}
\author{
Bernd Guber (Post to \url{https://groups.google.com/d/forum/dartr})
}
