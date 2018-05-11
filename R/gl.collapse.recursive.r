#' Recursively collapse a distance matrix by amalgamating populations
#'
#' This script generates a fixed difference matrix from a genlight object \{adegenet\} and from it generates a population recode
#' table used to amalgamate populations with a fixed difference count less than or equal to a specified threshold, tpop. 
#' The script then repeats the process until there is no further amalgamation of populations.
#' 
#' The distance matricies are generated by gl.fixed.diff(), a recode table is generated using gl.collapse() and the resultant
#' recode table is applied to the genlight object using gl.recode.pop(). The process is repeated as many times as necessary to
#' yield a final table with no fixed differences less than or equal to the specified threshold, tpop. 
#' 
#' Optionally, if test=TRUE, the script will test the fixed differences between final OTUs for statistical significance,
#' using simulation, and then further amalgamate populations that for which there are no significant fixed differences at 
#' a specified level of significance (alpha). To avoid conflation of true fixed differences with false positives in the
#' simulations, it is necessary to decide a threshold value (delta) for extreme true allele frequencies that will be considered
#' fixed for practical purposes. That is, fixed differences in the sample set will be considered to be positives (not false positives)
#' if they arise from true allele frequencies of less than 1-delta in one or both populations.  The parameter
#' delta is typically set to be small (e.g. delta = 0.02).
#' 
#' The intermediate and final recode tables and distance matricies are stored to disk as csv files for use with other analyses. 
#' In particular, the recode tables can be edited to replace populaton labels with meaninful names and reapplied in sequence.
#'
#' @param x -- name of the genlight object from which the distance matricies are to be calculated [required]
#' @param prefix -- a string to be used as a prefix in generating the matricies of fixed differences (stored to disk) and the recode
#' tables (also stored to disk) [default "collapse"]
#' @param tloc -- threshold defining a fixed difference (e.g. 0.05 implies 95:5 vs 5:95 is fixed) [default 0]
#' @param tpop -- max number of fixed differences allowed in amalgamating populations [default 0]
#' @param test -- if TRUE, calculate p values for the observed fixed differences [default FALSE]
#' @param reps -- number of replications to undertake in the simulation to estimate probability of false positives [default 1000]
#' @param delta -- threshold value for the population minor allele frequency (MAF) from which resultant sample fixed differences are considered true positives [default 0.02]
#' @param alpha -- significance level for test of false positives [default 0.05]
#' @param v -- verbosity: 0, silent or fatal errors; 1, begin and end; 2, progress log ; 3, progress and results summary; 5, full report [default 2]
#' @return A list containing the gl object x and the following square matricies
#'         [[1]] $gl -- the input genlight object;
#'         [[2]] $fd -- raw fixed differences;
#'         [[3]] $pcfd -- percent fixed differences;
#'         [[4]] $nobs -- mean no. of individuals used in each comparison;
#'         [[5]] $nloc -- total number of loci used in each comparison;
#'         [[6]] $expobs -- if test=TRUE, the expected count of false positives for each comparison [by simulation], otherwise NAs
#'         [[7]] $prob -- if test=TRUE, the significance of the count of fixed differences [by simulation], otherwise NAs
#' @import reshape2
#' @export
#' @author Arthur Georges (glbugs@aerg.canberra.edu.au)
#' @examples
#' \donttest{
#' fd <- gl.collapse.recursive(testset.gl, prefix="testset", test=TRUE, tloc=0, tpop=2, v=2)
#' }

