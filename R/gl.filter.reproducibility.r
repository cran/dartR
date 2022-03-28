#' @name gl.filter.reproducibility
#' @title Filters loci in a genlight \{adegenet\} object based on average
#'  repeatability of alleles at a locus
#' @description
#' SNP datasets generated by DArT have an index, RepAvg, generated by
#' reproducing the data independently for 30% of loci. RepAvg is the proportion
#' of alleles that give a repeatable result, averaged over both alleles for each
#' locus.
#'
#' SilicoDArT datasets generated by DArT have a similar index, Reproducibility.
#' For these fragment presence/absence data, repeatability is the percentage of
#' scores that are repeated in the technical replicate dataset.
#'
#' @param x Name of the genlight object containing the SNP data [required].
#' @param threshold Threshold value below which loci will be removed
#' [default 0.99].
#' @param plot.out If TRUE, displays a plots of the distribution of
#' reproducibility values before and after filtering [default TRUE].
#' @param plot_theme Theme for the plot [default theme_dartR()].
#' @param plot_colors List of two color names for the borders and fill of the
#' plots [default two_colors].
#' @param save2tmp If TRUE, saves any ggplots and listings to the session
#' temporary directory (tempdir) [default FALSE].
#' @param verbose Verbosity: 0, silent or fatal errors; 1, begin and end; 2,
#' progress log ; 3, progress and results summary; 5, full report
#' [default 2, unless specified using gl.set.verbosity].
#'
#' @return Returns a genlight object retaining loci with repeatability (Repavg
#' or Reproducibility) greater than the specified threshold.
#' @author Custodian: Arthur Georges -- Post to
#' \url{https://groups.google.com/d/forum/dartr}
#' @examples
#' # SNP data
#'   gl.report.reproducibility(testset.gl)
#'   result <- gl.filter.reproducibility(testset.gl, threshold=0.99, verbose=3)
#' # Tag P/A data
#'   gl.report.reproducibility(testset.gs)
#'   result <- gl.filter.reproducibility(testset.gs, threshold=0.99)
#' @seealso \code{\link{gl.report.reproducibility}}
#' @family filters and filter reports
#' @import patchwork
#' @export

