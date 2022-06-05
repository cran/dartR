#' @name gl.filter.callrate
#' @title Filters loci or specimens in a genlight \{adegenet\} object based on
#' call rate
#' @description
#' SNP datasets generated by DArT have missing values primarily arising from
#' failure to call a SNP because of a mutation at one or both of the restriction
#' enzyme recognition sites. The script gl.filter.callrate() will filter out the
#'  loci with call rates below a specified threshold.
#'
#' Tag Presence/Absence datasets (SilicoDArT) have missing values where it is
#' not possible to determine reliably if there the sequence tag can be called at
#' a particular locus.
#'
#' @details
#' Because this filter operates on call rate, this function recalculates Call
#' Rate, if necessary, before filtering. If individuals are removed using
#' method='ind', then the call rate stored in the genlight object is, optionally,
#' recalculated after filtering.
#'
#' Note that when filtering individuals on call rate, the initial call rate is
#' calculated and compared against the threshold. After filtering, if
#' mono.rm=TRUE, the removal of monomorphic loci will alter the call rates.
#' Some individuals with a call rate initially greater than the nominated
#' threshold, and so retained, may come to have a call rate lower than the
#' threshold. If this is a problem, repeated iterations of this function will
#' resolve the issue. This is done by setting mono.rm=TRUE and recursive=TRUE,
#' or it can be done manually.
#'
#' Callrate is summarized by locus or by individual to allow sensible decisions
#' on thresholds for filtering taking into consideration consequential loss of
#' data. The summary is in the form of a tabulation and plots.
#'
#' Plot themes can be obtained from \itemize{
#'  \item \url{https://ggplot2.tidyverse.org/reference/ggtheme.html} and \item
#'  \url{https://yutannihilation.github.io/allYourFigureAreBelongToUs/ggthemes/}
#'  }
#'
#' Resultant ggplot(s) and the tabulation(s) are saved to the session's
#'  temporary directory.
#'
#' @param x Name of the genlight object containing the SNP data, or the genind
#'  object containing the SilocoDArT data [required].
#' @param method Use method='loc' to specify that loci are to be filtered, 'ind' to specify
#' that specimens are to be filtered, 'pop' to remove loci that fail to meet the
#'  specified threshold in any one population [default 'loc'].
#' @param threshold Threshold value below which loci will be removed
#' [default 0.95].
#' @param mono.rm Remove monomorphic loci after analysis is complete
#' [default FALSE].
#' @param recalc Recalculate the locus metadata statistics if any individuals
#' are deleted in the filtering [default FALSE].
#' @param recursive Repeatedly filter individuals on call rate, each time
#' removing monomorphic loci. Only applies if method='ind' and mono.rm=TRUE
#'  [default FALSE].
#' @param plot.out Specify if histograms of call rate, before and after, are to
#' be produced [default TRUE].
#' @param plot_theme User specified theme for the plot [default theme_dartR()].
#' @param plot_colors List of two color names for the borders and fill of the
#' plots [default two_colors].
#' @param bins Number of bins to display in histograms [default 25].
#' @param save2tmp If TRUE, saves any ggplots and listings to the session
#'  temporary directory (tempdir) [default FALSE].
#' @param verbose Verbosity: 0, silent or fatal errors; 1, begin and end; 2,
#' progress log ; 3, progress and results summary; 5, full report
#' [default 2, unless specified using gl.set.verbosity].
#'
#' @return The reduced genlight or genind object, plus a summary
#' @author Custodian: Arthur Georges -- Post to
#' \url{https://groups.google.com/d/forum/dartr}
#'
#' @examples
#' # SNP data
#'   result <- gl.filter.callrate(testset.gl[1:10], method='loc', threshold=0.8, verbose=3)
#'   result <- gl.filter.callrate(testset.gl[1:10], method='ind', threshold=0.8, verbose=3)
#'   result <- gl.filter.callrate(testset.gl[1:10], method='pop', threshold=0.8, verbose=3)
#' # Tag P/A data
#'   result <- gl.filter.callrate(testset.gs[1:10], method='loc', threshold=0.95, verbose=3)
#'   result <- gl.filter.callrate(testset.gs[1:10], method='ind', threshold=0.8, verbose=3)
#'   result <- gl.filter.callrate(testset.gs[1:10], method='pop', threshold=0.8, verbose=3)
#'
#' @seealso \code{\link{gl.report.callrate}}
#' @family filter functions
#' @import patchwork
#' @export

