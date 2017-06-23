#' Filter duplicated loci in a genlight \{adegenet\} object 
#'
#' SNP datasets generated by DArT include fragments with more than one SNP and record them separately with the same CloneID (=AlleleID).
#' These multiple SNP loci within a fragment are likely to be linked, and so you may wish to remove duplicates.
#' This script filters out duplicate loci after ordering the genlight object on based on reproducibility, PIC in that order.
#'
#' @param gl -- name of the genlight object containing the SNP data, or the genind object containing the SilocoDArT data [required]
#' @return The reduced genlight or genind object, plus a summary
#' @export
#' @author Arthur Georges (glbugs@aerg.canberra.edu.au)
#' @examples
#' gl <- gl.filter.dups(testset.gl)

gl.filter.dups <- function(gl) {

  x <- gl
  
  if(class(x) == "genlight") {
    cat("Filtering a genlight object\n")
  } else {
    cat("Fatal Error: Specify either a genlight or a genind object\n")
    stop()
  }
  cat("Total number of SNP loci:",nLoc(x),"\n")
  
# Sort the genlight object on AlleleID (asc), RepAvg (desc), AvgPIC (desc) 
  x <- x[,order(x@other$loc.metrics$AlleleID,-x@other$loc.metrics$RepAvg,-x@other$loc.metrics$AvgPIC)]
# Extract the clone ID number
  a <- strsplit(as.character(x@other$loc.metrics$AlleleID),"\\|")
  b <- unlist(a)[ c(TRUE,FALSE,FALSE) ]
# Identify and remove duplicates from the genlight object, including the metadata
  x <- x[,duplicated(b)==FALSE]
  x@other$loc.metrics <- x@other$loc.metrics[duplicated(b)==FALSE,]
  
# Report duplicates from the genlight object

  cat("   Number of duplicates:",table(duplicated(b))[2],"\n")
  cat("   Number of loci after duplicates removed:",table(duplicated(b))[1],"\n")

  return(x)
  
}  




