% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/gl.select.colors.r
\name{gl.select.colors}
\alias{gl.select.colors}
\title{Selects colors from one of several palettes and output as a vector}
\usage{
gl.select.colors(
  x = NULL,
  library = NULL,
  palette = NULL,
  ncolors = NULL,
  select = NULL,
  verbose = NULL
)
}
\arguments{
\item{x}{Optionally, provide a gl object from which to determine the number
of populations [default NULL].}

\item{library}{Name of the color library to be used [default scales::hue_pl].}

\item{palette}{Name of the color palette to be pulled from the specified
library [default is library specific] .}

\item{ncolors}{number of colors to be displayed and returned [default 9].}

\item{select}{select the colors to retain in the output vector
[default NULL].}

\item{verbose}{-- verbosity: 0, silent or fatal errors; 1, begin and end; 2,
progress log; 3, progress and results summary; 5, full report
[default 2 or as specified using gl.set.verbosity].}
}
\value{
A vector with the required number of colors
}
\description{
This script draws upon a number of specified color libraries to extract a
vector of colors for plotting, where the script that follows has a color
parameter expecting a vector of colors.
}
\details{
The available color libraries and their palettes include:
\itemize{
\item library 'brewer' and the palettes available can be listed by
RColorBrewer::display.brewer.all() and RColorBrewer::brewer.pal.info.
\item library 'gr.palette' and the palettes available can be listed by
grDevices::palette.pals()
\item library 'r.hcl' and the palettes available can be listed by
grDevices::hcl.pals()
\item library 'baseR' and the palettes available are: 'rainbow','heat',
'topo.colors','terrain.colors','cm.colors'.
}
If the nominated palette is not specified, all the palettes will be listed a
nd a default palette will then be chosen.

The color palette will be displayed in the graphics window for the requested
number of colors (or 9 if not specified),and the vector of colors returned
for later use.

The select parameter can be used to select colors from the specified ncolors.
For example, select=c(1,1,3) will select color 1, 1 again and 3 to retain in
the final vector. This can be useful for fine-tuning color selection, and
matching colors and shapes.
}
\examples{
# SET UP DATASET
gl <- testset.gl
levels(pop(gl))<-c(rep('Coast',5),rep('Cooper',3),rep('Coast',5),
rep('MDB',8),rep('Coast',7),'Em.subglobosa','Em.victoriae')
# EXAMPLES -- SIMPLE
colors <- gl.select.colors()
colors <- gl.select.colors(library='brewer',palette='Spectral',ncolors=6)
colors <- gl.select.colors(library='baseR',palette='terrain.colors',ncolors=6)
colors <- gl.select.colors(library='baseR',palette='rainbow',ncolors=12)
colors <- gl.select.colors(library='gr.hcl',palette='RdBu',ncolors=12)
colors <- gl.select.colors(library='gr.palette',palette='Pastel 1',ncolors=6)
# EXAMPLES -- SELECTING colorS
colors <- gl.select.colors(library='baseR',palette='rainbow',ncolors=12,select=c(1,1,1,5,8))
# EXAMPLES -- CROSS-CHECKING WITH A GENLIGHT OBJECT
colors <- gl.select.colors(x=gl,library='baseR',palette='rainbow',ncolors=12,select=c(1,1,1,5,8))

}
\seealso{
\code{\link{gl.select.shapes}}

Other Exploration/visualisation functions: 
\code{\link{gl.pcoa.plot}()},
\code{\link{gl.select.shapes}()},
\code{\link{gl.smearplot}()}
}
\author{
Custodian: Arthur Georges -- Post to
\url{https://groups.google.com/d/forum/dartr}
}
\concept{Exploration/visualisation functions}
