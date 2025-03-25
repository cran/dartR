#' @name gl.grm.network
#' @title Represents a genomic relationship matrix (GRM) as a network
#' @description
#' This script takes a G matrix generated by \code{\link{gl.grm}} and represents
#' the relationship among the specimens as a network diagram. In order to use
#' this script, a decision is required on a threshold for relatedness to be
#' represented as link in the network, and on the layout used to create the
#' diagram.
#'
#' @param G A genomic relationship matrix (GRM) generated by
#' \code{\link{gl.grm}} [required].
#' @param x A genlight object from which the G matrix was generated [required].
#' @param method One of 'fr', 'kk', 'gh' or 'mds' [default 'fr'].
#' @param node.size Size of the symbols for the network nodes [default 8].
#' @param node.label TRUE to display node labels [default TRUE].
#' @param node.label.size Size of the node labels [default 3].
#' @param node.label.color Color of the text of the node labels
#' [default 'black'].
#' @param link.color Color palette for links [default NULL].
#' @param link.size Size of the links [default 2].
#' @param relatedness_factor Factor of relatedness [default 0.125].
#' @param title Title for the plot
#' [default 'Network based on genomic relationship matrix'].
#' @param palette_discrete A discrete palette for the color of populations or a
#' list with as many colors as there are populations in the dataset
#'  [default NULL].
#' @param save2tmp If TRUE, saves any ggplots and listings to the session
#' temporary directory (tempdir) [default FALSE].
#' @param verbose Verbosity: 0, silent or fatal errors; 1, begin and end; 2,
#'  progress log ; 3, progress and results summary; 5, full report
#'  [default 2 or as specified using gl.set.verbosity].
#' @details 
#' The gl.grm.network function takes a genomic relationship matrix (GRM) 
#' generated by the gl.grm function to represent the relationship among 
#' individuals in the dataset as a network diagram. To generate the GRM, the 
#' function gl.grm uses the function A.mat from package rrBLUP, which implements
#'  the approach developed by Endelman and Jannink (2012).
#'  
#' The GRM is an estimate of the proportion of alleles that two individuals have
#'  in common. It is generated by estimating the covariance of the genotypes 
#'  between two individuals, i.e. how much genotypes in the two individuals
#'   correspond with each other. This covariance depends on the probability that
#'    alleles at a random locus are identical by state (IBS). Two alleles are 
#'    IBS if they represent the same allele. Two alleles are identical by 
#'    descent (IBD) if one is a physical copy of the other or if they are both 
#'    physical copies of the same ancestral allele. Note that IBD is complicated
#'     to determine. IBD implies IBS, but not conversely. However, as the number
#'      of SNPs in a dataset increases, the mean probability of IBS approaches 
#'      the mean probability of IBD.
#'      
#' It follows that the off-diagonal elements of the GRM are two times the 
#' kinship coefficient, i.e. the probability that two alleles at a random locus
#'  drawn from two individuals are IBD. Additionally, the diagonal elements of
#'   the GRM are 1+f, where f is the inbreeding coefficient of each individual,
#'    i.e. the probability that the two alleles at a random locus are IBD.
#'    
#' Choosing a meaningful threshold to represent the relationship between 
#' individuals is tricky because IBD is not an absolute state but is relative to
#'  a reference population for which there is generally little information so 
#'  that we can estimate the kinship of a pair of individuals only relative to 
#'  some other quantity. To deal with this, we can use the average inbreeding 
#'  coefficient of the diagonal elements as the reference value. For this, the 
#'  function subtracts 1 from the mean of the diagonal elements of the GRM. In a
#'   second step, the off-diagonal elements are divided by 2, and finally, the 
#'   mean of the diagonal elements is subtracted from each off-diagonal element 
#'   after dividing them by 2. This approach is similar to the one used by 
#'   Goudet et al. (2018).
#'   
#' Below is a table modified from Speed & Balding (2015) showing kinship values,
#'  and their confidence intervals (CI), for different relationships that could 
#'  be used to guide the choosing of the relatedness threshold in the function.
#'
#'|Relationship                               |Kinship  |     95% CI       |
#'
#'|Identical twins/clones/same individual     | 0.5     |        -         |
#'
#'|Sibling/Parent-Offspring                   | 0.25    |    (0.204, 0.296)|
#'
#'|Half-sibling                               | 0.125   |    (0.092, 0.158)|
#'
#'|First cousin                               | 0.062   |    (0.038, 0.089)|
#'
#'|Half-cousin                                | 0.031   |    (0.012, 0.055)|
#'
#'|Second cousin                              | 0.016   |    (0.004, 0.031)|
#'
#'|Half-second cousin                         | 0.008   |    (0.001, 0.020)|
#' 
#'|Third cousin                               | 0.004   |    (0.000, 0.012)|
#'
#'|Unrelated                                  | 0       |        -         | 
#'
#' Four layout options are implemented in this function:
#'\itemize{
#'\item 'fr' Fruchterman-Reingold layout  \link[igraph]{layout_with_fr}
#' (package igraph)
#'\item 'kk' Kamada-Kawai layout \link[igraph]{layout_with_kk} (package igraph)
#'\item 'gh' Graphopt layout \link[igraph]{layout_with_graphopt}
#'(package igraph)
#'\item 'mds' Multidimensional scaling layout \link[igraph]{layout_with_mds}
#' (package igraph)
#' }
#'
#' @return A network plot showing relatedness between individuals
#' @author Custodian: Arthur Georges -- Post to
#' \url{https://groups.google.com/d/forum/dartr}
#' @examples
#' if (requireNamespace("igraph", quietly = TRUE) & requireNamespace("rrBLUP",
#' quietly = TRUE) & requireNamespace("fields", quietly=TRUE)) {
#' t1 <- possums.gl
#' # filtering on call rate 
#' t1 <- gl.filter.callrate(t1)
#' t1 <- gl.subsample.loci(t1,n = 100)
#' # relatedness matrix
#' res <- gl.grm(t1,plotheatmap = FALSE)
#' # relatedness network
#' res2 <- gl.grm.network(res,t1,relatedness_factor = 0.125)
#' }
#'@references
#'\itemize{
#'\item Endelman, J. B. , Jannink, J.-L. (2012). Shrinkage estimation of the 
#'realized relationship matrix. G3: Genes, Genomics, Genetics 2, 1405.
#'\item Goudet, J., Kay, T., & Weir, B. S. (2018). How to estimate kinship.
#'Molecular Ecology, 27(20), 4121-4135.
#'\item Speed, D., & Balding, D. J. (2015). Relatedness in the post-genomic era: 
#'is it still useful?. Nature Reviews Genetics, 16(1), 33-44.
#'  }
#' @seealso \code{\link{gl.grm}}
#' @family inbreeding functions
#' @export

