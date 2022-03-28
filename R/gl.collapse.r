#' @name gl.collapse
#' @title Collapses a distance matrix by amalgamating populations with pairwise
#'  fixed difference count less that a threshold
#' @description
#' This script takes a file generated by gl.fixed.diff and amalgamates
#' populations with distance less than or equal to a specified threshold. The
#' distance matrix is generated by gl.fixed.diff().
#'
#' The script then applies the new population assignments to the genlight object
#'  and recalculates the distance and associated matrices.
#'
#' @param fd Name of the list of matrices produced by gl.fixed.diff() [required].
#' @param tloc Threshold defining a fixed difference (e.g. 0.05 implies 95:5 vs
#'  5:95 is fixed) [default 0].
#' @param tpop Threshold number of fixed differences above which populations
#' will not be amalgamated [default 0].
#' @param pb If TRUE, show a progress bar on time consuming loops [default FALSE].
#' @param verbose Verbosity: 0, silent or fatal errors; 1, begin and end; 2,
#' progress log; 3, progress and results summary; 5, full report
#' [default 2 or as specified using gl.set.verbosity]
#' @return A list containing the gl object x and the following square matrices:
#' \enumerate{
#'  \item $gl -- the new genlight object with populations collapsed;
#'  \item $fd -- raw fixed differences;
#'  \item $pcfd -- percent fixed differences;
#'  \item $nobs -- mean no. of individuals used in each comparison;
#'  \item $nloc -- total number of loci used in each comparison;
#'  \item $expfpos -- NA's, populated by gl.fixed.diff [by simulation]
#'  \item $expfpos -- NA's, populated by gl.fixed.diff [by simulation]
#'  \item $prob -- NA's, populated by gl.fixed.diff [by simulation]
#'         }
#' @importFrom methods show
#' @export
#' @author Custodian: Arthur Georges -- Post to \url{https://groups.google.com/d/forum/dartr}
#' @examples
#' fd <- gl.fixed.diff(testset.gl,tloc=0.05)
#' fd
#' fd2 <- gl.collapse(fd,tpop=1)
#' fd2
#' fd3 <- gl.collapse(fd2,tpop=1)
#' fd3

