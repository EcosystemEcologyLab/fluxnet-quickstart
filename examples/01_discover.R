## examples/01_discover.R
## Worked Example 1: Discover and filter FLUXNET sites
##
## This script shows you how to query the FLUXNET registry to see what sites
## are available and filter them to a subset relevant to your research question.
##
## What you will learn:
##   - What FLUXNET sites are and how they are organized
##   - How to get the full list of available sites from the FLUXNET shuttle
##   - How to filter by ecosystem type (IGBP class)
##   - How to filter by data record length
##   - Why saving your manifest matters for reproducibility
##
## Prerequisites:
##   - R 4+ installed (4.6 recommended)
##   - fluxnet package: remotes::install_github("EcosystemEcologyLab/fluxnet-package")
##   - dplyr, readr packages: install.packages(c("dplyr", "readr"))
##
## Run this script from the root of your copy of this repository.

library(fluxnet)
library(dplyr)
library(readr)

## IMPORTANT — source this file in its entirety; do not run it line-by-line.
## RStudio : Ctrl+Shift+Enter (Cmd+Shift+Enter on Mac) with this file open.
## Console : source("examples/01_discover.R")
## Stepping through line by line bypasses the working-directory check below.

if (!dir.exists("R")) stop(
  "It looks like this script is being run from the wrong directory. ",
  "Open the fluxnet-quickstart project root before running examples."
)

## ---- What is FLUXNET? --------------------------------------------------------
##
## FLUXNET is a global network of eddy covariance flux towers. Each tower
## measures the exchange of carbon dioxide, water vapor, and energy between
## ecosystems and the atmosphere at 30-minute or 60-minute intervals,
## continuously for years to decades.
##
## Sites span every major ecosystem type on Earth: forests, grasslands,
## croplands, wetlands, tundra, and more. They are operated by regional
## networks — AmeriFlux (Americas), ICOS (Europe), TERN (Australia), and
## several others — that coordinate data processing and sharing.
##
## The FLUXNET Shuttle (launched May 2026) is the new canonical way to access
## this data. Instead of static dataset releases (like FLUXNET2015), the
## shuttle provides continuously updated access to processed data from all
## contributing networks. It is the authoritative source for the FLUXNET
## Annual 2026 paper.

## ---- Step 1: Get the full registry from the shuttle -------------------------
##
## flux_listall() contacts the FLUXNET shuttle and returns a data frame
## describing every site currently available. This requires an internet
## connection and takes about 30-60 seconds on first run (it fetches from
## multiple regional network servers).
##
## The returned data frame has one row per site with columns including:
##   site_id       : unique site identifier (e.g., "US-Ha1", "DE-Tha", "AU-How")
##   site_name     : human-readable site name
##   igbp          : International Geosphere-Biosphere Programme land cover class
##                   (e.g., "ENF" = evergreen needleleaf forest)
##   data_hub      : contributing network (AmeriFlux, ICOS, TERN, etc.)
##   first_year    : first year of available data
##   last_year     : last year of available data
##   location_lat  : latitude (decimal degrees)
##   location_long : longitude (decimal degrees)
##   product_citation : pre-formatted citation string for this site's dataset

message("Fetching the full FLUXNET site registry from the shuttle...")
message("This takes 30-60 seconds on first run.\n")

manifest <- flux_listall()

message("Done. Sites available: ", nrow(manifest))
message("Columns in manifest:   ", paste(names(manifest), collapse = ", "), "\n")

## ---- Step 2: Save your manifest immediately ----------------------------------
##
## This is not optional. Saving the manifest now means that even if the FLUXNET
## registry changes (new sites added, data reprocessed, sites removed), you have
## a record of exactly what was available and cited when you ran your analysis.
##
## This is the same principle as saving a package version in renv.lock or
## pinning a Python requirement. Science requires reproducibility: the data you
## cite must match the data you downloaded.
##
## The file data/my_manifest.csv is intentionally not gitignored in this
## template — it is small (< 1 MB) and worth committing to your fork so future
## you (or a collaborator) can reproduce your site selection.

