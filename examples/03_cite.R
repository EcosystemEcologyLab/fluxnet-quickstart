## examples/03_cite.R
## Worked Example 3: Generate citations for your FLUXNET data
##
## This script shows you how to generate publication-ready citations,
## acknowledgments, and review flags for the FLUXNET sites you downloaded.
##
## What you will learn:
##   - Why FLUXNET data requires per-site citations (not just a single reference)
##   - How to generate BibTeX entries for every site you use
##   - How to get network-level acknowledgment text
##   - Why the manifest you saved in example 01 is the authoritative citation source
##
## Prerequisites:
##   - Complete examples/01_discover.R first (creates data/my_manifest.csv)
##   - Complete examples/02_download.R first (creates data/my_sites.csv)
##   - dplyr, readr, stringr packages installed:
##     install.packages(c("dplyr", "readr", "stringr"))
##
## The citation generator works from the manifest CSV alone — it does NOT
## require the actual data files to be present on disk.
##
## Run this script from the root of your copy of this repository.

## IMPORTANT — source this file in its entirety; do not run it line-by-line.
## RStudio : Ctrl+Shift+Enter (Cmd+Shift+Enter on Mac) with this file open.
## Console : source("examples/03_cite.R")
## Stepping through line by line bypasses source() calls that load helper
## functions, causing "could not find function" errors later in the script.

if (!dir.exists("R")) stop(
  "It looks like this script is being run from the wrong directory. ",
  "Open the fluxnet-quickstart project root before running examples."
)

## ---- Load the citation generator --------------------------------------------
##
## generate_fluxnet_citations() is a temporary standalone utility vendored in
## R/generate_fluxnet_citations.R. Once the fluxnet package absorbs this
## functionality, you will replace this source() call with library(fluxnet)
## and call the same function directly.

source("R/generate_fluxnet_citations.R")

library(readr)
library(dplyr)

## ---- Check prerequisites ----------------------------------------------------

if (!file.exists("data/my_manifest.csv")) {
  stop(
    "data/my_manifest.csv not found.\n",
    "Run examples/01_discover.R first."
  )
}

if (!file.exists("data/my_sites.csv")) {
  stop(
    "data/my_sites.csv not found.\n",
    "Run examples/02_download.R first, or create a CSV with a 'site_id' column."
  )
}

## ---- Why per-site citations matter ------------------------------------------
##
## When you publish research using FLUXNET data, you are required to cite
## each individual site whose data you used. This is different from most
## databases where a single dataset citation suffices.
##
## The reason is that each site is operated by a distinct team of scientists
## who invest years of field work, instrument maintenance, and data processing.
## The DOI for each site's dataset is how that work gets credited in the
## literature. The site PIs depend on citation counts to demonstrate impact
## to their funding agencies.
##
## The fluxnet-citations tool (vendored in R/generate_fluxnet_citations.R)
## automates this by reading the product_citation and product_id fields from
## the shuttle manifest and formatting them as BibTeX entries.
##
## Three output files are produced:
##   .bib                 : BibTeX file with one @misc entry per site plus
##                          mandated network-level @article references
##   _acknowledgments.md  : Acknowledgment paragraph(s) in Markdown format,
##                          ready to paste into your Methods or Data section
##   _review_flags.md     : Sites needing manual attention before submission
##                          (e.g., missing author blocks, format anomalies)

## ---- Why the manifest you saved is the authoritative source -----------------
##
## Citations are generated from data/my_manifest.csv — the snapshot you saved
## in example 01 — NOT from a live query to the FLUXNET shuttle.
##
## This is intentional and important:
##   - FLUXNET data is continuously updated. New site-years are added, data
##     may be reprocessed, and DOIs may change between versions.
##   - If you generate citations from a live query today, they might not
##     match the data you actually downloaded six months ago.
##   - By using the saved manifest, citations describe the specific version
##     of the data you analyzed — the version that will be reproduced if
##     someone follows your methods.
##
## Always cite from the manifest you saved at download time, not from the
## live registry. This is the same principle as citing a specific DOI version
## rather than a project homepage.

