# =============================================================================
# TEMPORARY UTILITY — to be absorbed into the fluxnet R package
# =============================================================================
# What this file does
# -------------------
# A subset of AmeriFlux sites publish sub-daily data at hourly (HR, 60-minute)
# resolution rather than the standard half-hourly (HH, 30-minute). After
# flux_extract() unpacks their ZIP archives, flux_discover_files() labels those
# files with time_resolution = "HR" in the returned inventory data frame. Code
# that filters the inventory for time_resolution == "HH" will silently exclude
# these HR sites — no warning, no error, just missing data.
#
# These three helper functions normalise the inventory so HR sites are included:
#   identify_hr_sites()       — report which sites are HR
#   normalize_hr_inventory()  — relabel "HR" → "HH" in the inventory
#   filter_subdaily_inventory() — filter for sub-daily files including both
#
# The fluxnet package will eventually return a unified label for both HH and HR
# sites. Until then, source this file and call normalize_hr_inventory() on the
# result of flux_discover_files() before any downstream filtering.
#
# Historical note
# ---------------
# A separate, earlier HR-related bug existed in flux_extract() in fluxnet
# v0.3.1: it matched filenames using the pattern "_HH_" (the FLUXNET-2015
# convention) but AmeriFlux FLUXNET v1.3_r1 ships files named "_HR_", so
# flux_extract() silently skipped the sub-daily files entirely. That bug was
# fixed in fluxnet v0.3.2.9000 (commit 2741bb8) and is not relevant for
# current users. A now-retired standalone workaround for that older bug
# (bypassing flux_extract() entirely using zip::unzip()) is preserved for
# reference at davidjpmoore/FluxCourseForecast:
#   data/US-MMS/extract_hr_workaround.R  [RETIRED — kept for reference only]
# Do not confuse it with this file. This file addresses only the post-extraction
# inventory-label distinction, which remains an open issue.
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
