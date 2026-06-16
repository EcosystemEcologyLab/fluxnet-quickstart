# FLUXNET Quickstart

A template repository for getting started with FLUXNET data using R. Three
worked examples take a new user from "I want to study X with FLUXNET data"
to "I have data and citations ready for analysis."

**Click "Use this template" on the GitHub page to create your own copy.**
Then clone your fork and work through the examples in order.

---

## About the FLUXNET Shuttle

FLUXNET coordinates measurements of carbon dioxide, water vapor, and energy
exchange between ecosystems and the atmosphere at hundreds of flux tower sites
worldwide. Towers are installed in every major ecosystem type — forests,
grasslands, croplands, wetlands, savanna, tundra — and measure continuously at
30-minute or 60-minute intervals for years to decades. Collectively, FLUXNET
provides the most comprehensive observational record of terrestrial carbon and
energy cycling on Earth.

The **FLUXNET shuttle** (launched May 2026) is the canonical new way to access
FLUXNET data. It replaces the previous model of large, infrequent dataset
releases — such as FLUXNET2015 — with continuously updated, standardized data
from all participating regional networks. All data are processed through
**ONEFlux**, an open-access code family developed collaboratively over more than
a decade, and are distributed under a CC-BY-4.0 license. Contributing networks
include AmeriFlux (Americas), ICOS (Europe), TERN (Australia), SAEON (southern
Africa), ChinaFlux, KoFlux, and JapanFlux. As of May 2026, the shuttle provides
access to nearly 6,000 site-years of data including primary productivity,
ecosystem respiration, latent and sensible heat fluxes, gap-filling, uncertainty
quantification, and expanded site metadata. The shuttle is available via a
graphical interface for browsing and one-off downloads, or via the
[shuttle GitHub](https://github.com/fluxnet/shuttle) for scripted access. This
template uses the R-language interface provided by the
[fluxnet package](https://github.com/EcosystemEcologyLab/fluxnet-package),
which wraps the shuttle's command-line interface.

---

## What you will learn

- **Example 01 — Discover sites** (`examples/01_discover.R`): Query the FLUXNET
  registry, explore the available sites, and filter by ecosystem type and record
  length. Saves a local snapshot of the registry (your manifest) for downstream use.

- **Example 02 — Download data** (`examples/02_download.R`): Download and extract
  flux data for a small set of sites spanning multiple networks. Covers AmeriFlux
  credentials and the HR workaround for hourly sites.

- **Example 03 — Generate citations** (`examples/03_cite.R`): Produce a BibTeX
  file, acknowledgment text, and review checklist for every site you downloaded.

---

## How to use this template

1. Click **"Use this template"** on the GitHub page
   ([EcosystemEcologyLab/fluxnet-quickstart](https://github.com/EcosystemEcologyLab/fluxnet-quickstart))
   and create your own repository.

2. Clone your repository to your local machine:
   ```bash
   git clone https://github.com/YOUR-USERNAME/YOUR-REPO-NAME.git
   cd YOUR-REPO-NAME
   ```

3. Install R dependencies (see the [Installation](#installation) section below).

4. Work through the examples **in order**:
   ```r
   source("examples/01_discover.R")   # discover sites, save manifest
   source("examples/02_download.R")   # download and extract data
   source("examples/03_cite.R")       # generate citations
   ```
   Each example is a self-contained R script with heavy inline commentary
   explaining each step.

5. Once you understand the workflow, build your own analysis by adapting the
   examples to your research question. The examples are starting points, not
   prescriptions.

---

## Installation

**R 4.0 or higher is required.** R 4.6 is recommended.

Install the fluxnet package from GitHub:

```r
install.packages("remotes")
remotes::install_github("EcosystemEcologyLab/fluxnet-package")
```

Install CRAN dependencies used by the examples:

```r
install.packages(c("dplyr", "readr", "stringr", "lubridate"))
```

The fluxnet package requires Python (for the FLUXNET shuttle CLI) and the
`reticulate` R package (which provides the R-Python bridge). Both are installed
automatically as dependencies. On first use, call:

```r
library(fluxnet)
flux_install_shuttle()   # installs the shuttle CLI into a Python virtualenv
```

You only need to run `flux_install_shuttle()` once per machine. After that,
`flux_listall()` and `flux_download()` will use the installed shuttle
automatically.

If you are on Apple Silicon (M1/M2/M3/M4 Mac) and `reticulate` cannot find
Python, add the following line to your project's `.env` file:

```
RETICULATE_VIRTUALENV_STARTER=/opt/homebrew/bin/python3
```

This tells reticulate to use Homebrew's Python when creating the virtualenv.
You may need to adjust the path to match your Python installation
(`which python3` in the terminal will show you the path).

---

## A note on AmeriFlux credentials

The FLUXNET shuttle will download data from any network without authentication.
However, the **AmeriFlux community requests** (but does not technically require)
that users provide a name, email address, and intended-use description when
downloading AmeriFlux data.

This is a community norm, not a technical barrier. When you provide credentials,
you are counted in AmeriFlux's usage statistics, which helps the network
demonstrate impact to its funders (the U.S. Department of Energy's Office of
Science). The scientists who maintain flux towers and process the data depend on
this accounting to sustain their programs.

**How to provide credentials:**

Create a file called `.env` in the root of your project (it is already in
`.gitignore`, so it will not be committed):

```
AMERIFLUX_USER_NAME=Your Full Name
AMERIFLUX_USER_EMAIL=you@institution.edu
```

Then load it at the start of your session:

```r
if (file.exists(".env")) dotenv::load_dot_env()
```

The `dotenv` package can be installed with `install.packages("dotenv")`.

If you choose not to provide credentials, comment out the `user_info` argument
in the `flux_download()` call in example 02. You will still be able to download
all data — you just will not be counted in AmeriFlux's impact metrics. We
encourage you to provide credentials as a courtesy to the community.

---

## About the vendored utilities

This template includes two utility files in `R/` that are **temporary
scaffolding** intended to cover a gap in the current fluxnet package:

| File | Purpose |
|------|---------|
| `R/hr_workaround.R` | Handles AmeriFlux sites that publish at hourly (HR) rather than half-hourly (HH) resolution |
| `R/generate_fluxnet_citations.R` | Generates BibTeX citations and acknowledgments from the shuttle manifest |

Both utilities are scheduled for absorption into the fluxnet R package over the
next several months. When that happens, the corresponding source files will be
removed from future versions of this template. Existing forks will continue to
work — the utilities are stable and correct today. However, once the package
absorbs them, you should plan to update your fork to use the package functions
directly and remove the vendored files.

This is not urgent: the utilities work, they are tested, and there is no
security or correctness concern with keeping them. It is simply a cleaner
long-term workflow to use the package functions when they become available.

---

## What this template does not cover

This template is focused on **data access** — getting from zero to a local copy
of FLUXNET data with citations. It intentionally does not cover:

- **Analysis**: Reading and analyzing the data is up to you. Start with
  `flux_read()` from the fluxnet package to load the CSVs into R data frames.
  See `?flux_read` for documentation.

- **FLUXNET science in depth**: For the science behind the data — flux
  partitioning, gap-filling, uncertainty estimation — read
  Pastorello et al. (2020, doi:10.1038/s41597-020-0534-3) and consult the
  [fluxnet.org](https://fluxnet.org) documentation.

- **BADM metadata**: Each site ships a BIF file containing biological,
  ancillary, disturbance, and management (BADM) metadata. Access this with
  `flux_badm()` from the fluxnet package. See `?flux_badm` for examples.

- **Quality control beyond the defaults**: The shuttle data has already been
  through the ONEFlux QC pipeline. If you need custom QC (e.g., u* filtering
  at a specific threshold), refer to Pastorello et al. (2020) for the methodology.

---

## Citing FLUXNET data

See [CITATION.md](CITATION.md) for full citation guidance. The short version:

1. Cite the **fluxnet R package** (see CITATION.md for the reference).
2. Cite **Pastorello et al. 2020** (required for all FLUXNET data users).
3. **Run example 03** to generate per-site BibTeX citations — these are required
   and must appear in your manuscript.

Per-site citations are not optional. Each site DOI represents the work of the
PI team and their students and technicians. Include them.

---

## Getting help

- **Template-specific questions** (the examples, the vendored utilities, the
  repository structure): open an issue at
  [EcosystemEcologyLab/fluxnet-quickstart](https://github.com/EcosystemEcologyLab/fluxnet-quickstart/issues)

- **fluxnet package issues** (bugs in `flux_listall()`, `flux_download()`,
  `flux_read()`, etc.): open an issue at
  [EcosystemEcologyLab/fluxnet-package](https://github.com/EcosystemEcologyLab/fluxnet-package/issues)

- **Science questions, data questions, site coverage**: visit
  [fluxnet.org](https://fluxnet.org) or contact your regional network

---

## License

MIT — see [LICENSE](LICENSE). Copyright 2026 David J. P. Moore and contributors.