## ---- Step 1: Generate citations for all five downloaded sites ---------------
##
## generate_fluxnet_citations() accepts either:
##   site_ids     = character vector of site IDs
##   site_ids_csv = path to a CSV file with a site_id column
##
## We use the my_sites.csv created by example 02, which contains the five
## sites we downloaded: US-Ha1, DE-Tha, AU-How, US-MMS, FR-Fon.

dir.create("output", showWarnings = FALSE)

message("=== Generating citations for downloaded sites ===\n")

if (!exists("generate_fluxnet_citations")) stop(
  "R/generate_fluxnet_citations.R was not sourced. This script must be sourced ",
  "as a whole from the project root, not run line-by-line."
)
results <- generate_fluxnet_citations(
  site_ids_csv  = "data/my_sites.csv",
  manifest_path = "data/my_manifest.csv",
  output_prefix = "output/fluxnet_citations"
)

## ---- Step 2: What was produced? ---------------------------------------------

message("\n=== What was generated ===\n")

bib_lines <- readLines(results$bib)
n_site_entries <- length(bib_lines[grepl("^@misc", bib_lines)])

message("1. BibTeX file: ", results$bib)
message("   Contains ", n_site_entries, " site @misc entries")
message("   Plus mandated @article references for Pastorello 2020 and any")
message("   network-specific references required by the hubs in your data.")
message()

message("2. Acknowledgments: ", results$ack)
message("   Contains a global acknowledgment paragraph plus network-specific")
message("   acknowledgment text for AmeriFlux, ICOS, and TERN (since our five")
message("   sites span all three networks). Ready to paste into your Methods.")
message()

message("3. Review flags: ", results$flags)
message("   Lists sites that need human attention before submission:")
message("   - Sites with no author block in their citation")
message("   - Sites where the citation format has an unexpected structure")
message("   - Reminders to verify mandated references against the authoritative source")
if (results$n_flags > 0) {
  message("   ** ", results$n_flags, " flag(s) found — check ", basename(results$flags), " before submitting **")
} else {
  message("   (No flags for this set of 5 sites)")
}

## ---- Step 3: Peek at the BibTeX output -------------------------------------

message("\n=== First few lines of the .bib file ===\n")
cat(paste(head(bib_lines, 30), collapse = "\n"), "\n...\n")

## ---- Step 4: Optional — generate for a subset only -------------------------
##
## If you want citations for just some of your sites (e.g., only the AmeriFlux
## ones), you can pass a site_ids vector instead of a CSV:

message("\n=== Optional: generate for AmeriFlux-only subset ===\n")

amf_sites <- c("US-Ha1", "US-MMS")

results_amf <- generate_fluxnet_citations(
  site_ids      = amf_sites,
  manifest_path = "data/my_manifest.csv",
  output_prefix = "output/fluxnet_citations_ameriflux_only"
)

message("\n  AmeriFlux-only .bib: ", results_amf$bib)
message("  Networks present:    ", paste(results_amf$networks, collapse = ", "))

## ---- What's next? -----------------------------------------------------------
##
## You now have:
##   output/fluxnet_citations.bib               : BibTeX for all 5 sites
##   output/fluxnet_citations_acknowledgments.md : acknowledgment text
##   output/fluxnet_citations_review_flags.md    : review checklist
##
## Before submitting a manuscript:
##   1. Open output/fluxnet_citations_review_flags.md and address every flag
##   2. Add output/fluxnet_citations.bib to your LaTeX/Quarto/RMarkdown project
##   3. Cite each site in your data availability statement
##   4. Include the acknowledgment text from _acknowledgments.md
##
## The citation generator works correctly because you saved data/my_manifest.csv
## in example 01. If you add more sites to your analysis later, re-run this
## example after updating data/my_sites.csv with the additional site IDs.
##
## For the full FLUXNET site list or science questions, see: https://fluxnet.org

message("\n=== All done! ===")
message("Output files are in the output/ directory.")
message("Check output/fluxnet_citations_review_flags.md before manuscript submission.")
