## examples/02_download.R
## Worked Example 2: Download FLUXNET data for a set of sites
##
## This script shows you how to download FLUXNET flux data for a small set of
## sites using the manifest you created in example 01.
##
## What you will learn:
##   - How to select a subset of sites to download
##   - The AmeriFlux credential system and why it exists
##   - How to download and extract FLUXNET data
##   - How to handle AmeriFlux sites that publish hourly (HR) instead of
##     half-hourly (HH) data (the HR workaround)
##
## Prerequisites:
##   - Complete examples/01_discover.R first (creates data/my_manifest.csv)
##   - fluxnet package installed
##   - dplyr, readr packages installed
##
## Run this script from the root of your copy of this repository.

library(fluxnet)
library(dplyr)
library(readr)

## IMPORTANT — source this file in its entirety; do not run it line-by-line.
## RStudio : Ctrl+Shift+Enter (Cmd+Shift+Enter on Mac) with this file open.
## Console : source("examples/02_download.R")
## Stepping through line by line bypasses source() calls that load helper
## functions, causing "could not find function" errors later in the script.

if (!dir.exists("R")) stop(
  "It looks like this script is being run from the wrong directory. ",
  "Open the fluxnet-quickstart project root before running examples."
)

## Load the HR workaround helper (handles AmeriFlux hourly vs half-hourly sites)
source("R/hr_workaround.R")

## ---- Load your manifest from example 01 -------------------------------------

if (!file.exists("data/my_manifest.csv")) {
  stop(
    "data/my_manifest.csv not found.\n",
    "Run examples/01_discover.R first to create it."
  )
}

manifest <- read_csv("data/my_manifest.csv", show_col_types = FALSE)
message("Manifest loaded: ", nrow(manifest), " sites available\n")

## ---- Step 1: Select a small set of sites to download ------------------------
##
## For this worked example we download five sites that together illustrate
## the range of FLUXNET's global coverage:
##
##   US-Ha1  Harvard Forest, Massachusetts — long-running AmeriFlux deciduous
##           broadleaf forest; one of the most-studied carbon flux sites in
##           the world. Evergreen needleleaf understory under deciduous canopy.
##
##   DE-Tha  Tharandt, Germany — ICOS spruce forest; continuous record since
##           1996. Flagship European conifer site.
##
##   AU-How  Howard Springs, Northern Territory — TERN savanna site in tropical
##           Australia. The longest savanna eddy covariance record in the
##           Southern Hemisphere.
##
##   US-MMS  Morgan Monroe State Forest, Indiana — AmeriFlux deciduous
##           broadleaf forest. NOTE: US-MMS publishes at hourly (HR) resolution
##           rather than the standard half-hourly (HH). The HR workaround
##           function in R/hr_workaround.R handles this correctly.
##
##   FR-Fon  Fontainebleau-Barbeau, France — ICOS deciduous broadleaf forest
##           near Paris. Representative of European temperate forest.
##
## These five sites span three networks (AmeriFlux, ICOS, TERN), three
## continents, and two temporal resolutions (HH and HR). They are a manageable
## download size for a worked example (~500 MB total).

my_sites <- c("US-Ha1", "DE-Tha", "AU-How", "US-MMS", "FR-Fon")

## Subset the manifest to only the sites we want
download_manifest <- manifest |>
  filter(site_id %in% my_sites)

## Confirm all requested sites are in the manifest
missing_sites <- setdiff(my_sites, download_manifest$site_id)
if (length(missing_sites) > 0) {
  warning(
    "The following sites were not found in the manifest:\n  ",
    paste(missing_sites, collapse = ", "),
    "\nThe manifest may be out of date — re-run examples/01_discover.R."
  )
}

message("Downloading ", nrow(download_manifest), " sites:")
for (s in download_manifest$site_id) {
  message("  ", s, " — ",
    download_manifest$site_name[download_manifest$site_id == s],
    " (", download_manifest$data_hub[download_manifest$site_id == s], ")"
  )
}
message()

## ---- Step 2: AmeriFlux credentials — please provide them --------------------
##
## The FLUXNET shuttle will download data from any participating network without
## any authentication. However, the AmeriFlux community specifically requests
## (but does not technically require) that users provide a name, email address,
## and intended-use description when downloading AmeriFlux data.
##
## Why does this matter?
##   AmeriFlux is supported by the U.S. Department of Energy's Office of
##   Science. To continue receiving funding, the AmeriFlux network needs to
##   demonstrate community impact: who uses the data, from which institutions,
##   for what purposes. When you provide credentials, you contribute to that
##   accounting. This directly supports the scientists who operate the towers
##   and share their data.
##
## It is a community norm, not a technical requirement. But please do it.
##
## How to provide credentials:
##   Set two environment variables before running this script. The easiest way
##   is to create a file called .env in the root of your project:
##
##     AMERIFLUX_USER_NAME=Your Full Name
##     AMERIFLUX_USER_EMAIL=you@institution.edu
##
##   Then load them at the start of your script with:
##     if (file.exists(".env")) dotenv::load_dot_env()
##
##   If you are just exploring and do not want to provide credentials yet,
##   comment out the flux_amf_credentials() call and the user_info argument
##   to flux_download() below. You can still download the data — you will
##   just not be counted in the AmeriFlux usage statistics.
##
## Do not commit your .env file to git. It is already listed in .gitignore.
## If you need to share your workflow with collaborators, each person provides
## their own credentials via their own .env file.

