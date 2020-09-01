#' Summary of base pair frequencies
#'
#' This script calculates the frequencies of the four bases, and the frequency of transitions and
#' transversions in a DArT genlight object.
#'
#' The script checks if trimmed sequences are included in the locus metadata, and if so, tallies up
#' the numbers of A,T,G and C bases. Only the reference state at the SNP locus is counted. Counts of transitions
#' and transversions assume that there is no directionality, that is C>T is the same as T>C, because
#' the reference state is arbitrary.
#' 
#' For presence/absence data (SilicoDArT), it is not possible to count transitions and tranversions or tv/ts ratio
#' because the SNP data is not available, only a single sequence tag.
#' 
#' @param x -- name of the genlight object containing the SNP or presence/absence data [required]
#' @param plot -- if TRUE, histograms of base composition are produced [default TRUE]
#' @param verbose -- verbosity: 0, silent or fatal errors; 1, begin and end; 2, progress log ; 3, progress and results summary; 5, full report [default 2 or as specified using gl.set.verbosity]
#' @return returns a matrix containing the percent frequencies of each base (A,C,T,G) and the transition and transversion frequencies.
#' @return returns a named vector of base frequencies and the transversion and transitions. I also returns the plot as an ggplot object, which can be further customised. See example.
#' @export
#' @import stringr
#' @importFrom gridExtra grid.arrange
#' @author Arthur Georges (Post to \url{https://groups.google.com/d/forum/dartr})
#' @examples
#' # SNP data
#'   out <- gl.report.bases(testset.gl)
#'   out$freq
#'   out$plotbases
#'   out$plottvts
#' # Tag P/A data
#'   out <- gl.report.bases(testset.gs)
#'   out

gl.report.bases <- function(x, plot=TRUE, verbose = NULL) {

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
    stop("  Fatal Error: genlight object required!\n")
  }
  
    if (all(x@ploidy == 1)){
      cat("  Processing Presence/Absence (SilicoDArT) data\n")
      datatype <- "SilicoDArT"
    } else if (all(x@ploidy == 2)){
      cat("  Processing a SNP dataset\n")
      datatype <- "SNP"
    } else {
      stop ("Fatal Error: Ploidy must be universally 1 (fragment P/A data) or 2 (SNP data)")
    }

# FUNCTION SPECIFIC ERROR CHECKING

    if(!any(names(x@other$loc.metrics) == "TrimmedSequence")) {
      stop("  Fatal Error: Dataset does not include variable TrimmedSequence!\n")
    }

# DO THE JOB
p1 <- p2 <- NULL #initialise plots in case they are not defined  
# Count up the number of bases, and the number of each of ATGC, and other
  if (verbose >= 2){
    cat("  Counting the bases\n")
  }
  A <- sum(str_count(x@other$loc.metrics$TrimmedSequence, "A"))
  G <- sum(str_count(x@other$loc.metrics$TrimmedSequence, "G"))
  C <- sum(str_count(x@other$loc.metrics$TrimmedSequence, "C"))
  T <- sum(str_count(x@other$loc.metrics$TrimmedSequence, "T"))
  total <- sum(str_length(x@other$loc.metrics$TrimmedSequence))
  total.ATGC <- sum(A,G,C,T)
  if (verbose >= 2){
  if (total != total.ATGC) {
    cat("  Warning: Codes other than A, T, G and C present\n")
  }
  }  
  other <- total - total.ATGC
  other <- other*100/total
  A <- A*100/total
  G <- G*100/total
  T <- T*100/total
  C <- C*100/total
  

