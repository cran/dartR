#' @name gl.diagnostics.hwe
#' @title Provides descriptive stats and plots to diagnose potential problems
#'   with Hardy-Weinberg proportions
#' @description Different causes may be responsible for lack of Hardy-Weinberg
#' proportions. This function helps diagnose potential problems.
#' @inheritParams gl.report.hwe
#' @inheritParams utils.jackknife
#' @param n.cores The number of cores to use. If "auto", it will 
#' use all but one available cores [default "auto"].
#' @param bins Number of bins to display in histograms [default 20].
#' @param stdErr Whether standard errors for Fis and Fst should be computed 
#' (default: TRUE)
#' @param colors_hist List of two color names for the borders and fill of the
#'   histogram [default two_colors].
#' @param colors_barplot Vector with two color names for the observed and
#'   expected number of significant HWE tests [default two_colors_contrast].
#' @param plot_theme User specified theme [default theme_dartR()].
#' @details This function initially runs \code{\link{gl.report.hwe}} and reports
#' the ternary plots. The remaining outputs follow the recommendations from
#'  Waples
#' (2015) paper and De Meeûs 2018. These include: 
#' \enumerate{ 
#' \item A histogram
#' with the distribution of p-values of the HWE tests. The distribution should
#' be roughly uniform across equal-sized bins. 
#' \item A bar plot with observed
#' and expected (null expectation) number of significant HWE tests for the same
#' locus in multiple populations (that is, the x-axis shows whether a locus
#' results significant in 1, 2, ..., n populations. The y axis is the count of
#' these occurrences. The zero value on x-axis shows the number of
#' non-significant tests). If HWE tests are significant by chance alone,
#' observed and expected number of HWE tests should have roughly a similar
#' distribution. 
#' \item A scatter plot with a linear regression between Fst and Fis,
#'  averaged across subpopulations. De Meeûs 2018 suggests that in the case of
#' Null alleles, a strong positive relationship is expected (together with the
#' Fis standard error much larger than the Fst standard error, see below).
#' \bold{Note}, this is not the scatter plot that Waples 2015 presents in his
#' paper. In the lower right corner of the plot, the Pearson correlation
#' coefficient is reported. 
#' \item The Fis and Fst (averaged over loci and
#' subpopulations) standard errors are also printed on screen and reported in
#' the returned list (if \code{stdErr=TRUE}). These are computed with the 
#' Jackknife method over loci (See De Meeûs 2007 for details on how this is 
#' computed) and it may take some time for these computations to complete. 
#' De Meeûs 2018 suggests that under a global significant heterozygosity 
#' deficit: 
#' 
#' - if the
#' correlation between Fis and Fst is strongly positive, and StdErrFis >>
#' StdErrFst, Null alleles are likely to be the cause. 
#' 
#' - if the correlation
#' between Fis and Fst is ~0 or mildly positive, and StdErrFis > StdErrFst,
#' Wahlund may be the cause. 
#' 
#' - if the correlation between Fis and Fst is ~0, and
#' StdErrFis ~ StdErrFst, selfing or sib mating could to be the cause.
#' 
#'  It is
#' important to realise that these statistics only suggest a pattern (pointers).
#' Their absence is not conclusive evidence of the absence of the problem, as 
#' their presence does not confirm the cause of the problem. 
#' \item A table where the
#' number of observed and expected significant HWE tests are reported by each
#' population, indicating whether these are due to heterozygosity excess or
#' deficiency. These can be used to have a clue of potential problems (e.g.
#' deficiency might be due to a Wahlund effect, presence of null alleles or
#' non-random sampling; excess might be due to sex linkage or different
#' selection between sexes, demographic changes or small Ne. See Table 1 in
#' Wapples 2015). The last two columns of the table generated by this function
#' report chisquare values and their associated p-values. Chisquare is computed
#' following Fisher's procedure for a global test (Fisher 1970). This basically
#' tests whether there is at least one test that is truly significant in the
#' series of tests conducted (De Meeûs et al 2009).
#' }
#' @return A list with the table with the summary of the HWE tests and (if 
#' stdErr=TRUE) a named vector with the StdErrFis and StdErrFst.
#' @author Custodian: Carlo Pacioni -- Post to
#'   \url{https://groups.google.com/d/forum/dartr}
#' @examples
#' \dontrun{
#' require("dartR.data")
#' res <- gl.diagnostics.hwe(x = gl.filter.allna(platypus.gl[,1:50]), 
#' stdErr=FALSE, n.cores=1)
#' }
#' @references \itemize{ 
#' \item de Meeûs, T., McCoy, K.D., Prugnolle, F.,
#' Chevillon, C., Durand, P., Hurtrez-Boussès, S., Renaud, F., 2007. Population
#' genetics and molecular epidemiology or how to “débusquer la bête”. Infection,
#' Genetics and Evolution 7, 308-332. 
#' \item De Meeûs, T., Guégan, J.-F., Teriokhin, A.T., 2009. MultiTest V.1.2, 
#' a program to binomially combine independent tests and performance comparison 
#' with other related methods on
#' proportional data. BMC Bioinformatics 10, 443-443. 
#' \item De Meeûs, T., 2018. Revisiting FIS, FST, Wahlund Effects, and Null 
#' Alleles. Journal of Heredity 109, 446-456.
#' \item Fisher, R., 1970.
#' Statistical methods for research workers Edinburgh: Oliver and Boyd. 
#' \item
#' Waples, R. S. (2015). Testing for Hardy–Weinberg proportions: have we lost
#' the plot?. Journal of heredity, 106(1), 1-19.
#'  }
#' @seealso \code{\link{gl.report.hwe}}
#' @family reporting functions
#' @rawNamespace import(data.table, except = c(melt,dcast))
#' @export