gl.grm.network <- function(G,
                           x,
                           method = "fr",
                           node.size = 8,
                           node.label = TRUE,
                           node.label.size = 2,
                           node.label.color = "black",
                           link.color = NULL,
                           link.size = 2,
                           relatedness_factor = 0.125,
                  title = "Network based on a genomic relationship matrix",
                           palette_discrete = NULL,
                           save2tmp = FALSE,
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
    
    # FUNCTION SPECIFIC ERROR CHECKING Set a population if none is specified 
    # (such as if the genlight object has been generated manually)
    if (is.null(pop(x)) |
        is.na(length(pop(x))) | length(pop(x)) <= 0) {
        if (verbose >= 2) {
            cat(
                important(
                    "  Population assignments not detected, individuals assigned
                    to a single population labelled 'pop1'\n"
                )
            )
        }
        pop(x) <- array("pop1", dim = nInd(x))
        pop(x) <- as.factor(pop(x))
    }
    
    # check if package is installed
    pkg <- "igraph"
    if (!(requireNamespace(pkg, quietly = TRUE))) {
      cat(error(
        "Package",
        pkg,
        " needed for this function to work. Please install it.\n"
      ))
      return(-1)
    }
    
    if (!(method == "fr" ||
          method == "kk" ||
          method == "gh" || method == "mds")) {
        cat(warn(
     "Warning: Layout method must be one of fr, or kk, gh or mds, set to fr\n"
        ))
        method <- "fr"
    }
    
    # DO THE JOB
    G2 <- G
    G2[upper.tri(G2, diag = TRUE)] <- NA
    links <- as.data.frame(as.table(G2))
    links <- links[which(!is.na(links$Freq)), ]
    
    colnames(links) <- c("from", "to", "weight")
    
    # using the average inbreeding coefficient (1-f) of the diagonal elements as
    #the reference value
    MS <- mean(diag(G) - 1)
    
    # the result of the GRM is the summation of the IBD of each allele .
    links$kinship <- (links$weight / 2) - MS
    
    links_tmp <- links[,c(1,2,4)]
    links_tmp <- rbind(links_tmp,cbind(from=indNames(x),
                                       to=indNames(x),kinship=0))
    links_matrix <- as.matrix(reshape2::acast(links_tmp, 
                                              from~to, value.var="kinship"))
    links_matrix <- apply(links_matrix, 2, as.numeric)
    rownames(links_matrix) <- colnames(links_matrix)
    
    links_plot_tmp <- links_tmp[links_tmp$kinship>relatedness_factor,]
    links_plot_2 <- links_plot_tmp[,c("from","kinship")]
    colnames(links_plot_2) <- c("label.node","kinship")
    links_plot_3 <- links_plot_tmp[,c("to","kinship")]
    colnames(links_plot_3) <- c("label.node","kinship")
    links_plot <- rbind(links_plot_2,links_plot_3)
    
    nodes <- data.frame(cbind(x$ind.names, as.character(pop(x))))
    colnames(nodes) <- c("name", "pop")
    
    network <- igraph::graph_from_data_frame(d = links,
                                      vertices = nodes,
                                      directed = FALSE)
    
    q <- relatedness_factor
    network.FS <-
        igraph::delete_edges(network, igraph::E(network)[links$kinship < q])
    
    if (method == "fr") {
        layout.name <- "Fruchterman-Reingold layout"
        plotcord <-
            data.frame(igraph::layout_with_fr(network.FS))
    }
    
    if (method == "kk") {
        layout.name <- "Kamada-Kawai layout"
        plotcord <-
            data.frame(igraph::layout_with_kk(network.FS))
    }
    
    if (method == "gh") {
        layout.name <- "Graphopt layout"
        plotcord <-
            data.frame(igraph::layout_with_graphopt(network.FS))
    }
    
    if (method == "mds") {
        layout.name <- "Multidimensional scaling layout"
        plotcord <-
            data.frame(igraph::layout_with_mds(network.FS))
    }
    
    # get edges, which are pairs of node IDs
    edgelist <- igraph::get.edgelist(network.FS, names = F)
    # convert to a four column edge data frame with source and destination
    # coordinates
    edges <-
        data.frame(plotcord[edgelist[, 1], ], plotcord[edgelist[, 2], ])
    # using kinship for the size of the edges
    edges$size <- links[links$kinship > q, "kinship"]
    X1 <- X2 <- Y1 <- Y2 <- label.node <- NA
    colnames(edges) <- c("X1", "Y1", "X2", "Y2", "size")
    
    # node labels
    plotcord$label.node <- igraph::V(network.FS)$name
    
    # adding populations
    pop_df <-
        as.data.frame(cbind(indNames(x), as.character(pop(x))))
    colnames(pop_df) <- c("label.node", "pop")
    plotcord <- merge(plotcord, pop_df, by = "label.node")
    plotcord$pop <- as.factor(plotcord$pop)
    
    plotcord <- merge(plotcord,links_plot,by="label.node",all.x = TRUE)
    plotcord[is.na(plotcord$kinship),"kinship"] <- 0
    plotcord$kinship <- as.numeric(plotcord$kinship)
    plotcord$kinship <- scales::rescale(plotcord$kinship, to = c(0.1, 1))
    
    # assigning colors to populations
    if(is.null(palette_discrete)){
      palette_discrete <- discrete_palette
    }
    
    if (is(palette_discrete, "function")) {
        colors_pops <- palette_discrete(length(levels(pop(x))))
    }
    
    if (!is(palette_discrete, "function")) {
        colors_pops <- palette_discrete
    }
    
    if(is.null(link.color)){
      link.color <- diverging_palette
    }
    
    names(colors_pops) <- as.character(levels(x$pop))
    pal <- link.color(10)
    size <- NULL
    p1 <-
        ggplot() + 
      geom_segment(data = edges,
                   aes( x = X1, y = Y1, xend = X2,yend = Y2,color = size),
                   size = link.size) +
      scale_colour_gradientn(name = "Relatedness",colours = pal) + 
      geom_point(data = plotcord,aes(x = X1,y = X2, fill = pop), 
                  pch = 21,
                 size = node.size,
                 alpha=plotcord$kinship) +
      scale_fill_manual(name = "Populations", values = colors_pops)+
      coord_fixed(ratio = 1) + 
      theme_void() +
      ggtitle(paste(title, "\n[", layout.name, "]")) + 
      theme(legend.position = "bottom",
            plot.title = element_text( hjust = 0.5, face = "bold",size = 14)) 
    
    if (node.label == T) {
        p1 <-
            p1 + geom_text(
                data = plotcord,
                aes(
                    x = X1,
                    y = X2,
                    label = label.node
                ),
                size = node.label.size,
                show.legend = FALSE,
                color = node.label.color
            )
    }
    
    # PRINTING OUTPUTS
    print(p1)
    
    # SAVE INTERMEDIATES TO TEMPDIR
    if (save2tmp) {
        # creating temp file names
        temp_plot <- tempfile(pattern = "Plot_")
        match_call <-
            paste0(names(match.call()),
                   "_",
                   as.character(match.call()),
                   collapse = "_")
        # saving to tempdir
        saveRDS(list(match_call, p1), file = temp_plot)
        if (verbose >= 2) {
            cat(report("  Saving the ggplot to session tempfile\n"))
            cat(
                report(
                    "  NOTE: Retrieve output files from tempdir using 
                    gl.list.reports() and gl.print.reports()\n"
                )
            )
        }
    }
    
    # FLAG SCRIPT END
    
    if (verbose >= 1) {
        cat(report("Completed:", funname, "\n"))
    }
    
    # RETURN
    
    return(invisible(list(p1,links_matrix)))
    
}
