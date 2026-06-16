# =============================================================================
# TEMPORARY UTILITY — to be absorbed into the fluxnet R package
# =============================================================================
# This workaround handles AmeriFlux sites that publish only hourly (HR)
# resolution rather than half-hourly (HH). The fluxnet package will eventually
# handle this transparently; until then, this helper exists to keep student
# workflows running. Expect this file to be removed in a future version of
# this template once the package update lands.
#
# Background: FLUXNET data is published at various temporal resolutions. Most
# sites use half-hourly (HH, 30-minute intervals). A subset of AmeriFlux sites
# publish at hourly (HR, 60-minute intervals) instead. The FLUXNET shuttle
# downloads and extracts both correctly (a separate flux_extract() filename-
# matching bug affecting v0.3.1 was fixed in fluxnet v0.3.2.9000). However,
# flux_discover_files() still labels extracted HR files with time_resolution =
# "HR" in the file inventory. Code that filters the inventory for
# time_resolution == "HH" will silently exclude HR sites. These helper
# functions normalize the inventory so HR sites are not dropped.
# =============================================================================

library(dplyr)

#' Identify which sites in a file inventory are HR (hourly) rather than HH (half-hourly)
#'
#' Use this to check whether any of your downloaded sites need the HR workaround
#' before reading sub-daily data.
#'
#' @param inventory A data frame from flux_discover_files().
#' @return A character vector of site_ids that have HR (not HH) sub-daily files.
identify_hr_sites <- function(inventory) {
  hr_rows <- !is.na(inventory$time_resolution) & inventory$time_resolution == "HR"
  sort(unique(inventory$site_id[hr_rows]))
}

#' Normalize HR (hourly) entries in a flux file inventory to HH (half-hourly)
#'
#' Some AmeriFlux sites publish sub-daily data at hourly (HR, 60-min) resolution
#' rather than the standard half-hourly (HH, 30-min). This function relabels HR
#' entries as HH in the file inventory so that downstream code treats them
#' consistently. The actual data files are unchanged on disk — only the label
#' in the inventory data frame is updated.
#'
#' When the fluxnet package natively handles HR sites, this function will become
#' a no-op and can safely be left in place or removed.
#'
#' @param inventory A data frame returned by flux_discover_files().
#' @return The same data frame with time_resolution "HR" replaced by "HH".
normalize_hr_inventory <- function(inventory) {
  inventory |>
    dplyr::mutate(
      time_resolution = dplyr::if_else(
        !is.na(time_resolution) & time_resolution == "HR",
        "HH",
        time_resolution
      )
    )
}

#' Filter a file inventory to include sub-daily (HH and HR) files
#'
#' When you want to read sub-daily data, use this instead of filtering directly
#' on time_resolution == "HH". It includes both HH and HR entries so that
#' AmeriFlux HR sites are not silently excluded.
#'
#' @param inventory A data frame returned by flux_discover_files().
#' @param datasets Character vector of dataset types to include.
#'   Default is c("ERA5", "FLUXMET") which covers all flux and climate data.
#' @return A filtered data frame containing only sub-daily (HH and HR) rows.
filter_subdaily_inventory <- function(inventory,
                                       datasets = c("ERA5", "FLUXMET")) {
  inventory |>
    dplyr::filter(
      time_resolution %in% c("HH", "HR"),
      dataset %in% datasets,
      !is.na(path),
      nchar(path) > 0,
      file.exists(path)
    )
}