gl.filter.reproducibility <- function(x,
                                      threshold = 0.99,
                                      plot.out = TRUE,
                                      plot_theme = theme_dartR(),
                                      plot_colors = two_colors,
                                      save2tmp = FALSE,
                                      verbose = NULL) {
    # SET VERBOSITY
    verbose <- gl.check.verbosity(verbose)
    
    # FLAG SCRIPT START
    funname <- match.call()[[1]]
    utils.flag.start(func = funname,
                     build = "Jody",
                     verbosity = verbose)
    
    # CHECK DATATYPE
    datatype <- utils.check.datatype(x, verbose = verbose)
    
    # FUNCTION SPECIFIC ERROR CHECKING
    
    if (threshold < 0 | threshold > 1) {
        cat(
            warn(
                "  Warning: Threshold value for repeatability measure must be between 0 and 1, set to 0.99\n"
            )
        )
        threshold <- 0.99
    }
    if (datatype == "SilicoDArT") {
        if (is.null(x@other$loc.metrics$Reproducibility)) {
            stop(
                error(
                    "Fatal Error: Dataset does not include Reproducibility among the locus metrics, cannot be calculated!"
                )
            )
        }
    }
    if (datatype == "SNP") {
        if (is.null(x@other$loc.metrics$RepAvg)) {
            stop(
                error(
                    "Fatal Error: Dataset does not include RepAvg among the locus metrics, cannot be calculated!"
                )
            )
        }
    }
    
    # DO THE JOB
    
    hold <- x
    loc.list <- array(NA, nLoc(x))
    
    # Tag presence/absence data
    if (datatype == "SilicoDArT") {
        repeatability <- x@other$loc.metrics$Reproducibility
        for (i in 1:nLoc(x)) {
            if (repeatability[i] < threshold) {
                loc.list[i] <- locNames(x)[i]
            }
        }
    }
    
    # SNP data
    if (datatype == "SNP") {
        repeatability <- x@other$loc.metrics$RepAvg
        for (i in 1:nLoc(x)) {
            if (repeatability[i] < threshold) {
                loc.list[i] <- locNames(x)[i]
            }
        }
    }
    
    # Remove NAs from list of loci to be discarded
    loc.list <- loc.list[!is.na(loc.list)]
    
    if (length(loc.list) > 0) {
        # remove the loci with repeatability below the threshold
        if (verbose >= 2) {
            cat(report(
                "  Removing loci with repeatability less than",
                threshold,
                "\n"
            ))
        }
        x2 <- gl.drop.loc(x, loc.list = loc.list, verbose = 0)
    } else {
        x2 <- x
        if (verbose >= 2) {
            cat(report(
                "  No loci with repeatability less than",
                threshold,
                "\n"
            ))
        }
    }
    
    # PLOT HISTOGRAMS, BEFORE AFTER
    if (plot.out) {
        min <- min(repeatability, threshold, na.rm = TRUE)
        min <- trunc(min * 100) / 100
        if (datatype == "SNP") {
            xlabel <- "Pre-filter SNP repeatability"
        } else {
            xlabel <- "Pre-filter P/A repeatability"
        }
        p1 <-
            ggplot(data.frame(repeatability), aes(x = repeatability)) + geom_histogram(bins = 100,
                                                                                       color = plot_colors[1],
                                                                                       fill = plot_colors[2]) +
            coord_cartesian(xlim = c(min, 1)) + geom_vline(xintercept = threshold,
                                                           color = "red",
                                                           size = 1) + xlab(xlabel) + ylab("Count") +
            plot_theme
        
        if (datatype == "SilicoDArT") {
            repeatability <- x2@other$loc.metrics$Reproducibility
        }
        if (datatype == "SNP") {
            repeatability <- x2@other$loc.metrics$RepAvg
        }
        if (datatype == "SNP") {
            xlabel <- "Post-filter SNP repeatability"
        } else {
            xlabel <- "Post-filter P/A repeatability"
        }
        min <- min(repeatability, threshold, na.rm = TRUE)
        min <- trunc(min * 100) / 100
        p2 <-
            ggplot(data.frame(repeatability), aes(x = repeatability)) + geom_histogram(bins = 100,
                                                                                       color = plot_colors[1],
                                                                                       fill = plot_colors[2]) +
            coord_cartesian(xlim = c(min, 1)) + geom_vline(xintercept = threshold,
                                                           color = "red",
                                                           size = 1) + xlab(xlabel) + ylab("Count") +
            plot_theme
        
        p3 <- (p1 / p2) + plot_layout(heights = c(1, 1))
        print(p3)
    }
    
    # REPORT A SUMMARY
    if (verbose >= 3) {
        cat("  Summary of filtered dataset\n")
        cat(paste("    Retaining loci with repeatability >=", threshold, "\n"))
        cat(paste("    Original no. of loci:", nLoc(hold), "\n"))
        cat(paste("    No. of loci discarded:", nLoc(hold) - nLoc(x2), "\n"))
        cat(paste("    No. of loci retained:", nLoc(x2), "\n"))
        cat(paste("    No. of individuals:", nInd(x2), "\n"))
        cat(paste("    No. of populations: ", nPop(x2), "\n"))
    }
    
    # SAVE INTERMEDIATES TO TEMPDIR
    if (save2tmp & plot.out) {
        # creating temp file names
        temp_plot <- tempfile(pattern = "Plot_")
        match_call <-
            paste0(names(match.call()),
                   "_",
                   as.character(match.call()),
                   collapse = "_")
        # saving to tempdir
        saveRDS(list(match_call, p3), file = temp_plot)
        if (verbose >= 2) {
            cat(report("  Saving ggplot(s) to the session tempfile\n"))
            cat(
                report(
                    "  NOTE: Retrieve output files from tempdir using gl.list.reports() and gl.print.reports()\n"
                )
            )
        }
    }
    
    # ADD TO HISTORY
    nh <- length(x2@other$history)
    x2@other$history[[nh + 1]] <- match.call()
    
    # FLAG SCRIPT END
    
    if (verbose >= 1) {
        cat(report("Completed:", funname, "\n"))
    }
    
    return(x2)
    
}
