#' Filter loci or specimens in a genlight \{adegenet\} object based on call rate
#'
#' SNP datasets generated by DArT have missing values primarily arising from failure to call a SNP because of a mutation
#' at one or both of the the restriction enzyme recognition sites. This script reports the number of missing values for each
#' of several percentiles. The script gl.filter.callrate() will filter out the loci with call rates below a specified threshold.
#' 
#' Tag Presence/Absence datasets (SilicoDArT) have missing values where it is not possible to determine reliably if there the
#' sequence tag can be called at a particular locus.
#' 
#' method = 'ind': Because this filter operates on call rate, this function recalculates Call Rate, if necessary, before filtering.
#' If individuals are removed using method='ind', then the call rate stored in the genlight object is, optionally, recalcuated after filtering.
#' 
#' recursive=TRUE: Note that when filtering individuals on call rate, the initial call rate is calculated and compared against the threshold. After filtering, 
#' if mono.rm=TRUE, the removal of monomorphic loci will alter the call rates. Some individuals with a call rate initially greater than 
#' the nominated threshold, and so retained, may come to have a call rate lower than the threshold. If this is a problem, repeated iterations 
#' of this function will resolve the issue. This is done by setting mono.rm=TRUE and recursive=TRUE, or it can be done manually.
#' 
#' @param  x name of the genlight object containing the SNP data, or the genind object containing the SilocoDArT data [required]
#' @param method -- "loc" to specify that loci are to be filtered, "ind" to specify that specimens are to be filtered, "pop"
#' to remove loci that fail to meet the specified threshold in any one population [default "loc"]
#' @param threshold -- threshold value below which loci will be removed [default 0.95]
#' @param plot specify if histograms of call rate, before and after, are to be produced [default TRUE]
#' @param bins -- number of bins to display in histograms [default 25]
#' @param mono.rm -- Remove monomorphic loci after analysis is complete [default FALSE]
#' @param recalc -- Recalculate the locus metadata statistics if any individuals are deleted in the filtering [default FALSE]
#' @param recursive -- Repeatedly filter individuals on call rate, each time removing monomorphic loci. Only applies if method="ind" and mono.rm=TRUE [default FALSE]
#' @param verbose -- verbosity: 0, silent or fatal errors; 1, begin and end; 2, progress log ; 3, progress and results summary; 5, full report [default 2, unless specified using gl.set.verbosity]
#' @return The reduced genlight or genind object, plus a summary
#' @export
#' @author Arthur Georges and Bernd Gruber (Post to \url{https://groups.google.com/d/forum/dartr})
#' @examples
#' # SNP data
#'   result <- gl.filter.callrate(testset.gl, method="loc", threshold=0.95, verbose=3)
#'   result <- gl.filter.callrate(testset.gl, method="ind", threshold=0.8, verbose=3)
#' # Tag P/A data
#'   result <- gl.filter.callrate(testset.gs, method="loc", threshold=0.95, verbose=3)
#'   result <- gl.filter.callrate(testset.gs, method="ind", threshold=0.8, verbose=3)

 gl.filter.callrate <- function(x, method="loc", threshold=0.95, mono.rm=FALSE, recalc=FALSE, recursive=FALSE, plot=TRUE, bins=25, verbose=NULL) {
  
# TRAP COMMAND, SET VERSION
   
   funname <- match.call()[[1]]
   build <- "Jacob"
   hold <- x
   
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
    cat("  Fatal Error: genlight object required!\n"); stop("Execution terminated\n")
  }
  
  if (verbose >= 2){
    if (all(x@ploidy == 1)){
      cat("  Processing Presence/Absence (SilicoDArT) data\n")
    } else if (all(x@ploidy == 2)){
      cat("  Processing a SNP dataset\n")
    } else {
      stop("Fatal Error: Ploidy must be universally 1 (fragment P/A data) or 2 (SNP data)")
    }
  }

  # Check monomorphs have been removed up to date
  if (x@other$loc.metrics.flags$monomorphs == FALSE){
    if (verbose >= 2){
      cat("  Warning: Dataset contains monomorphic loci which will be included in the Call Rate calculations for the filtering\n")
    }  
  }
  
  # Check call rate up to date
    if (x@other$loc.metrics.flags$CallRate == FALSE){
      if (verbose >= 2){
        cat("  Recalculating Call Rate\n")
      }  
        x <- utils.recalc.callrate(x,verbose=0)
    }
   
  # Suppress plotting on verbose == 0
   if(verbose==0){plot=FALSE}
  