gl.collapse.recursive <- function(x, prefix="collapse", tloc=0, tpop=1, test=TRUE, alpha=0.05, delta=0.02, reps=1000, v=2) {
  
  if (v > 0) {
    cat("Starting gl.collapse.recursive: Recursively amalgamating populations with",tpop,"or fewer fixed differences\n")
  }
  tpop <- as.integer(tpop)
  if (tpop < 0 || tpop > nPop(x)) {
    cat("  Fatal Error: Parameter tpop must be between 0 and",nPop(x),"typically small (e.g. 3)\n"); stop("Execution terminated\n")
  }
  if (delta < 0 || delta > 1){
    cat("  Fatal Error: Parameter delta must be between 0 and 1, typically small (e.g. 0.05)\n"); stop("Execution terminated\n")
  }
  reps <- as.integer(reps)
  if (reps < 0 ) {
    cat("  Fatal Error: Parameter reps must be a positive integer\n"); stop("Execution terminated\n")
  }
  if (tloc < 0 || tloc > 1){
    cat("  Fatal Error: Parameter tloc must be between 0 and 1, typically small (e.g. 0.05)\n"); stop("Execution terminated\n")
  }
  v <- as.integer(v)
  if (v < 0 || v > 5){
    cat("  Fatal Error: Parameter v must be between 0 and 5\n"); stop("Execution terminated\n")
  }
  
# Set the iteration counter
  count <- 1
  
# Create the initial distance matrix
  fd <- gl.fixed.diff(x, test=FALSE, tloc=tloc, v=v)
  
# Store the length of the fd matrix
  fd.hold <- dim(fd$fd)[1]
  
# Construct a filename for the fd matrix
  d.name <- paste0(prefix,"_matrix_",count,".csv")
  
# Output the fd matrix for the first iteration to file
  if (v >= 2) {cat(paste("    Writing the initial fixed difference matrix to disk:",d.name,"\n"))}
  write.csv(fd$fd, d.name)

# Repeat until no change to the fixed difference matrix
  repeat {
    if( v > 1 ){cat(paste("\n  Iteration:", count,"\n"))}
    
    # Construct a filename for the pop.recode table
      recode.name <- paste0(prefix,"_recode_",count,".csv")
      
    # Collapse the matrix, write the new pop.recode table to file
      fdcoll <- gl.collapse(fd, recode.table=recode.name, tpop=tpop, tloc=tloc, v=v)
      x <- fdcoll$gl
      
      if (nPop(x) == 1)  {
        cat("WArning: All populations amalgamated to one on iteration",count,"\n")
        break
      }
      
    #  calculate the fixed difference matrix for the collapsed dataset
       fd <- gl.fixed.diff(x, tloc=tloc, test=FALSE, v=v)
      
    # If it is not different in dimensions from previous, break
      if (dim(fd$fd)[1] == fd.hold) {
        if(v > 1) {cat(paste("\n  No further amalgamation of populations on iteration",count,"\n"))}
        break
      }
      
    # Otherwise, construct a filename for the collapsed fd matrix
      count <- count + 1
      d.name <- paste0(prefix,"_matrix_",count,".csv")
      
    # Output the collapsed fixed difference matrix for this iteration to file
      if (v > 1) {cat(paste("    Writing the collapsed fixed difference matrix to disk:",d.name,"\n"))}
      write.csv(fd$fd, d.name)
      
    # Hold the dimensions of the new fixed difference matrix
      fd.hold <- dim(fd$fd)[1]
      
  } #end repeat
  
    if(test) {
  
    if( v > 1 ){cat(paste("  Computing probabilities of false positives\n"))}
    fd <- gl.fixed.diff(x, tloc=tloc, test=TRUE, delta=delta, reps=reps, v=v)

    }
  
  if (v > 2) {
    if (tloc == 0 ){
      cat("    Using absolute fixed differences\n")
    } else {  
      cat("    Using fixed differences defined with tolerance",tloc,"\n")
    }   
    cat("    Number of fixed differences allowing population amalgamation fd <=",tpop,"(",round((tpop*100/nLoc(x)),4),"%)\n")
    cat("    Resultant recode tables and fd matricies output with prefix",prefix,"\n")
  }
  
  l <- list(gl=x,fd=fd$fd,pcfd=fd$pcfd,nobs=fd$nobs,nloc=fd$nloc,expobs=fd$expobs,pval=fd$pval)

    # Return the matricies
  if (v > 1) {
    cat("Returning a list containing the following square matricies:\n",
        "         [[1]] $gl -- input genlight object;\n",
        "         [[2]] $fd -- raw fixed differences;\n",
        "         [[3]] $pcfd -- percent fixed differences;\n",
        "         [[4]] $nobs -- mean no. of individuals used in each comparison;\n",
        "         [[5]] $nloc -- total number of loci used in each comparison;\n",
        "         [[6]] $expobs -- if test=TRUE, the expected count of false positives for each comparison [by simulation]\n",
        "         [[7]] $prob -- if test=TRUE, the significance of the count of fixed differences [by simulation]\n")
  }
  
  if (v > 0) {
    cat("Completed gl.collapse.recursive\n\n")
  }
  
  return(l)
}
