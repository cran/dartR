#' Recursively collapse a distance matrix by amalgamating populations
#'
#' This script generates a fixed difference matrix from a genlight object \{adegenet\} and from it generates a population recode
#' table used to amalgamate populations with distance less than or equal to a specified t. The script then repeats the process
#' until there is no further amalgamation of populations.
#' The distance matricies are generated by gl.fixed.diff(), a recode table is generated using gl.collapse() and the resultant
#' recode table is applied to the genlight object using gl.pop.recode(). The process is repeated as many times as necessary to
#' yield a final table with no distances less than or equal to the specified threshold. The intermediate and final recode tables and distance matricies are
#' stored to disk as csv files for use with other analyses. In particular, the recode tables can be editted to replace Group1, Group2 etc with meaninful names.
#'
#' @param gl -- name of the genlight object from which the distance matricies are to be calculated [required]
#' @param prefix -- a string to be used as a prefix in generating the matricies of fixed differences (stored to disk) and the recode
#' tables (also stored to disk) [default "collapse"]
#' @param threshold -- the threshold distance value for amalgamating populations [default 0]
#' @return The new genlight object with recoded populations.
#' @import reshape2
#' @export
#' @author Arthur Georges (glbugs@aerg.canberra.edu.au)
#' @examples
#' #only used the first 20 individuals due to runtime reasons
#' fd <- gl.collapse.recursive(testset.gl[1:20,], prefix="testset",threshold=0.026)

gl.collapse.recursive <- function(gl, prefix="collapse", threshold=0) {

# Set the iteration counter
  count <- 1
# Create the initial distance matrix
  cat("Calculating an initial fixed difference matrix\n")
  fd <- gl.fixed.diff(gl, t=threshold)
# Construct a filename for the fd matrix
  d.name <- paste0(prefix,"_FD_cut_",count,".csv")
# Output the fd matrix for the first iteration to file
  cat(paste("     Writing the initial fixed difference matrix to disk:",d.name,"\n"))
  write.csv(fd, d.name)
# set the length of the fd matrix
  fd.hold <- dim(fd)[1]

# Repeat until no change to the fixed difference matrix
  cat("Collapsing the initial fixed difference matrix iteratively until no further change\n")
  cat(paste("     threshold =",threshold,"\n"))
  repeat {
    cat(paste("\nITERATION ", count,"\n"))
  # Construct a filename for the pop.recode table
    recode.name <- paste0(prefix,"_FD_pop_recode_cut_",count,".csv")
  # Collapse the matrix, write the new pop.recode table to file
    gl <- gl.collapse(fd, gl, recode.table=recode.name, t=threshold, iter=count)
  #  calculate the fixed difference matrix fd
    fd <- gl.fixed.diff(gl, t=threshold)
  # If it is not different in dimensions from previous, break
    if (dim(fd)[1] == fd.hold) {
      cat(paste("\nNo further amalgamation of populations at d < ",threshold,"\n"))
      break
    }
  # Otherwise, construct a filename for the collapsed fd matrix
    d.name <- paste0(prefix,"_FD_cut_",count+1,".csv")
  # Output the collapsed fixed difference matrix for this iteration to file
    cat(paste("     Writing the collapsed fixed difference matrix to disk:",d.name,"\n"))
    write.csv(fd, d.name)
  # Hold the dimensions of the new fixed difference matrix, increment iteration counter
    fd.hold <- dim(fd)[1]
    count <- count + 1
  }

  return(gl)
}