# FUNCTION SPECIFIC ERROR CHECKING

   if (method != "ind" & method != "loc" & method != "pop") {
     cat("    Warning: method must be either \"loc\" or \"ind\" or \"pop\", set to \"loc\" \n")
     method <- "loc"
   }

   if (threshold < 0 | threshold > 1){
     cat("    Warning: threshold must be an integer between 0 and 1, set to 0.95\n")
     threshold <- 0.95
   }

# DO THE JOB
    
# FOR METHOD BASED ON LOCUS    

  if( method == "loc" ) {
    # Determine starting number of loci and individuals
    if (verbose >= 2) {cat("  Removing loci based on Call Rate, threshold =",threshold,"\n")}
    n0 <- nLoc(x)
    if (verbose >= 3) {cat("Initial no. of loci =", n0, "\n")}

    # Remove loci with NA count <= 1-threshold
      x2 <- x[ ,glNA(x,alleleAsUnit=FALSE)<=((1-threshold)*nInd(x))]
      x2@other$loc.metrics <- x@other$loc.metrics[glNA(x,alleleAsUnit=FALSE)<=((1-threshold)*nInd(x)),]
      if (verbose > 2) {cat ("  No. of loci deleted =", (n0-nLoc(x2)),"\n")}
      
    # Plot a histogram of Call Rate
      
      if(all(x@ploidy==2)){
        title <- "Call Rate by locus\n[pre-filtering, SNP dataset]"
      } else {
        title <- "Call Rate by locus\n[pre-filtering, Tag presence/absence dataset]"
      }  
      
      if (plot) {
        par(mfrow = c(2, 1),pty="m")
        hist(x@other$loc.metrics$CallRate, 
             main=title, 
             xlab="Call Rate", 
             border="blue", 
             col="red",
             xlim=c(min(x@other$loc.metrics$CallRate),1),
             breaks=bins
        )
        
       hist(x2@other$loc.metrics$CallRate, 
             main="[post-filtering]", 
             xlab="Call Rate", 
             border="blue", 
             col="red",
             xlim=c(min(x2@other$loc.metrics$CallRate),1),
             breaks=bins
        )
      }  
      if (mono.rm) {
        # Remove monomorphic loci  
        x2 <- gl.filter.monomorphs(x2,verbose=0)
      }
      if (recalc) {
        # Recalculate all metrics, including Call Rate (flags reset in utils scripts)
        x2 <- gl.recalc.metrics(x2, verbose=verbose)
      } else {
        # Reset the flags as FALSE for all metrics except Call Rate (dealt with elsewhere)
        x2@other$loc.metrics.flags$AvgPIC <- FALSE
        x2@other$loc.metrics.flags$OneRatioRef <- FALSE
        x2@other$loc.metrics.flags$OneRatioSnp <- FALSE
        x2@other$loc.metrics.flags$PICRef <- FALSE
        x2@other$loc.metrics.flags$PICSnp <- FALSE
        x2@other$loc.metrics.flags$maf <- FALSE
        x2@other$loc.metrics.flags$FreqHets <- FALSE
        x2@other$loc.metrics.flags$FreqHomRef <- FALSE
        x2@other$loc.metrics.flags$FreqHomSnp <- FALSE
      }
  }
  
