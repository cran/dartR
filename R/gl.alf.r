#' Calculates allele frequency of the first and second allele for each loci #' 
#' A very simple function to report allele frequencies
#' @param gl -- a genlight object
#' @return a simple data.frame with alf1, alf2
#' @export
#' @rawNamespace import(adegenet, except = plot)
#' @author Bernd Gruber (bugs? Post to \url{https://groups.google.com/d/forum/dartr})
#' @examples 
#' #for the first 10 loci only
#' gl.alf(possums.gl[,1:10])
#' barplot(t(as.matrix(gl.alf(possums.gl[,1:10]))))

gl.alf <- function(gl)
{
  alf <- colMeans(as.matrix(gl), na.rm = T)/2
  out <- data.frame(alf1=1-alf, alf2=alf)
  return(out)
}