gl.collapse <- function(fd,
                        tpop = 0,
                        tloc = 0,
                        pb = FALSE,
                        verbose = NULL) {
    # SET VERBOSITY
    verbose <- gl.check.verbosity(verbose)
    
    # FLAG SCRIPT START
    funname <- match.call()[[1]]
    utils.flag.start(func = funname,
                     build = "Jody",
                     verbosity = verbose)
    
    # CHECK DATATYPE
    datatype <-
        utils.check.datatype(fd, accept = "fd", verbose = verbose)
    
    # FUNCTION SPECIFIC ERROR CHECKING
    
    if (tloc > 0.5 || tloc < 0) {
        stop(error(
            "Fatal Error: Parameter tloc should be positive in the range 0 to 0.5\n"
        ))
    }
    
    if (tpop < 0) {
        stop(error(
            "Fatal Error: Parameter tpop should be a positive integer\n"
        ))
    }
    
    # DO THE JOB
    
    if (verbose >= 2) {
        if (tloc > 0) {
            cat(
                report(
                    "  Comparing populations for fixed differences with tolerance",
                    tloc,
                    "\n"
                )
            )
        }
        if (tloc == 0) {
            cat(report(
                "  Comparing populations for absolute fixed differences\n"
            ))
        }
        if (tpop == 1) {
            cat(
                report(
                    "  Amalgamating populations with corrobrated fixed differences, tpop =",
                    tpop,
                    "\n"
                )
            )
        }
        if (tpop > 1) {
            cat(report(
                "  Amalgamating populations with fixed differences <= ",
                tpop,
                "\n"
            ))
        }
        if (tpop == 0) {
            cat(report(
                "  Amalgamating populations with zero fixed differences\n"
            ))
        }
    }
    
    # Convert fd$fd from a distance matrix to a square matrix
    mat <- as.matrix(fd$fd)
    
    # Store the number of populations in the matrix
    npops <- dim(mat)[1]
    
    # Extract the column names
    pops <- variable.names(mat)
    
    # Initialize a list to hold the populations that differ by <= tpop
    zero.list <- list()
    
    # For each pair of populations
    for (i in 1:npops) {
        zero.list[[i]] <- c(rownames(mat)[i])
        for (j in 1:npops) {
            if (mat[i, j] <= tpop) {
                zero.list[[i]] <-
                    c(zero.list[[i]], rownames(mat)[i], rownames(mat)[j])
                zero.list[[i]] <- unique(zero.list[[i]])
            }
        }
        zero.list[[i]] <- sort(zero.list[[i]])
    }
    
    # Pull out the unique aggregations
    zero.list <- unique(zero.list)
    
    # Amalgamate populations
    if (length(zero.list) >= 2) {
        for (i in 1:(length(zero.list) - 1)) {
            for (j in 2:length(zero.list)) {
                if (length(intersect(zero.list[[i]], zero.list[[j]])) > 0) {
                    zero.list[[i]] <- union(zero.list[[i]], zero.list[[j]])
                    zero.list[[j]] <-
                        union(zero.list[[i]], zero.list[[j]])
                }
            }
        }
        for (i in 1:length(zero.list)) {
            zero.list <- unique(zero.list)
        }
    }
    zero.list.hold <- zero.list
    
    # Print out the results of the aggregations
    if (verbose >= 3) {
        cat("Initial Populations\n", pops, "\n")
        cat("New population groups\n")
    }
    
    x <- fd$gl
    for (i in 1:length(zero.list)) {
        # Create a group label
        if (length(zero.list[[i]]) == 1) {
            replacement <- zero.list[[i]][1]
        } else {
            replacement <- paste0(zero.list[[i]][1], "+")
        }
        if (verbose >= 3) {
            if (length(zero.list[[i]]) > 1) {
                cat(paste0("Group:", replacement, "\n"))
                print(as.character(zero.list[[i]]))
                cat("\n")
            }
        }
        # Amalgamate the populations
        x <-
            gl.merge.pop(x,
                         old = zero.list[[i]],
                         new = replacement,
                         verbose = 0)
    }
    
    # Recalculate matricies
    fd2 <- gl.fixed.diff(x,
                         tloc = tloc,
                         pb = pb,
                         verbose = 0)
    
    if (setequal(nPop(x), nPop(fd$gl))) {
        if (verbose >= 2) {
            cat(paste(
                "\nNo further amalgamation of populations at fd <=",
                tpop,
                "\n"
            ))
            cat("  Analysis complete\n\n")
        }
        l <-
            list(
                gl = fd2$gl,
                fd = fd2$fd,
                pcfd = fd2$pcfd,
                nobs = fd2$nobs,
                nloc = fd2$nloc,
                expfpos = fd2$expfpos,
                sdfpos = fd$sdfpos,
                pval = fd2$pval
            )
        class(l) <- "fd"
    } else {
        # Display the fd matrix
        if (verbose >= 4) {
            cat("\n\nRaw Fixed Difference Matrix\n")
            print(fd2$fd)
            cat("\n")
        }
        if (verbose >= 3) {
            cat("Sample sizes")
            print(table(pop(fd2$gl)))
            cat("\n")
        }
        
        # Create the list for output
        l <-
            list(
                gl = fd2$gl,
                fd = fd2$fd,
                pcfd = fd2$pcfd,
                nobs = fd2$nobs,
                nloc = fd2$nloc,
                expfpos = fd2$expfpos,
                sdfpos = fd2$sdfpos,
                pval = fd2$pval
            )
        class(l) <- "fd"
    }
    
    
    # Explanatory bumpf
    if (verbose >= 3) {
        if (pb) {
            cat("\n")
        }
        cat(
            report(
                "Returning a list of class 'fd' containing the new genlight object and square matricies, as follows:\n",
                "         [[1]] $gl -- input genlight object;\n",
                "         [[2]] $fd -- raw fixed differences;\n",
                "         [[3]] $pcfd -- percent fixed differences;\n",
                "         [[4]] $nobs -- mean no. of individuals used in each comparison;\n",
                "         [[5]] $nloc -- total number of loci used in each comparison;\n",
                "         [[6]] $expfpos -- NAs, populated by gl.fixed.diff [by simulation];\n",
                "         [[7]] $sdfpos -- NAs, populated by gl.fixed.diff [by simulation];\n",
                "         [[8]] $prob -- NAs, populated by gl.fixed.diff [by simulation].\n"
            )
        )
    }
    
    # FLAG SCRIPT END
    
    if (verbose > 0) {
        cat(report("Completed:", funname, "\n"))
    }
    
    return(l)
}
