#' Filter loci that contain private (and fixed alleles) between two populations. 
#'
#' This script is meant to be used prior to \code{gl.nhybrids} to maximise the information content of the snps used to identify hybrids 
#' (currently newhybrids does allow only 200 SNPs). The idea is to use first all loci that have fixed alleles between the potential source 
#' populations and then "fill up" to 200 loci using loci that have private alleles between those. The functions filters for those loci (if 
#' invers is set to TRUE, the opposite is returned (all loci that are not fixed and have no private alleles - not sure why yet, but maybe useful.)
#' 
#' @param x -- name of the genlight object containing the SNP data [required]
#' @param pop1 -- name of the first parental population (in quotes) [required]
#' @param pop2 -- name of the second parental population (in quotes) [required]
#' @param invers -- switch to filter for all loci that have no private alleles and are not fixed [FALSE]
#' @param verbose -- verbosity: 0, silent or fatal errors; 1, begin and end; 2, progress log ; 3, progress and results summary; 5, full report [default 2, unless specified using gl.set.verbosity] 
#' @return The reduced genlight dataset, containing now only fixed and private alleles
#' @export
#' @author Bernd Gruber & Ella Kelly (University of Melbourne) (Post to \url{https://groups.google.com/d/forum/dartr})
#' @examples
#' result <- gl.filter.pa(testset.gl, pop1=pop(testset.gl)[1], pop2=pop(testset.gl)[2],verbose=3)

gl.filter.pa<-function(x, pop1, pop2, invers=FALSE, verbose=NULL){
  
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
    stop("Fatal Error: Private alleles can only be calculated for SNP data. Please provide a SNP dataset\n")
  } else if (all(x@ploidy == 2)){
    if (verbose >= 2){cat(paste("  Processing a SNP dataset\n"))}
  } else {
    stop("Fatal Error: Ploidy must be universally 1 (fragment P/A data) or 2 (SNP data)")
  }

# FUNCTION SPECIFIC ERROR CHECKING
  
# DO THE JOB
  
  pops <- seppop(x)
  p1 <- as.matrix(pops[[pop1]])
  p2 <- as.matrix(pops[[pop2]])
  p1alf <- colMeans(p1, na.rm = T)/2
  p2alf <- colMeans(p2, na.rm = T)/2
  priv1 <- c(names(p1alf)[p2alf == 0 & p1alf != 0], names(p1alf)[p2alf == 1 & p1alf != 1]) # private alleles for pop 1
  priv2 <-  c(names(p2alf)[p1alf == 0 & p2alf != 0], names(p2alf)[p1alf == 1 & p2alf != 1]) # private alleles for pop 2
  pfLoci<-unique(c(priv1, priv2)) # put all together
  index <- locNames(x) %in% pfLoci
  if (invers) index <- !index
  x <- x[, index]
  x@other$loc.metrics <- x@other$loc.metrics[index, ]
  
# ADD TO HISTORY
  nh <- length(x@other$history)
  x@other$history[[nh + 1]] <- match.call() 
  
# FLAG SCRIPT END
 
  if (verbose > 0) {
    cat("Completed:", funname, "\n")
  }

  return(x)
}
