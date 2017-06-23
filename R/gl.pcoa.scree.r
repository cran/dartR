#' Produce a plot of eigenvalues, standardized as percentages, derived from a PCoA
#'
#' This script takes output from gl.pcoa() and produces a plot of eigenvalues, expressed as a percentage of the sum of the
#' eigenvalues. An option is provided to only plot those eigenvalues with greater explanatory power than the average for
#' the original variables.
#'
#' A Scree Plot is a plot of the relative value of eigenvalues, usually expressed as a percentage, that informs a decision
#' on how many dimensions carry with them substantial information worthy of examination. In an ordination, such as PCoA,
#' the axes are ordered on the proportion of variation explained, so the first axis explains the most (has the largest eigenvalue),
#' the second explains the next greatest amount, and so on.
#'
#' @param x -- name of the pcoa file generated by gl.pcoa() [required]
#' @param top -- a flag to indicate whether or not plot only those eigenvalues greater in value than the average for the
#'        unordinated original variables (top=TRUE) or to plot all eigenvalues (top=FALSE). If top=FALSE, then a
#'        reference line showing the average eigenvalue for the unordinated variables is shown. [default TRUE]
#' @return The scree plot
#' @export
#' @author Arthur Georges (glbugs@@aerg.canberra.edu.au)
#' @examples
#' pcoa <- gl.pcoa(testset.gl)
#' gl.pcoa.scree(pcoa)

gl.pcoa.scree <- function(x, top=TRUE) {

  # Express eigenvalues as a percentage of total
    s <- sum(x$eig)
    e <- round(x$eig*100/s,1)

  # If top=TRUE, consider only those eigenvalues above the average for the original unordinated variables.
    if(top==TRUE) {
      e <- e[e>mean(e)]
      cat("Note: Only eigenvalues for dimensions that explain more that the average of the original variables are shown\n")
    } else {
      cat("Note: All eigenvalues shown\n")
    }
    top <- length(e[e>=10])
    cat(paste("No. of axes each explaining 10% or more of total variation:",top,"\n"))
  # Plot the scree plot
    m <- cbind(seq(1:length(e)),e)
    df <- data.frame(m)
    colnames(df) <- c("eigenvalue","percent")
    xlab <- paste("Eigenvalue")
    ylab <- paste("Percentage Contribution")
    p <- ggplot(df, aes(x=df$eigenvalue, y=df$percent)) +
      geom_point(size=3, colour="red") +
      geom_line(colour="red") +
      ggtitle("Scree plot for PCoA") +
      theme(axis.title=element_text(face="bold.italic",size="20", color="black"),
          axis.text.x  = element_text(face="bold",angle=0, vjust=0.5, size=16),
          axis.text.y  = element_text(face="bold",angle=0, vjust=0.5, size=16)) +
      labs(x=xlab, y=ylab) +
      geom_hline(yintercept=0) +
      geom_vline(xintercept=0)
      if(top==FALSE) {p <- p + geom_hline(yintercept=mean(e), colour="blue")}

   return(p)
}