# FOR METHOD BASED ON INDIVIDUALS    
      
  if ( method == "ind" ) {
    
    # Determine starting number of loci and individuals
    if (verbose > 1) {cat("  Removing individuals based on Call Rate, threshold =",threshold,"\n")}
      n0 <- nInd(x)
    if (verbose > 2) {cat("Initial no. of individuals =", n0, "\n")}
      
    # Calculate the individual call rate
      ind.call.rate <- 1 - rowSums(is.na(as.matrix(x)))/nLoc(x)
    # Store the initial call rate profile
      hold2 <- ind.call.rate
    # Check that there are some individuals left
      if (sum(ind.call.rate >= threshold) == 0) stop(paste("Maximum individual call rate =",max(ind.call.rate),". Nominated threshold of",threshold,"too stringent.\n No individuals remain.\n"))
      
      if (!recursive) {
    # Extract those individuals with a call rate greater or equal to the threshold
      x2 <- x[ind.call.rate >= threshold,]

    # for some reason that eludes me, this also (appropriately) filters the latlons and the covariates, but see above for locus filtering
        if (verbose > 2) {cat ("Filtering a genlight object\n  No. of individuals deleted =", (n0-nInd(x2)), "\nIndividuals retained =", nInd(x2),"\n")}
      
    # Report individuals that are excluded on call rate
      if (any(ind.call.rate <= threshold)) {
        x3 <- x[ind.call.rate <= threshold,]
        if (length(x3) > 0) {
          if (verbose >= 2) {
            cat("  No. of individuals deleted (CallRate <= ",threshold,":\n")
            cat(paste0(indNames(x3),"[",as.character(pop(x3)),"],"))
          }  

              if (mono.rm) {
              # Remove monomorphic loci  
                x2 <- gl.filter.monomorphs(x2,verbose=0)
              }
              if (recalc) {
              # Recalculate all metrics, including Call Rate (flags reset in utils scripts)
                x2 <- gl.recalc.metrics(x2, verbose=verbose)
              } else {
              # Reset the flags as FALSE for all metrics except Call Rate (dealt with elsewhere)
                x2@other$loc.metrics.flags$AvgPIC <- FALSE
                x2@other$loc.metrics.flags$OneRatioRef <- FALSE
                x2@other$loc.metrics.flags$OneRatioSnp <- FALSE
                x2@other$loc.metrics.flags$PICRef <- FALSE
                x2@other$loc.metrics.flags$PICSnp <- FALSE
                x2@other$loc.metrics.flags$maf <- FALSE
                x2@other$loc.metrics.flags$FreqHets <- FALSE
                x2@other$loc.metrics.flags$FreqHomRef <- FALSE
                x2@other$loc.metrics.flags$FreqHomSnp <- FALSE
              }
        }
      }  
    # Recalculate the callrate
      ind.call.rate <- 1 - rowSums(is.na(as.matrix(x2)))/nLoc(x2)
      # cat(min(ind.call.rate),"\n")
    
    } else { # If recursive
      
      # Recursively remove individuals
      cat("Recursively removing individuals with call rate <",threshold,", recalculating Call Rate after deleting monomorphs, and repeating until final Call Rate is >=",threshold,"\n")
      for (i in 1:10) {
        # Recalculate the callrate
        ind.call.rate <- 1 - rowSums(is.na(as.matrix(x)))/nLoc(x)
        # Extract those individuals with a call rate greater or equal to the threshold
        x2 <- x[ind.call.rate >= threshold,]
        if (nInd(x2) == nInd(x)) {break}
        
        # for some reason that eludes me, this also (appropriately) filters the latlons and the covariates, but see above for locus filtering
        if (verbose > 2) {cat ("ITERATION",i,"\n  No. of individuals deleted =", (n0-nInd(x2)), "\n  No. of individuals retained =", nInd(x2),"\n")}
        
        # Report individuals that are excluded on call rate
        if (any(ind.call.rate <= threshold)) {
          x3 <- x[ind.call.rate <= threshold,]
          if (length(x3) > 0) {
            if (verbose >= 3) {
              cat("  List of individuals deleted (CallRate <= ",threshold,":\n")
              cat(paste0(indNames(x3),"[",as.character(pop(x3)),"],"))
              cat("\n")
            }  
            if (mono.rm) {
              # Remove monomorphic loci  
              x2 <- gl.filter.monomorphs(x2,verbose=0)
            }
            if (recalc) {
              # Recalculate all metrics, including Call Rate (flags reset in utils scripts)
              x2 <- gl.recalc.metrics(x2, verbose=verbose)
            } else {
              # Reset the flags as FALSE for all metrics except Call Rate (dealt with elsewhere)
              x2@other$loc.metrics.flags$AvgPIC <- FALSE
              x2@other$loc.metrics.flags$OneRatioRef <- FALSE
              x2@other$loc.metrics.flags$OneRatioSnp <- FALSE
              x2@other$loc.metrics.flags$PICRef <- FALSE
              x2@other$loc.metrics.flags$PICSnp <- FALSE
              x2@other$loc.metrics.flags$maf <- FALSE
              x2@other$loc.metrics.flags$FreqHets <- FALSE
              x2@other$loc.metrics.flags$FreqHomRef <- FALSE
              x2@other$loc.metrics.flags$FreqHomSnp <- FALSE
            }
          }
        } 
        
        x <- x2

      } 
    }  
      
      # Plot a histogram of Call Rate

      if(all(x@ploidy==2)){
        title <- "Call Rate by individual\n[pre-filtering, SNP dataset]"
      } else {
        title <- "Call Rate by individual\n[pre-filtering, Tag presence/absence dataset]"
      }  
  
      if (plot) {
        par(mfrow = c(2, 1),pty="m")

        hist(hold2,
             main=title,
             xlab="Call Rate",
             border="blue",
             col="red",
             breaks=bins,
             xlim=c(min(hold2),1)
        )

       hist(ind.call.rate,
             main="[post-filtering]",
             xlab="Call Rate",
             border="blue",
             col="red",
             breaks=bins,
             xlim=c(min(ind.call.rate),1)
        )
      }
  }
  