gl.filter.callrate <- function(x,
                               method = "loc",
                               threshold = 0.95,
                               mono.rm = FALSE,
                               recalc = FALSE,
                               recursive = FALSE,
                               plot.out = TRUE,
                               plot_theme = theme_dartR(),
                               plot_colors = two_colors,
                               bins = 25,
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
    
    # Check monomorphs have been removed up to date
    if (x@other$loc.metrics.flags$monomorphs == FALSE) {
        if (verbose >= 2) {
            cat(
                warn(
                    "  Warning: Data may include monomorphic loci in call rate calculations for filtering\n"
                )
            )
        }
    }
    
    # Check call rate up to date if (x@other$loc.metrics.flags$CallRate == FALSE){
    if (verbose >= 2) {
        cat(report("  Recalculating Call Rate\n"))
    }
    x <- utils.recalc.callrate(x, verbose = 0)
    # }
    
    # Suppress plotting on verbose == 0
    if (verbose == 0) {
        plot.out = FALSE
    }
    
    # Method
    if (method != "ind" & method != "loc" & method != "pop") {
        cat(
            warn(
                "    Warning: method must be either \"loc\" or \"ind\" or \"pop\", set to \"loc\" \n"
            )
        )
        method <- "loc"
    }
    
    # Threshold
    if (threshold < 0 | threshold > 1) {
        cat(warn(
            "    Warning: threshold must be an integer between 0 and 1, set to 0.95\n"
        ))
        threshold <- 0.95
    }
    
    # DO THE JOB
    
    hold <- x
    
    # FOR METHOD BASED ON LOCUS
    
    if (method == "loc") {
        # Determine starting number of loci and individuals
        if (verbose >= 2) {
            cat(report(
                "  Removing loci based on Call Rate, threshold =",
                threshold,
                "\n"
            ))
        }
        n0 <- nLoc(x)
        
        # Remove loci with NA count <= 1-threshold index <- colMeans(is.na(as.matrix(x))) < threshold
        index <- x@other$loc.metrics$CallRate >= threshold
        x2 <- x[, index]
        x2@other$loc.metrics <- x@other$loc.metrics[index,]
        
        # Plot a histogram of Call Rate
        callrate <- x@other$loc.metrics$CallRate
        min <- min(callrate, threshold, na.rm = TRUE)
        min <- trunc(min * 100) / 100
        if (datatype == "SNP") {
            xlabel <- "Pre-filter SNP Call Rate [Loci]"
        } else {
            xlabel <- "Pre-filter P/A Call Rate [Loci]"
        }
        p1 <-
            ggplot(data.frame(callrate), aes(x = callrate)) +
            geom_histogram(bins = bins,
                           color = plot_colors[1],
                           fill = plot_colors[2]) +
            coord_cartesian(xlim = c(min, 1)) + 
            geom_vline(xintercept = threshold,
                       color = "red",
                       size = 1) + 
            xlab(xlabel) + 
            ylab("Count") +
            plot_theme
        
        callrate <- x2@other$loc.metrics$CallRate
        min <- min(callrate, threshold, na.rm = TRUE)
        min <- trunc(min * 100) / 100
        if (datatype == "SNP") {
            xlabel <- "Post-filter SNP Call Rate [Loci]"
        } else {
            xlabel <- "Post-filter P/A Call Rate [Loci]"
        }
        p2 <-
            ggplot(data.frame(callrate), aes(x = callrate)) + 
            geom_histogram(bins = bins,
                           color = plot_colors[1],
                           fill = plot_colors[2]) +
            coord_cartesian(xlim = c(min, 1)) +
            geom_vline(xintercept = threshold,
                       color = "red",
                       size = 1) +
            xlab(xlabel) +
            ylab("Count") +
            plot_theme
        
        if (mono.rm) {
            # Remove monomorphic loci
            x2 <- gl.filter.monomorphs(x2, verbose = 0)
        }
        if (recalc) {
            # Recalculate all metrics, including Call Rate (flags reset in utils scripts)
            x2 <- gl.recalc.metrics(x2, verbose = verbose)
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
            x2@other$loc.metrics.flags$allna <- FALSE
        }
    }
    
    ########### FOR METHOD BASED ON INDIVIDUAL
    
    if (method == "ind") {
        # Determine starting number of loci and individuals
        if (verbose >= 2) {
            cat(
                report(
                    "  Removing individuals based on Call Rate, threshold =",
                    threshold,
                    "\n"
                )
            )
        }
        n0 <- nInd(x)
        # if (verbose >= 3) {cat('Initial no. of individuals =', n0, '\n')}
        
        # Calculate the individual call rate
        ind.call.rate <- 1 - rowSums(is.na(as.matrix(x))) / nLoc(x)
        
        # Store the initial call rate profile
        hold2 <- ind.call.rate
        
        # Check that there are some individuals left
        if (sum(ind.call.rate >= threshold) == 0) {
            stop(error(
                paste(
                    "Maximum individual call rate =",
                    max(ind.call.rate),
                    ". Nominated threshold of",
                    threshold,
                    "too stringent.\n No individuals remain.\n"
                )
            ))
        }
        if (!recursive) {
            # Extract those individuals with a call rate greater or equal to the
            # threshold
            x2 <- x[ind.call.rate >= threshold,]
            
            # for some reason that eludes me, this also (appropriately) filters 
            # the latlons and the covariates, but see above for locus filtering
            
            # Report individuals that are excluded on call rate
            if (any(ind.call.rate <= threshold)) {
                x3 <- x[ind.call.rate <= threshold,]
                if (length(x3) > 0) {
                    if (verbose >= 2) {
                        cat("  Individuals deleted (CallRate <= ",
                            threshold,
                            "):\n")
                        cat(paste0(
                            indNames(x3),
                            "[",
                            as.character(pop(x3)),
                            "],"
                        ))
                    }
                    cat("\n")
                    
                    if (mono.rm) {
                        # Remove monomorphic loci
                        x2 <- gl.filter.monomorphs(x2, verbose = 0)
                    }
                    if (recalc) {
                        # Recalculate all metrics, including Call Rate (flags reset in utils scripts)
                        x2 <- gl.recalc.metrics(x2, verbose = verbose)
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
                        x2@other$loc.metrics.flags$allna <- FALSE
                    }
                }
            }
            # Recalculate the callrate
            ind.call.rate <- 1 - rowSums(is.na(as.matrix(x2))) / nLoc(x2)
            # cat(min(ind.call.rate),'\n')
        } else {
            # If recursive
            # Recursively remove individuals
            if (verbose >= 2) {
                cat(
                    report(
                        "Recursively removing individuals with call rate <",
                        threshold,
                        ", recalculating Call Rate after deleting monomorphs, and repeating until final Call Rate is >=",
                        threshold,
                        "\n"
                    )
                )
            }
            for (i in 1:10) {
                # Recalculate the callrate
                ind.call.rate <- 1 - rowSums(is.na(as.matrix(x))) / nLoc(x)
                # Extract those individuals with a call rate greater or equal to the threshold
                x2 <- x[ind.call.rate >= threshold,]
                
                if (nInd(x2) == nInd(x)) {
                    break
                }
                
                # for some reason that eludes me, this also (appropriately) filters the latlons and the covariates, but see above for
                # locus filtering
                if (verbose > 2) {
                    cat(
                        report(
                            "ITERATION",
                            i,
                            "\n  No. of individuals deleted =",
                            (n0 - nInd(x2)),
                            "\n  No. of individuals retained =",
                            nInd(x2),
                            "\n"
                        )
                    )
                }
                
                # Report individuals that are excluded on call rate
                if (any(ind.call.rate <= threshold)) {
                    x3 <- x[ind.call.rate <= threshold,]
                    if (length(x3) > 0) {
                        if (verbose >= 3) {
                            cat(
                                report(
                                    "  List of individuals deleted (CallRate <= ",
                                    threshold,
                                    ":\n"
                                )
                            )
                            cat(report(
                                paste0(
                                    indNames(x3),
                                    "[",
                                    as.character(pop(x3)),
                                    "],"
                                )
                            ))
                            cat("\n")
                        }
                        if (mono.rm) {
                            # Remove monomorphic loci
                            cat(report("  Removing monomorphic loci\n"))
                            x2 <-
                                gl.filter.monomorphs(x2, verbose = 0)
                        }
                        if (recalc) {
                            # Recalculate all metrics, including Call Rate (flags reset in utils scripts)
                            x2 <-
                                gl.recalc.metrics(x2, verbose = verbose)
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
                            x2@other$loc.metrics.flags$allna <- FALSE
                        }
                    }
                }
                x <- x2
            }
        }
        
        # Plot a histogram of Call Rate
        
        min <- min(hold2, threshold, na.rm = TRUE)
        min <- trunc(min * 100) / 100
        if (datatype == "SNP") {
            xlabel <- "Pre-filter SNP Call Rate [Individuals]"
        } else {
            xlabel <- "Pre-filter P/A Call Rate [Individuals]"
        }
        p1 <-
            ggplot(data.frame(hold2), aes(x = hold2)) + 
            geom_histogram(bins = bins,
                           color = plot_colors[1],
                           fill = plot_colors[2]) +
            coord_cartesian(xlim = c(min,1)) + 
            geom_vline(xintercept = threshold, color = "red", size = 1) + 
            xlab(xlabel) + 
            ylab("Count") + 
            plot_theme
        
        min <- min(ind.call.rate, threshold, na.rm = TRUE)
        min <- trunc(min * 100) / 100
        if (datatype == "SNP") {
            xlabel <- "Post-filter SNP Call Rate [Individuals]"
        } else {
            xlabel <- "Post-filter P/A Call Rate [Individuals]"
        }
        p2 <-
            ggplot(data.frame(ind.call.rate), aes(x = ind.call.rate)) + 
            geom_histogram(bins = bins, 
                           color = plot_colors[1], 
                           fill = plot_colors[2]) +
            coord_cartesian(xlim = c(min, 1)) + 
            geom_vline(xintercept = threshold,color = "red", size = 1) + 
            xlab(xlabel) + 
            ylab("Count") +
            plot_theme
    }
    
    ########### FOR METHOD BASED ON POPULATIONS
    
    if (method == "pop") {
        if (verbose >= 2) {
            cat(
                report(
                    "  Removing loci based on Call Rate by population\n    Call Rate must be equal to or exceed threshold =",
                    threshold,
                    "in all populations\n"
                )
            )
        }
        
        pops <- seppop(x)
        ll <-
            lapply(pops, function(x)
                locNames(
                    gl.filter.callrate(
                        x,
                        method = "loc",
                        threshold = threshold,
                        verbose = 0
                    )
                ))
        locall <- Reduce(intersect, ll)
        index <- which(locNames(x) %in% locall)
        x <- x[, locall]
        x@other$loc.metrics <- x@other$loc.metrics[locall,]
        
        x <- utils.recalc.callrate(x, verbose = 0)
        
        # Plot a histogram of Call Rate
        
        tmp <- hold@other$loc.metrics$CallRate
        min <- min(tmp, threshold, na.rm = TRUE)
        min <- trunc(min * 100) / 100
        if (datatype == "SNP") {
            xlabel <- "Pre-filter SNP Call Rate [by population]"
        } else {
            xlabel <- "Pre-filter P/A Call Rate [by population]"
        }
        p1 <-
            ggplot(data.frame(tmp), aes(x = tmp)) + 
            geom_histogram(bins = bins,
                           color = plot_colors[1],
                           fill = plot_colors[2]) + 
            coord_cartesian(xlim = c(min, 1)) + 
            geom_vline(xintercept = threshold, color = "red", size = 1) + 
            xlab(xlabel) + 
            ylab("Count") + 
            plot_theme
        
        tmp <- x@other$loc.metrics$CallRate
        min <- min(tmp, threshold, na.rm = TRUE)
        min <- trunc(min * 100) / 100
        if (datatype == "SNP") {
            xlabel <- "Post-filter SNP Call Rate [by population]"
        } else {
            xlabel <- "Post-filter P/A Call Rate [by population]"
        }
        p2 <-
            ggplot(data.frame(tmp), aes(x = tmp)) + 
            geom_histogram(bins = bins,
                           color = plot_colors[1],
                           fill = plot_colors[2]) + 
            coord_cartesian(xlim = c(min, 1)) +
            geom_vline(xintercept = threshold,color = "red", size = 1) + 
            xlab(xlabel) + 
            ylab("Count") + 
            plot_theme
        
        x2 <- x
        if (mono.rm) {
            # Remove monomorphic loci
            x2 <- gl.filter.monomorphs(x2, verbose = 0)
        }
        if (recalc) {
            # Recalculate all metrics, including Call Rate (flags reset in utils scripts)
            x2 <- gl.recalc.metrics(x2, verbose = verbose)
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
            x2@other$loc.metrics.flags$allna <- FALSE
        }
    }
    
    # REPORT A SUMMARY
    if (verbose >= 3) {
        cat("  Summary of filtered dataset\n")
        if (method == "pop") {
            cat(paste("    Call Rate in any one population >", threshold, "\n"))
        } else if (method == "ind") {
            cat(paste("    Call Rate for individuals >", threshold, "\n"))
        } else {
            cat(paste("    Call Rate for loci >", threshold, "\n"))
        }
        cat(paste("    Original No. of loci :", nLoc(hold), "\n"))
        cat(paste("    Original No. of individuals:", nInd(hold), "\n"))
        cat(paste("    No. of loci retained:", nLoc(x2), "\n"))
        cat(paste("    No. of individuals retained:", nInd(x2), "\n"))
        cat(paste("    No. of populations: ", length(levels(
            factor(pop(x2))
        )), "\n"))
    }
    
    # PRINTING OUTPUTS using package patchwork
    p3 <- (p1 / p2) + plot_layout(heights = c(1, 1))
    if (plot.out) {
        print(p3)
    }
    
    if (verbose >= 2) {
        if (method == "ind") {
            if (!recalc) {
                cat(report("  Note: Locus metrics not recalculated\n"))
            } else {
                cat(report("  Note: Locus metrics recalculated\n"))
            }
            if (!mono.rm) {
                cat(report(
                    "  Note: Resultant monomorphic loci not deleted\n"
                ))
            } else {
                cat(report("  Note: Resultant monomorphic loci deleted\n"))
                if (!recursive) {
                    cat(
                        warn(
                            "  Warning: Some individuals with a Call Rate initially >=",
                            threshold,
                            "may have a final CallRate lower than",
                            threshold,
                            "when call rate is recalculated after removing resultant monomorphic loci\n"
                        )
                    )
                }
            }
        }
    }
    
    # # Recalculate Call Rate to be safe x <- utils.recalc.callrate(x,verbose=0)
    
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
    
    if (verbose > 0) {
        cat(report("Completed:", funname, "\n"))
    }
    
    invisible(x2)
}
