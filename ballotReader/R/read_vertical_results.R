#' read_vertical_results
#'
#' Reads election results from .pdf files where column titles are formatted vertically.
#'
#' Vertically formatted text is often formatted incorrectly when converting
#' .pdf files to tabular data formats such as data.frames and tibbles. This
#' function includes additional parameters to help generate well-formatted
#' data.frames for a single race from .pdfs containing election results with
#' vertical column headers.
#'
#' @author Alyssa Savo
#'
#' @param file A URL or path to a .pdf file.
#' @param range An integer vector specifying the pages in the PDF for the race of interest. There currently is not a way to read multiple races at once.
#' @param colnames A character vector containing the names for each column.
#'
#' @examples
#' file <- "data/dem_primary_essex_17.pdf"
#' read_vertical_results(file, range = c(1:11), colnames = c("Municipality","Registration","Ballots Cast","Turnout (%)","Philip MURPHY","William BRENNAN","John S. WISNIEWSKI","Jim Johnson","Mark ZINNA","Raymond J. LESNIAK","Write-In"))
#'
#' @export
#'

read_vertical_results <- function(file, range, colnames) {
  `%>%` <- magrittr::`%>%`
  elex <- list()

  # Extract pdf tables into a list of matrices
  pages <- tabulizer::extract_tables(file, pages = range)

  for (i in 1:length(pages)) {
    # Convert to data.frame and add column names
    df <- as.data.frame(pages[[i]])
    names(df) <- colnames
    # Drop final column, which is incorrectly parsed headers
    df <- df[-length(df)]
    elex[[i]] <- df
  }

  # Combine each page from elex list
  all_elex <- as.data.frame(do.call("rbind", elex), stringsAsFactors = FALSE)

  # Gather candidate columns and drop empty rows
  all_elex <- all_elex %>%
    tidyr::gather(key = "Vote Choice", value = "Votes", -1) %>%
    dplyr::mutate(Votes = as.numeric(Votes)) %>%
    fill_na() %>%
    na.omit()
  all_elex
}