## Load credentials from environment variables (set these in your .env file)
if (file.exists(".env")) {
  if (requireNamespace("dotenv", quietly = TRUE)) {
    dotenv::load_dot_env()
  } else {
    message("Tip: install.packages('dotenv') to load .env files automatically.")
  }
}

## Build the AmeriFlux credential object.
## flux_amf_credentials() reads from AMERIFLUX_USER_NAME and
## AMERIFLUX_USER_EMAIL environment variables. If these are not set, it
## uses empty strings — which still works for downloading but is discouraged.
amf_creds <- flux_amf_credentials()

if (!nzchar(Sys.getenv("AMERIFLUX_USER_NAME"))) {
  message(
    "NOTE: AMERIFLUX_USER_NAME is not set. Please set it in a .env file.\n",
    "  See the 'AmeriFlux credentials' section above for instructions.\n"
  )
}

## ---- Step 3: Create directories ---------------------------------------------

dir.create("data/raw",       showWarnings = FALSE, recursive = TRUE)
dir.create("data/extracted", showWarnings = FALSE, recursive = TRUE)
dir.create("output",         showWarnings = FALSE, recursive = TRUE)

## ---- Step 4: Download -------------------------------------------------------
##
## flux_download() fetches the ZIP archives for each site from the FLUXNET
## shuttle. Each ZIP contains multiple CSV files at different temporal
## resolutions (yearly, monthly, weekly, daily, half-hourly or hourly).
##
## The resolutions argument controls which resolution files are extracted
## from the ZIP. Common codes:
##   "y"  = yearly (YY)
##   "m"  = monthly (MM)
##   "w"  = weekly (WW)
##   "d"  = daily (DD)
##   "h"  = sub-daily (HH or HR, depending on the site)
##
## For this example we extract yearly, monthly, and daily data only ("y m d").
## This keeps the extracted files small. If you need half-hourly or hourly
## data, add "h" to the resolutions string.

message("=== Downloading ZIP archives ===")
flux_download(
  file_list_df = download_manifest,
  download_dir = "data/raw",
  user_info    = amf_creds
)

## ---- Step 5: Extract --------------------------------------------------------
##
## flux_extract() unzips the downloaded archives and places the CSV files in
## data/extracted/. It also filters by resolution at extraction time, so
## you only unzip the resolutions you need.

message("\n=== Extracting ZIP archives ===")
flux_extract(
  zip_dir     = "data/raw",
  output_dir  = "data/extracted",
  resolutions = c("y", "m", "d")   # add "h" here if you want sub-daily
)

## ---- Step 6: Discover extracted files and apply the HR workaround ----------
##
## flux_discover_files() scans the extracted directories and returns a data
## frame (the "file inventory") describing every CSV file found. This inventory
## tells downstream functions where each file is and what resolution / dataset
## it contains.
##
## For the five sites in this example, the inventory will include:
##   time_resolution = "YY"  for yearly files
##   time_resolution = "MM"  for monthly files
##   time_resolution = "DD"  for daily files
##   time_resolution = "HR"  for US-MMS (hourly, not half-hourly!)
##
## The HR workaround (R/hr_workaround.R) normalizes "HR" -> "HH" in the
## inventory so that US-MMS is treated consistently alongside HH sites.
## This matters when you filter the inventory for sub-daily data.
## For yearly/monthly/daily data (which is all we extracted here), the
## workaround has no effect — it is harmless to apply regardless.

message("\n=== Discovering extracted files ===")
inventory <- flux_discover_files("data/extracted")

## Report any HR sites found
if (!exists("identify_hr_sites")) stop(
  "R/hr_workaround.R was not sourced. This script must be sourced as a whole ",
  "from the project root, not run line-by-line."
)
hr_sites <- identify_hr_sites(inventory)
if (length(hr_sites) > 0) {
  message(
    "HR (hourly) sites found: ", paste(hr_sites, collapse = ", "), "\n",
    "  These sites publish at 60-minute resolution instead of 30-minute.\n",
    "  The normalize_hr_inventory() function will treat them as HH downstream."
  )
}

## Apply the normalization (safe to call even if no HR sites are present)
inventory <- normalize_hr_inventory(inventory)

## Save the inventory for use in your own analysis scripts
saveRDS(inventory, "data/file_inventory.rds")

message("\n=== Summary of extracted files ===")
inventory |>
  dplyr::filter(!is.na(time_resolution)) |>
  dplyr::count(time_resolution, dataset) |>
  print()

## ---- Step 7: Save a site list for use in example 03 -------------------------
##
## Write a small CSV with just the site IDs we downloaded. Example 03 will
## use this to generate citations specifically for these five sites.

sites_df <- data.frame(site_id = my_sites)
write_csv(sites_df, "data/my_sites.csv")
message("\nSite list saved to: data/my_sites.csv")

## ---- What's next? ------------------------------------------------------------
##
## You now have:
##   data/raw/            : ZIP archives (you can delete these to save space)
##   data/extracted/      : unzipped CSV files for each site and resolution
##   data/file_inventory.rds : the file inventory for downstream analysis
##   data/my_sites.csv    : your 5-site list for citation generation
##
## To read the data into R, use flux_read() with the inventory:
##   flux_data <- flux_read(inventory, resolution = "YY")
##
## Next: open examples/03_cite.R to generate publication-ready citations
## for the five sites you just downloaded.

message("\n=== Next step ===")
message("Open examples/03_cite.R to generate citations for your downloaded sites.")
