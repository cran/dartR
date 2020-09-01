#' Assign a individual metric as pop in a genlight \{adegenet\} object 
#'
#' Individuals are assigned to populations based on the individual/sample/specimen metrics file (csv)
#'  used with gl.read.dart(). 
#'
#' One might want to define the population structure in accordance with another classification, such as
#' using an individual metric (e.g. sex, male or female). This script discards the current population 
#' assignments and replaces them with new population assignments defined by a specified individual metric.
#' 
#' The script returns a genlight object with the new population assignments Note that the original population
#' assigments are lost.
#'
#' @param x -- name of the genlight object containing SNP genotypes [required]
#' @param as.pop -- specify the name of the individual metric to set as the pop variable. [required]
#' @param verbose -- verbosity: 0, silent or fatal errors; 1, begin and end; 2, progress log ; 3, progress and results summary; 5, full report [default 2 or as specified using gl.set.verbosity]
#' @return A genlight object with the reassigned populations
#' @export
#' @author Arthur Georges (Post to \url{https://groups.google.com/d/forum/dartr})
#' @examples
#' # SNP data
#'    popNames(testset.gl)
#'    gl <- gl.reassign.pop(testset.gl, as.pop='sex',verbose=3)
#'    popNames(gl)
#' # Tag P/A data
#'    popNames(testset.gs)
#'    gs <- gl.reassign.pop(testset.gs, as.pop='sex',verbose=3)
#'    popNames(gs)

gl.reassign.pop <- function (x, as.pop, verbose = NULL) {
  
# TRAP COMMAND, SET VERSION
  
  funname <- match.call()[[1]]
  build <- "Jacob"
  
# SET VERBOSITY
  
  if (is.null(verbose)){ 
    if(!is.null(x@other$verbose)){ 
      verbose <- x@other$verbose
    } else { 
      verbose <- 2
    }
  } 
  
  if (verbose < 0 | verbose > 5){
    cat(paste("  Warning: Parameter 'verbose' must be an integer between 0 [silent] and 5 [full report], set to 2\n"))
    verbose <- 2
  }
  
# FLAG SCRIPT START
  
  if (verbose >= 1){
    if(verbose==5){
      cat("Starting",funname,"[ Build =",build,"]\n")
    } else {
      cat("Starting",funname,"\n")
    }
  }
  
# STANDARD ERROR CHECKING
  
  if(class(x)!="genlight") {
    stop("Fatal Error: genlight object required!\n")
  }
  
  if (all(x@ploidy == 1)){
    if (verbose >= 2){cat("  Processing  Presence/Absence (SilicoDArT) data\n")}
  } else if (all(x@ploidy == 2)){
    if (verbose >= 2){cat("  Processing a SNP dataset\n")}
  } else {
    stop("Fatal Error: Ploidy must be universally 1 (fragment P/A data) or 2 (SNP data)")
  }  
  
# SCRIPT SPECIFIC ERROR CHECKING
  
  if (!(as.pop %in% names(x@other$ind.metrics))) {
    stop("  Fatal Error: Specified individual metric", as.pop, "not present in the dataset\n")
  }
  
# DO THE JOB
  
  pop(x) <- as.matrix(x@other$ind.metrics[as.pop])
  if (verbose >= 2) {
    cat("  Setting population assignments to individual metric", as.pop,"\n")
  }
  
  if (verbose >= 3) {
      cat("  Summary of recoded dataset\n")
      cat(paste("    No. of loci:", nLoc(x), "\n"))
      cat(paste("    No. of individuals:", nInd(x), "\n"))
      cat(paste("    No. of populations: ", nPop(x), "\n"))
  }

# ADD TO HISTORY
  nh <- length(x@other$history)
  x@other$history[[nh + 1]] <- match.call() 
  
# FLAG SCRIPT END
  
  if (verbose >= 1) {
    cat("Completed:", funname, "\n")
  }
  
  return(x)
}