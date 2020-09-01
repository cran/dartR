#' Report summary of sequence tag length across loci in a genlight {adegenet} object
#'
#' SNP datasets generated by DArT typically have sequence tag lengths ranging from 20 to 69 base pairs.
#' 
#' The minimum, maximum and mean of tag length are provided. Output also is a histogram of tag length, accompanied by a box and 
#' whisker plot presented either in standard (boxplot="standard") or adjusted for skewness (boxplot=adjusted). 
#' 
#' Refer to Tukey (1977, Exploratory Data Analysis. Addison-Wesley) for standard
#' Box and Whisker Plots and Hubert & Vandervieren (2008), An Adjusted Boxplot for Skewed
#' Distributions, Computational Statistics & Data Analysis 52:5186-5201) for adjusted
#' Box and Whisker Plots.
#' 
#' @param x -- name of the genlight object containing the SNP data [required]
#' @param boxplot -- if 'standard', plots a standard box and whisker plot; if 'adjusted',
#' plots a boxplot adjusted for skewed distributions [default 'adjusted']
#' @param range -- specifies the range for delimiting outliers [default = 1.5 interquartile ranges]
#' @param verbose -- verbosity: 0, silent or fatal errors; 1, begin and end; 2, progress log ; 3, progress and results summary; 5, full report [default 2 or as specified using gl.set.verbosity]
#' @return -- dataframe with loci that are outliers
#' @importFrom graphics hist
#' @importFrom robustbase adjbox
#' @export
#' @author Arthur Georges (Post to \url{https://groups.google.com/d/forum/dartr})
#' @examples
#' out <- gl.report.taglength(testset.gl)

gl.report.taglength <- function(x, boxplot="adjusted", range=1.5, verbose=NULL) {

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
    cat("  Processing Presence/Absence (SilicoDArT) data\n")
  } else if (all(x@ploidy == 2)){
    cat("  Processing a SNP dataset\n")
  } else {
    stop("Fatal Error: Ploidy must be universally 1 (fragment P/A data) or 2 (SNP data)!\n")
  }
  
# FUNCTION SPECIFIC ERROR CHECKING
  
  if(length(x@other$loc.metrics$TrimmedSequence) != nLoc(x)) {
    stop("Fatal Error: Data must include Trimmed Sequences for each loci in a column called 'TrimmedSequence' in the @other$loc.metrics slot.\n")
  }
  if (boxplot != "standard" & boxplot != "adjusted") {
    cat("    Warning: method must be either \"standard\" or \"adjusted\", set to \"adjusted\" \n")
    boxplot <- "adjusted"
  }
  if (range < 0){
    cat("  Warning: Parameter 'range' must be a positive integer, set to 1.5 interquarile ranges\n")
    range <- 1.5
  }
  
# DO THE JOB

  tags <- x@other$loc.metrics$TrimmedSequence
  nchar.tags <- nchar(as.character(tags))

  cat("  No. of loci =", nLoc(x), "\n")
  cat("  No. of individuals =", nInd(x), "\n")
  cat("    Miniumum tag length: ",min(nchar.tags),"\n")
  cat("    Maximum tag length: ",max(nchar.tags),"\n")
  cat("    Mean tag length: ",round(mean(nchar.tags),1),"\n")

  # Determine the loss of loci for a given filter cut-off
  retained <- array(NA,21)
  pc.retained <- array(NA,21)
  filtered <- array(NA,21)
  pc.filtered <- array(NA,21)
  percentile <- array(NA,21)
  for (index in 1:21) {
    i <- (index - 1)/20
    i <- (i - 1)*(1-max(nchar.tags)) + 1
    percentile[index] <- i
    retained[index] <- length(nchar.tags[nchar.tags >= percentile[index]])
    pc.retained[index] <- round(retained[index]*100/nLoc(x),1)
    filtered[index] <- nLoc(x) - retained[index]
    pc.filtered[index] <- 100 - pc.retained[index]
  }
  df <- cbind(percentile,retained,pc.retained,filtered,pc.filtered)
  df <- data.frame(df)
  colnames(df) <- c("Threshold", "Retained", "Percent", "Filtered", "Percent")
  df <- df[order(-df$Threshold),]
  rownames(df) <- NULL
  #print(df)
  
  # Prepare for plotting
  # Save the prior settings for mfrow, oma, mai and pty, and reassign
  op <- par(mfrow = c(2, 1), oma=c(1,1,1,1), mai=c(0.5,0.5,0.5,0.5),pty="m")
  # Set margins for first plot
  par(mai=c(1,0.5,0.5,0.5))
  # Plot Box-Whisker plot
  if (boxplot == "standard"){
    whisker <- boxplot(nchar.tags, horizontal=TRUE, col='red', range=range, main = "Tag Length")
    if (length(whisker$out)==0){
      cat("    Standard boxplot, no adjustment for skewness\n")
    } else {
      outliers <- data.frame(Locus=as.character(x$loc.names[nchar.tags %in% whisker$out]),
                             TagLen=whisker$out
      )
      cat("    Standard boxplot, no adjustment for skewness\n")
    }
    
  } else {
    whisker <- robustbase::adjbox(nchar.tags,
                                  horizontal = TRUE,
                                  col='red',
                                  range=range,
                                  main = "Tag Length")
    if (length(whisker$out)==0){
      cat("    Boxplot adjusted to account for skewness\n")
    } else {
      outliers <- data.frame(Locus=as.character(x$loc.names[nchar.tags %in% whisker$out]),
                             TagLen=whisker$out
      )
      cat("    Boxplot adjusted to account for skewness\n")
    }
  }  
  # Set margins for second plot
  par(mai=c(0.5,0.5,0,0.5))  
  # Plot Histogram
  hist(nchar.tags, col='red',breaks=100, main=NULL)
  
 # Output the outlier loci 
  if (length(whisker$out)==0){
    cat("    No outliers detected\n")
  } else {  
    if (verbose >=3){
      cat("    Outliers detected -- \n")
      print(outliers)
    }  
  }  
  
 # Reset the par options    
    par(op)
    
# FLAG SCRIPT END

    if(verbose >= 1){
      cat("Completed:",funname,"\n")
    }  
    
    if (length(whisker$out)==0){
      return(NULL)
    } else {  
      return(outliers)
    }  
    
}
