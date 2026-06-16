# Getting started with FLUXNET data: a quickstart for FLUXCOURSE students

If you've come to FLUXCOURSE wanting to work with FLUXNET data and aren't sure where to start, this guide is for you. We've built a template repository that takes you from "I've heard of FLUXNET" to "I have data downloaded and citations ready" in three worked examples.

The template lives at **[EcosystemEcologyLab/fluxnet-quickstart](https://github.com/EcosystemEcologyLab/fluxnet-quickstart)**.

## What this is

FLUXNET coordinates eddy covariance flux measurements (carbon, water, and energy exchange between ecosystems and the atmosphere) from hundreds of tower sites worldwide. As of May 2026, the FLUXNET Shuttle gives you access to nearly 6,000 site-years of standardized data, processed with ONEFlux, from networks including AmeriFlux, ICOS, TERN, SAEON, JapanFlux, and KoFlux. Behind every site is a team that installed and maintains the instruments, often over years to decades.

The `fluxnet-quickstart` repository is a GitHub template that bundles together everything you need to start using this data in R: the `fluxnet` R package as a dependency, three worked examples covering discovery, download, and citation, and the small utility scripts that smooth over rough edges in the current tooling.

## How to use it

1. Go to the repository at https://github.com/EcosystemEcologyLab/fluxnet-quickstart
2. Click the green **Use this template** button to create your own copy under your GitHub account
3. Clone your copy to your laptop
4. Open the project in RStudio or your editor of choice
5. Work through the three example scripts in order

The examples are heavily commented and assume no prior FLUXNET experience.

## What you'll learn

**Example 1: Discovery.** Use the `fluxnet` package to list every site available in the FLUXNET network, then filter by characteristics you care about (vegetation type, record length, location). Save the result as your manifest, a snapshot of what was available at this moment.

**Example 2: Download.** Take a small handful of sites from your manifest and download their data. This example covers the AmeriFlux credential conversation (credentials are requested for community accountability, not technically required), the practical mechanics of getting data onto your disk, and a small workaround for an inventory-labeling quirk in the current tooling.

**Example 3: Citations.** Use the manifest from Example 1 to generate publication-ready BibTeX citations, acknowledgments text, and a review-flags file for the sites you downloaded. The temporal-correctness principle is central here: the citations match the data you downloaded, not whatever the FLUXNET registry says today.

## Why citation matters

FLUXNET data carries an attribution requirement that distinguishes it from many other datasets. Each tower's data was contributed by a specific site team, and the data hubs require you to cite each site individually in any publication that uses its data. A paper using 50 FLUXNET sites needs 50 site-level citations in its reference list, plus references for the regional networks and synthesis works. The citation tool in Example 3 produces this for you and is the easiest way to do this part of your analysis correctly.

## What this isn't

This template gets you to data. It does not teach you eddy covariance, ONEFlux processing, BADM metadata, or analysis methods. For those, FLUXCOURSE itself is your resource, along with the FLUXNET documentation at [fluxnet.org](https://fluxnet.org) and Pastorello et al. 2020 in Scientific Data.

## A note on the underlying tools

The `fluxnet` R package by Eric Scott is the foundation. The two utility scripts vendored into the template (the citation generator and the inventory-label workaround) are temporary scaffolding scheduled for absorption into the package over the coming months. Your forked template will keep working regardless; the underlying tools will just get tidier as the ecosystem matures.

## If you get stuck

Open an issue on the [fluxnet-quickstart](https://github.com/EcosystemEcologyLab/fluxnet-quickstart/issues) repository. Other FLUXCOURSE students will likely run into the same things, and a public record of fixes helps everyone.

Welcome to FLUXNET. Have fun with the data.
