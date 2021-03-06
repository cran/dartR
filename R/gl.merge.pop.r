#' Merge two or more populations in a genelight \{adegenet\} object into one population
#'
#' Individuals are assigned to populations based on the specimen metadata data file (csv) used with gl.read.dart(). 
#'
#' This script assigns individuals from two nominated populations into a new single population. It can also be used
#' to rename populations.
#' 
#' The script returns a genlight object with the new population assignments.
#'
#' @param x -- name of the genlight object containing SNP genotypes [required]
#' @param old -- a list of populations to be merged [required]
#' @param new -- name of the new population [required]
#' @param verbose -- verbosity: 0, silent or fatal errors; 1, begin and end; 2, progress log ; 3, progress and results summary; 5, full report [default 2 or as specified using gl.set.verbosity]
#' @return A genlight object with the new population assignments
#' @export
#' @author Arthur Georges (Post to \url{https://groups.google.com/d/forum/dartr})
#' @examples
#'    gl <- gl.merge.pop(testset.gl, old=c("EmsubRopeMata","EmvicVictJasp"), new="Outgroup")

gl.merge.pop <- function(x, old=NULL, new=NULL, verbose=NULL) {

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
  
  if (verbose >= 1) {
    if (length(old) == 1) {
      cat("Renaming a population\n")
    } else if (length(old) > 1) {
      cat("Merging a list of populations into one\n")
    } else {
      stop("Fatal Error: At least one old population label must be provided\n")
    }
  }
  
# SCRIPT SPECIFIC ERROR TESTING
  
  if (is.null(new)) {
    stop("Fatal Error: A new population label must be specified\n")
  }
  if(class(x)!="genlight") {
    stop("Fatal Error: genlight object required for gl.keep.pop.r!\n")
  }
  if (verbose >= 2) {
    if (length(old) == 1) {
      cat("  Renaming",old,"as",new,"\n")
    } else {
      cat("  Merging",old,"into",new,"\n")
    } 
  }

# DO THE JOB
  
  # Merge or rename
  
  for (i in 1:length(old)) {
    levels(pop(x))[levels(pop(x))==old[i]] <- new
  }

# ADD TO HISTORY
  nh <- length(x@other$history)
  x@other$history[[nh + 1]] <- match.call()
  
# FLAG SCRIPT END
  
  if (verbose >= 1) {
    cat("Completed:",funname,"\n")
  }
    
    return(x)
}

