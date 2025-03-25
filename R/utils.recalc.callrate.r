#' A utility script to recalculate the callrate by locus after some populations
#' have been deleted
#'
#' SNP datasets generated by DArT have missing values primarily arising from
#' failure to call a SNP because of a mutation at one or both of the
#' restriction enzyme recognition sites. The locus metadata supplied by DArT has
#'  callrate included, but the call rate will change when some individuals are
#'  removed from the dataset. This script recalculates the callrate and places
#'  these recalculated values in the appropriate place in the genlight object.
#'  It sets the Call Rate flag to TRUE.
#'
#' @param x Name of the genlight object containing the SNP data [required].
#' @param verbose Verbosity: 0, silent or fatal errors; 1, begin and end; 2,
#' progress log ; 3, progress and results summary; 5, full report [default 2].
#' @return The modified genlight object
#' @author Custodian: Luis Mijangos (Post to
#'  \url{https://groups.google.com/d/forum/dartr})
#' @seealso \code{utils.recalc.metrics} for recalculating all metrics,
#' \code{utils.recalc.avgpic} for recalculating avgPIC,
#' \code{utils.recalc.freqhomref} for recalculating frequency of homozygous
#' reference, \code{utils.recalc.freqhomsnp} for recalculating frequency of
#' homozygous alternate, \code{utils.recalc.freqhet} for recalculating frequency
#'  of heterozygotes, \code{gl.recalc.maf} for recalculating minor allele
#'  frequency, \code{gl.recalc.rdepth} for recalculating average read depth
#' @examples
#' #out <- utils.recalc.callrate(testset.gl)

utils.recalc.callrate <- function(x,
                                  verbose = NULL) {
    # SET VERBOSITY
    verbose <- gl.check.verbosity(verbose)
    
    # FLAG SCRIPT START
    funname <- match.call()[[1]]
    utils.flag.start(func = funname,
                     build = "Jody",
                     verbose = verbose)
    
    # CHECK DATATYPE
    datatype <- utils.check.datatype(x, verbose = verbose)
    
    # Check monomorphs have been removed up to date
    if (x@other$loc.metrics.flags$monomorphs == FALSE) {
        if (verbose >= 2) {
            cat(
                warn(
                    "  Warning: Dataset contains monomorphic loci which will be included in the Call Rate calculations\n"
                )
            )
        }
    }
    
    # FUNCTION SPECIFIC ERROR CHECKING
    
    if (is.null(x@other$loc.metrics$CallRate)) {
        x@other$loc.metrics$CallRate <- array(NA, nLoc(x))
        if (verbose >= 2) {
            cat(
                report(
                    "  Locus metric CallRate does not exist, creating slot @other$loc.metrics$CallRate\n"
                )
            )
        }
    }
    
    # DO THE DEED
    
    if (verbose >= 2) {
        cat(report("  Recalculating locus metric CallRate\n"))
    }
    x@other$loc.metrics$CallRate <-
        1 - (glNA(x, alleleAsUnit = FALSE)) / nInd(x)
    x@other$loc.metrics$CallRate <- signif(x@other$loc.metrics$CallRate,digits=6)
    x@other$loc.metrics.flags$CallRate <- TRUE
    
    # FLAG SCRIPT END
    
    if (verbose > 0) {
        cat(report("Completed:", funname, "\n"))
    }
    
    return(x)
}