gl.diagnostics.hwe <- function(x,
                               alpha_val = 0.05,
                               bins = 20,
                               stdErr = TRUE,
                               colors_hist = two_colors,
                               colors_barplot = two_colors_contrast,
                               plot_theme = theme_dartR(),
                               save2tmp = FALSE,
                               n.cores = "auto",
                               verbose = NULL) {
  # SET VERBOSITY
  verbose <- gl.check.verbosity(verbose)
  
  # FLAG SCRIPT START
  funname <- match.call()[[1]]
  utils.flag.start(func = funname,
                   build = "Jackson",
                   verbosity = verbose)
  
  # CHECK DATATYPE
  datatype <- utils.check.datatype(x, verbose = verbose)
  
  # DO THE JOB
  # Set NULL to variables to pass CRAN checks
  Prob<-Sig<-N<-Locus<-Population<-Freq<-Data<-dumpop<-Deficiency<-Fis<-
    Excess<-pvalue<-ChiSquare<-Fst<-gen <-He <-value<- variable <-fst_obs<-NULL
  
  # Helper function
  extractParam <- function(i, l, param) {
    return(l[[i]][["overall"]][param])
  }
  
  # Distribution of p-values by equal bins
  suppressWarnings(hweout <- gl.report.hwe(x, sig_only = F, verbose = 0))
  
  p1 <-   ggplot(hweout, aes(Prob)) +
    geom_histogram(bins = bins,
                   color = colors_hist[1],
                   fill = colors_hist[2]) +
    geom_hline(
      aes(
        yintercept = nrow(hweout) / (bins - 1),
        linetype = "Mean number\nof significant\nHWE tests"
      ),
      col = "red",
      size = 1
    ) +
    scale_linetype_manual(name = "", values = 'solid') +
    coord_cartesian(xlim = c(0, 1)) +
    xlab("Probability of departure from H-W proportions") +
    ylab("Count") +
    ggtitle("Distribution of p-values of HWE tests") +
    plot_theme
  
  # Fst vs Fis scatter plot with linear regression
  # lpops <- seppop(x)
  # lFstats <- lapply(lpops, utils.basic.stats, verbose = 0)
  # lFstats <- lapply(lFstats, "[[", "perloc")
  # Fstats <- rbindlist(l = lFstats, use.names = TRUE, idcol = TRUE)
  Fstats <- utils.basic.stats(x)
  
  # Number of loci out of HWE as a function of a population
  hweout.dt <- data.table(hweout)
  nTimesBypop <- hweout.dt[, .N, by = c("Locus", "Sig")]
  setkey(nTimesBypop, Sig)
  
  nTimesBypop.df <- as.data.frame(table(nTimesBypop["sig", N]))
  
  # Include the non-sig tests
  nTimesBypop.df <-
    rbind(data.frame(Var1 = 0, Freq = nTimesBypop["no_sig", sum(N)]),
          nTimesBypop.df)
  nTimesBypop.df$Data <- "Observed"
  
  # Generate the null distribution
  nullDist <-
    as.data.frame(table(rbinom(
      length(hweout.dt[, unique(Locus)]),
      size = length(hweout.dt[, unique(Population)]),
      prob = alpha_val
    )))
  nullDist$Data <- "Null expectation"
  
  # Compile the data for the plot
  nTimesBypop.fin <- rbind(nTimesBypop.df, nullDist)
  names(nTimesBypop.fin)[1] <- "nPop"
  nTimesBypop.fin$nPop <- factor(as.integer(nTimesBypop.fin$nPop))
  
  p2 <- ggplot(nTimesBypop.fin, aes(nPop, Freq, fill = Data)) +
    geom_col(position = "dodge2",
             alpha = 0.85,
             color = "black") +
    scale_fill_manual(values = c("Observed" = colors_barplot[1],
                                 "Null expectation" = colors_barplot[2])) +
    scale_y_log10() +
    xlab("Number of populations in which loci depart from HWE") +
    ylab("Count") +
    ggtitle(label =  "Number of significant HWE tests for\nthe same locus in 
            multiple populations")+
    plot_theme 
  
  # Collate HWE tests and Fis per locus and pop
  FisPops <- data.table(Fstats$Fis, keep.rownames = TRUE)
  
  # fix the headings when there is only one pop
  if (length(levels(pop(x))) == 1) {
    FisPops[, dumpop := NULL]
    setnames(FisPops, "1", levels(pop(x)))
  }
  setnames(FisPops, "rn", "Locus")
  FisPopsLong <-
    data.table::melt(
      FisPops,
      id.vars = "Locus",
      variable.name = "Population",
      value.name = "Fis"
    )
  #  FisPopsLong[, Locus := sub("^X", "", Locus)]
  # hweout.dt[, Locus := gsub("-|/", replacement = ".", x = Locus)]
  hwe_Fis <- merge(hweout.dt, FisPopsLong, by = c("Locus", "Population"))
  hwe_Fis[, Deficiency := Fis > 0]
  hwe_Fis[,  Excess := Fis < 0]
  setkey(hwe_Fis, Sig)
  
  hwe_summary <-
    hwe_Fis["sig", .(
      nSig = .N,
      nExpected = alpha_val * nLoc(x),
      Deficiency = sum(Deficiency, na.rm = TRUE),
      Excess = sum(Excess, na.rm = TRUE),
      PropDeficiency = sum(Deficiency, na.rm = TRUE) /
        .N
    ),
    by = Population]
  
  chsq <-
    hwe_Fis[, .(ChiSquare = -2 * (sum(log(Prob)))), by = Population]
  chsq[, pvalue := pchisq(ChiSquare, 2 * nLoc(x), lower.tail = FALSE)]
  hwe_summary <- merge(hwe_summary, chsq, by = "Population")
  
  # Fis vs Fst plot
  
  corr <- round(cor(Fstats$perloc$Fis, Fstats$perloc$Fst, 
                    "pairwise.complete.obs"), 3)
  p3 <- ggplot(Fstats$perloc, aes(Fst, Fis)) + 
    geom_point(size=2,color=colors_barplot[1],alpha=0.5) + 
    geom_smooth(method = "lm",color=colors_barplot[2],fill=colors_barplot[2],
                size=1) +
    annotate("text", 
             x=min(Fstats$perloc$Fst, na.rm = TRUE) +
               (max(Fstats$perloc$Fst, na.rm = TRUE) - 
                  min(Fstats$perloc$Fst, na.rm = TRUE))*0.75, 
             y = min(Fstats$perloc$Fis, na.rm = TRUE) +
               (max(Fstats$perloc$Fis, na.rm = TRUE) -
                  min(Fstats$perloc$Fis, na.rm = TRUE))*0.25, 
             col="black",
             label= paste("r: ", corr,sep=""),parse=TRUE,
             size=4) +
    xlab("Fst") +
    ylab("Fis") +
    ggtitle("Fst vs Fis by locus") +
    plot_theme
  if(stdErr) {
    jck <- utils.jackknife(x, FUN="utils.basic.stats", unit="loc", 
                           n.cores = n.cores)
    
    jckFst <- sapply(seq_len(nLoc(x)), extractParam, l=jck, param="Fst")
    jckFis <- sapply(seq_len(nLoc(x)), extractParam, l=jck, param="Fis")
    stdErrFst <- sqrt(var(jckFst)/nLoc(x))
    stdErrFis <- sqrt(var(jckFis)/nLoc(x)) 
    
    cat(report("The variation of Fis and Fst, respectively\n (measured as 
               standard error with the Jackknife method - see De Meeus 2018) 
               is:",
               paste(c(stdErrFis, stdErrFst), collapse = ", "), "\n Fis vs Fst 
               ratio is:", 
               round(stdErrFis/stdErrFst, 2), "\n"))
  }
  
  # PRINTING OUTPUTS
  # using package patchwork
  p5 <- (p1 / p2 / p3)
  print(p5)
  
  print(hwe_summary, row.names = FALSE)
  
  # SAVE INTERMEDIATES TO TEMPDIR
  
  # creating temp file names
  if (save2tmp) {
    temp_plot <- tempfile(pattern = "Plot_")
    match_call <-
      paste0(names(match.call()),
             "_",
             as.character(match.call()),
             collapse = "_")
    # saving to tempdir
    saveRDS(list(match_call,p5), file = temp_plot)
    
    if (verbose >= 2) {
      cat(report("  Saving the ggplot to session tempfile\n"))
    }
    
    temp_table <- tempfile(pattern = "Table_")
    saveRDS(list(match_call, hwe_summary), file = temp_table)
    
    if (verbose >= 2) {
      cat(report("  Saving tabulation to session tempfile\n"))
      cat(
        report(
          "  NOTE: Retrieve output files from tempdir using gl.list.reports() 
          and gl.print.reports()\n"
        )
      )
    }
  }
  
  # FLAG SCRIPT END
  
  if (verbose >= 1) {
    cat(report("Completed:", funname, "\n"))
  }
  
  # RETURN
  if(stdErr) {
    StdErr <- c(stdErrFis, stdErrFst)
    names(StdErr) <- c(c("stdErrFis", "stdErrFst"))
    return(invisible(list(hwe_summary=hwe_summary, StdErr=StdErr)))
  } else {
    return(invisible(list(hwe_summary=hwe_summary)))
  }
  
  
  
}
