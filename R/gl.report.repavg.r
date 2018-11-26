#' Report summary of RepAvg, reproducibility averaged over both alleles for each locus in a genlight {adegenet} object
#'
#' SNP datasets generated by DArT have in index, RepAvg, generated by reproducing the data independently for 30% of loci.
#' RepAvg is the proportion of alleles that give a reproducible result, averaged over both alleles for each locus.
#'
#' @param gl -- name of the genlight object containing the SNP data [required]
#' @return -- the mean call rate
#' @export
#' @author Arthur Georges (bugs? Post to \url{https://groups.google.com/d/forum/dartr})
#' @examples
#' gl.report.repavg(testset.gl)


gl.report.repavg <- function(gl) {
x <- gl
  
  if(class(x) == "genlight") {
    cat("Reporting for a genlight object\n")
  } else {
    cat("Fatal Error: Specify a genlight object\n")
    stop()
  }
  cat("Note: RepAvg is a DArT statistic reporting reproducibility averaged across alleles for each locus. \n\n")
  

  cat("No. of loci =", nLoc(x), "\n\n")
  
  # Function to determine the loss of loci for a given filter cut-off
  s <- function(gl, percentile) {
    a <- sum(x@other$loc.metrics$RepAvg>=percentile)
    if (percentile == 1) {
      cat(paste0("  Loci with perfect reproducibility = ",a," [",round((a*100/nLoc(x)),digits=1),"%]\n"))
    } else {
      cat(paste0("  > ",percentile," = ",a," [",round((a*100/nLoc(x)),digits=1),"%]\n"))
    }
    return(a)
  }
  for (i in seq(1000,0,by=-5)) {
    b <- s(x,i/1000)
    if (b == nLoc(x)) {break}
  }
  #r <- round(mean(x@other$loc.metrics$RepAvg]), digits=2)

  return("Completed")

}