# FOR METHOD BASE ON POPULATIONS
  
  if (method == 'pop'){
    
    if (verbose >= 2) {
      cat("  Removing loci based on Call Rate by population, Call rate must be equal to or exceed threshold =",threshold,"in all populations\n")
    }
    pops <- seppop(x) 
    ll <- lapply(pops, function(x) locNames(gl.filter.callrate(x, method = "loc", threshold = threshold, verbose = 0)))
    locall <- Reduce(intersect, ll)
    index <- which(locNames(x) %in% locall)
    x <- x[ , locall]
    x@other$loc.metrics <- x@other$loc.metrics[locall,]
    
    x <- utils.recalc.callrate(x)

    # Plot a histogram of Call Rate
    
    if(all(x@ploidy==2)){
      title <- "Call Rate by population\n[pre-filtering by population, SNP dataset]"
    } else {
      title <- "Call Rate by population\n[pre-filtering by population, Tag presence/absence dataset]"
    }  
    
    if (plot) {
      par(mfrow = c(1, 1),pty="m")
      hist(hold@other$loc.metrics$CallRate, 
           main=title, 
           xlab="Call Rate", 
           border="blue", 
           col="red",
           xlim=c(min(hold@other$loc.metrics$CallRate),1),
           breaks=bins
      )
      
      hist(x@other$loc.metrics$CallRate, 
           main="[post-filtering]", 
           xlab="Call Rate", 
           border="blue", 
           col="red",
           xlim=c(min(x@other$loc.metrics$CallRate),1),
           breaks=bins
      )
    }
    
    x2 <- x
    if (mono.rm) {
      # Remove monomorphic loci  
      x2 <- gl.filter.monomorphs(x2,verbose=0)
    }
    if (recalc) {
      # Recalculate all metrics, including Call Rate (flags reset in utils scripts)
      x2 <- gl.recalc.metrics(x2, verbose=verbose)
    } else {
      # Reset the flags as FALSE for all metrics except Call Rate (dealt with elsewhere)
      x2@other$loc.metrics.flags$AvgPIC <- FALSE
      x2@other$loc.metrics.flags$OneRatioRef <- FALSE
      x2@other$loc.metrics.flags$OneRatioSnp <- FALSE
      x2@other$loc.metrics.flags$PICRef <- FALSE
      x2@other$loc.metrics.flags$PICSnp <- FALSE
      x2@other$loc.metrics.flags$maf <- FALSE
      x2@other$loc.metrics.flags$FreqHets <- FALSE
      x2@other$loc.metrics.flags$FreqHomRef <- FALSE
      x2@other$loc.metrics.flags$FreqHomSnp <- FALSE
    }
  }

# REPORT A SUMMARY
   if (verbose > 2) {
     cat("Summary of filtered dataset\n")
     if (method=='pop'){
       cat(paste("  Call Rate in any one population >",threshold,"\n"))
     } else if (method=='ind'){
       cat(paste("  Call Rate for individuals >",threshold,"\n"))
     } else {
       cat(paste("  Call Rate for loci >",threshold,"\n"))
     }
     cat(paste("  Original No. of loci :",nLoc(hold),"\n"))
     cat(paste("  Original No. of individuals:", nInd(hold),"\n"))
     cat(paste("  No. of loci retained:",nLoc(x2),"\n"))
     cat(paste("  No. of individuals retained:", nInd(x2),"\n"))
     cat(paste("  No. of populations: ", length(levels(factor(pop(x2)))),"\n"))
   }
   
   if (verbose >= 2) {
     if (method == "ind"){
       if (!recalc) {
         cat("  Note: Locus metrics not recalculated\n")
       } else {
         cat("  Note: Locus metrics recalculated\n")
       }
       if (!mono.rm) {
         cat("  Note: Resultant monomorphic loci not deleted\n")
       } else{
         cat("  Note: Resultant monomorphic loci deleted\n")
         if (!recursive) {cat("  Warning: Some individuals with a Call Rate initially >=",threshold,"may have a final CallRate lower than",threshold,"when call rate is recalculated after removing resultant monomorphic loci\n")}
       }   
     }
   }

  # Recalculate Call Rate to be safe
      x <- utils.recalc.callrate(x,verbose=0)
      
# ADD TO HISTORY
      
   nh <- length(x2@other$history)
   x2@other$history[[nh + 1]] <- match.call()      
   
# FLAG SCRIPT END

  if (verbose > 0) {
    cat("Completed:",funname,"\n")
  }

   return(x2)
 }
