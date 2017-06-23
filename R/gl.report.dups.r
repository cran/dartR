#' Report duplicated loci in a genlight \{adegenet\} object 
#'
#' SNP datasets generated by DArT include fragments with more than one SNP and record them separately with the same CloneID (=AlleleID).
#' These multiple SNP loci within a fragment are likely to be linked, and so you may wish to remove duplicates.
#' This script reports duplicate loci.
#'
#' @param gl -- name of the genlight object containing the SNP data, or the genind object containing the SilocoDArT data [required]
#' @return 1
#' @export
#' @author Arthur Georges (glbugs@aerg.canberra.edu.au)
#' @examples
#' gl.report.dups(testset.gl)


gl.report.dups <- function(gl) {
x <- gl
  
  if(class(x) == "genlight") {
    cat("Reporting for a genlight object\n")
  } else {
    cat("Fatal Error: Specify either a genlight or a genind object\n")
    stop()
  }

# Extract the clone ID number
  a <- strsplit(as.character(x@other$loc.metrics$AlleleID),"\\|")
  b <- unlist(a)[ c(TRUE,FALSE,FALSE) ]
# Identify duplicates from the genlight object
  cat("Total number of SNP loci:",nLoc(x),"\n")
  if (is.na(table(duplicated(b))[2])) {
    cat("   Number of duplicates: 0 \n")
  } else {
    cat("   Number of duplicates:",table(duplicated(b))[2],"\n")
  }  
  cat("   Number of loci after duplicates removed:",table(duplicated(b))[1],"\n")

    return(1)
  
}  