dir.create("data", showWarnings = FALSE)
write_csv(manifest, "data/my_manifest.csv")
message("Manifest saved to: data/my_manifest.csv")
message("  (commit this file to your repository for reproducibility)\n")

## ---- Step 3: Explore what's available ----------------------------------------

## How many sites per hub?
message("=== Sites per data hub ===")
manifest |>
  count(data_hub, sort = TRUE) |>
  print()

## What IGBP land cover types are available?
##
## IGBP classes are a standard ecosystem classification system. Common ones in
## FLUXNET:
##   ENF = Evergreen Needleleaf Forest (boreal, temperate conifer)
##   EBF = Evergreen Broadleaf Forest  (tropical, Mediterranean)
##   DBF = Deciduous Broadleaf Forest  (temperate broadleaf)
##   MF  = Mixed Forest
##   OSH = Open Shrubland
##   CSH = Closed Shrubland
##   WSA = Woody Savanna
##   SAV = Savanna
##   GRA = Grassland
##   WET = Permanent Wetland
##   CRO = Cropland
##   URB = Urban
##   SNO = Snow and Ice
##   BSV = Barren or Sparsely Vegetated
##   WAT = Water Bodies

message("\n=== Sites per IGBP land cover class ===")
manifest |>
  count(igbp, sort = TRUE) |>
  print()

## Data record length
manifest <- manifest |>
  mutate(record_length = last_year - first_year + 1)

message("\n=== Record length summary (years) ===")
summary(manifest$record_length) |> print()

## ---- Step 4: Filter by IGBP class -------------------------------------------
##
## Suppose you are interested in evergreen needleleaf forests (ENF) — boreal
## and temperate conifer sites. Filter the manifest to just those sites.

enf_sites <- manifest |>
  filter(igbp == "ENF")

message("\n=== Evergreen Needleleaf Forest (ENF) sites ===")
message("Count: ", nrow(enf_sites))
message("Hubs:  ", paste(sort(unique(enf_sites$data_hub)), collapse = ", "))
message("Record range: ", min(enf_sites$first_year), " to ", max(enf_sites$last_year))

## ---- Step 5: Filter by record length -----------------------------------------
##
## Long records are valuable for trend detection, interannual variability
## analysis, and understanding ecosystem responses to climate change.
## Filter to sites with at least 10 years of data.

long_record_sites <- manifest |>
  filter(record_length >= 10)

message("\n=== Sites with >= 10 years of data ===")
message("Count: ", nrow(long_record_sites))
message("Mean record length: ", round(mean(long_record_sites$record_length), 1), " years")

## ---- Step 6: Combine filters -------------------------------------------------
##
## Combine both filters: ENF sites with >= 10 years of data.
## These are long-term conifer forest monitoring sites — the kind of sites
## useful for studying forest carbon uptake trends.

enf_long <- manifest |>
  filter(igbp == "ENF", record_length >= 10)

message("\n=== Long-record ENF sites (>= 10 years) ===")
message("Count: ", nrow(enf_long))

enf_long |>
  select(site_id, site_name, data_hub, first_year, last_year, record_length,
         location_lat, location_long) |>
  arrange(desc(record_length)) |>
  print(n = 20)

## ---- What's next? ------------------------------------------------------------
##
## You now have:
##   - data/my_manifest.csv : the full FLUXNET registry at this moment in time
##
## The manifest tells you what is available but does not download any data.
## The next example (examples/02_download.R) will use this manifest to download
## actual flux data for a small set of sites.
##
## Before running example 02, commit data/my_manifest.csv to your repository:
##   git add data/my_manifest.csv
##   git commit -m "Add FLUXNET manifest snapshot"
##
## Then open examples/02_download.R.

message("\n=== Next step ===")
message("Commit data/my_manifest.csv, then open examples/02_download.R")