# Calculate the fragment lengths  
  mn <- mean(str_length(x@other$loc.metrics$TrimmedSequence))
  mx <- max(str_length(x@other$loc.metrics$TrimmedSequence))
  mi <- min(str_length(x@other$loc.metrics$TrimmedSequence))
  if(datatype=="SNP"){
# Extract the SNPs  
  matrix <- str_split_fixed(x@other$loc.metrics$SNP,":",2)
  state.change <- matrix[,2]

  if (verbose >= 2){
    cat("  Counting Transitions and Transversions\n")
  }  
# Sum the transitions and transversions  
  tv <- sum(str_count(state.change, "A>C")) +
    sum(str_count(state.change, "C>A")) +
    sum(str_count(state.change, "G>T")) +
    sum(str_count(state.change, "T>G")) +
    sum(str_count(state.change, "A>T")) +
    sum(str_count(state.change, "T>A")) +
    sum(str_count(state.change, "G>C")) +
    sum(str_count(state.change, "C>G"))
  
  ts <- sum(str_count(state.change, "A>G")) +
    sum(str_count(state.change, "G>A")) +
    sum(str_count(state.change, "C>T")) +
    sum(str_count(state.change, "T>C"))
  
  if (verbose >= 2){
  if (ts+tv != length(x@other$loc.metrics$TrimmedSequence)) {
    cat("  Warning: Sum of transitions plus transversions does not equal number of loci.\n")
  }
  }  
  ts <- ts*100/length(x@other$loc.metrics$TrimmedSequence)
  tv <- tv*100/length(x@other$loc.metrics$TrimmedSequence)
  ratio <- ts/tv
}

# Report
  cat(paste("  Average trimmed sequence length:",round(mn,digits=1),"(",mi,"to",mx,")"),"\n")
  cat(paste("  Total number of trimmed sequences:",length(x@other$loc.metrics$TrimmedSequence)),"\n")
  cat("  Base frequencies (%)\n")
  cat(paste("    A:",round(A,2)),"\n")
  cat(paste("    G:",round(G,2)),"\n")
  cat(paste("    T:",round(T,2)),"\n")
  cat(paste("    C:",round(C,2)),"\n\n")
  if (datatype=="SilicoDArT"){
    if(verbose >= 2){
      cat("  Tag P/A data (SilicoDArT), transition/transversions cannot be calculated\n")
    }
    tv <- NA
    ts <- NA
  } else {
    cat(paste("  Transitions  :",round(ts,2),"\n"))
    cat(paste("  Transversions:",round(tv,2),"\n"))
    cat(paste("  tv/ts ratio:", round(ratio,4),"\n\n"))
  }
  gg<- NULL
  if (plot) {
    if (datatype=="SNP"){
      title <- paste0("SNP: Base Frequencies")
    } else {
      title <- paste0("Tag P/A: Base Frequencies")
    }  
    bases <- c("A","C","T","G")
    freq <- round(c(A,C,T,G),1)
    df <- data.frame(bases=bases,freq=freq)
    p1 <- ggplot(data=df,aes(x=bases, y=freq)) +
            geom_bar(stat="identity", fill="steelblue") +
            xlab("Bases") + ylab("Frequency") +
            ggtitle(title)
    #p1
    if(datatype=="SNP"){
      bases <- c("Ts","Tv")
      freq <- round(c(ts,tv),1)
      df2 <- data.frame(bases=bases,freq=freq)
      p2 <- ggplot(data=df2,aes(x=bases, y=freq)) +
          geom_bar(stat="identity", fill="steelblue") +
          xlab("Mutation Type") + ylab("Frequency") +
          ggtitle(paste("SNP: Ts/Tv Rates [ratio =",round(ratio,2),"]"))
      #p2
      grid.arrange(p1, p2)
    } else {
      show(p1)
    }  
  }  
  
# Create return matrix
  if (verbose >= 2){
    cat("  Creating an output vector to return\n")
  }
  
  out <- c(round(A,2),round(G,2),round(T,2),round(C,2),round(tv,2),round(ts,2))
  names(out) <- c("A","G","T","C","tv","ts")
 
  #colnames(matrix) <- c("Base","Pcent")
  
# FLAG SCRIPT END

  if (verbose >= 1) {
    cat("Completed:",funname,"\n")
  }
  
  return(list(freq=out, plotbases=p1, plottstv=p2))

}
