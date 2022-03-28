#' @name gl.filter.taglength
#' @title Filters loci in a genlight \{adegenet\} object based on sequence tag
#'  length
#' @description
#' SNP datasets generated by DArT typically have sequence tag lengths ranging
#' from 20 to 69 base pairs.
#'
#' @param x Name of the genlight object containing the SNP data [required].
#' @param lower Lower threshold value below which loci will be removed
#' [default 20].
#' @param upper Upper threshold value above which loci will be removed
#'  [default 69].
#' @param verbose Verbosity: 0, silent or fatal errors; 1, begin and end; 2,
#' progress log; 3, progress and results summary; 5, full report
#' [default 2, unless specified using gl.set.verbosity].
#' @return Returns a genlight object retaining loci with a sequence tag length
#' in the range specified by the lower and upper threshold.
#' @export
#' @author Custodian: Arthur Georges -- Post to
#' \url{https://groups.google.com/d/forum/dartr}
#' @examples
#' # SNP data
#'   gl.report.taglength(testset.gl)
#'   result <- gl.filter.taglength(testset.gl,lower=60)
#'   gl.report.taglength(result)
#' # Tag P/A data
#'   gl.report.taglength(testset.gs)
#'   result <- gl.filter.taglength(testset.gs,lower=60)
#'   gl.report.taglength(result)

gl.filter.taglength <- function(x,
                                lower = 20,
                                upper = 69,
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
    
    if (length(x@other$loc.metrics$TrimmedSequence) != nLoc(x)) {
        stop(
            error(
                "Fatal Error: Data must include Trimmed Sequences for each loci in a column called 'TrimmedSequence' in the @other$loc.metrics slot.\n"
            )
        )
    }
    if (upper < lower) {
        cat(
            warn(
                "  Warning: Parameter 'upper' must be greater than parameter 'lower', swapping\n"
            )
        )
        tmp <- upper
        upper <- lower
        lower <- tmp
    }
    if (lower < 0 | lower > 250) {
        cat(
            warn(
                "  Warning: Parameter 'verbose' must be an integer between 0 and 250 , set to 20\n"
            )
        )
        lower <- 20
    }
    if (upper < 0 | upper > 250) {
        cat(
            warn(
                "  Warning: Parameter 'upper' must be an integer between 0 and 250 , set to 69\n"
            )
        )
        upper <- 69
    }
    
    # DO THE JOB
    
    n0 <- nLoc(x)
    if (verbose > 2) {
        cat("Initial no. of loci =", n0, "\n")
    }
    
    tags <- x@other$loc.metrics$TrimmedSequence
    nchar.tags <- nchar(as.character(tags))
    
    # Remove SNP loci with rdepth < threshold
    if (verbose > 1) {
        cat(report(
            "  Removing loci with taglength <",
            lower,
            "and >",
            upper,
            "\n"
        ))
    }
    index <- (nchar.tags >= lower & nchar.tags <= upper)
    x2 <- x[, index]
    # Remove the corresponding records from the loci metadata
    x2@other$loc.metrics <- x@other$loc.metrics[index, ]
    if (verbose > 2) {
        cat(report("  No. of loci deleted =", (n0 - nLoc(x2)), "\n"))
    }
    
    # REPORT A SUMMARY
    if (verbose > 2) {
        cat("  Summary of filtered dataset\n")
        cat(paste(
            "    Sequence Tag Length >=",
            lower,
            "and Sequence Tag Length <=",
            upper,
            "\n"
        ))
        cat(paste("    No. of loci:", nLoc(x2), "\n"))
        cat(paste("    No. of individuals:", nInd(x2), "\n"))
        cat(paste("    No. of populations: ", length(levels(
            factor(pop(x2))
        )), "\n"))
    }
    
    # ADD TO HISTORY
    nh <- length(x2@other$history)
    x2@other$history[[nh + 1]] <- match.call()
    
    # FLAG SCRIPT END
    
    if (verbose > 0) {
        cat(report("Completed:", funname, "\n"))
    }
    
    return(x2)
    
}
