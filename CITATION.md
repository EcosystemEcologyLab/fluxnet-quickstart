# How to Cite

If you use FLUXNET data downloaded with this template, you are required to include
citations for:

1. The **fluxnet R package** that provides the shuttle interface
2. The **FLUXNET2015 / ONEFlux pipeline** reference (Pastorello et al. 2020)
3. **Every individual site** whose data you use (per-site DOIs from example 03)

Additional network-level citations are required depending on which hub(s) your
sites come from. The citation generator in example 03 handles all of this automatically
and writes a `.bib` file ready for your manuscript.

---

## The fluxnet R package

The R package that wraps the FLUXNET shuttle (used in all three examples):

```
Eric Scott and contributors (2026). fluxnet: R interface to the FLUXNET shuttle.
R package version 0.3.x. EcosystemEcologyLab/fluxnet-package.
https://github.com/EcosystemEcologyLab/fluxnet-package
```

BibTeX:
```bibtex
@misc{Scott2026fluxnet,
  author = {Scott, Eric and contributors},
  title  = {{fluxnet}: {R} interface to the {FLUXNET} shuttle},
  year   = {2026},
  note   = {R package. EcosystemEcologyLab/fluxnet-package},
  url    = {https://github.com/EcosystemEcologyLab/fluxnet-package}
}
```

---

## The fluxnet-citations tool

The citation generator vendored in `R/generate_fluxnet_citations.R`:

```
David J. P. Moore (2026). fluxnet-citations: Generate BibTeX citations and
acknowledgments from a FLUXNET shuttle manifest.
EcosystemEcologyLab/fluxnet-citations.
https://github.com/EcosystemEcologyLab/fluxnet-citations
```

Note: This tool will be absorbed into the fluxnet R package in a future release.
Cite the package (above) once that merge occurs.

---

## FLUXNET synthesis reference

The primary reference for the FLUXNET network, ONEFlux processing pipeline, and
the FLUXNET2015 dataset. Required in any paper that uses FLUXNET data:

```
Pastorello, G. et al. (2020). The FLUXNET2015 dataset and the ONEFlux processing
pipeline for eddy covariance data. Scientific Data 7:225.
https://doi.org/10.1038/s41597-020-0534-3
```

BibTeX:
```bibtex
@article{Pastorello2020,
  author  = {Pastorello, G. and others},
  title   = {{The FLUXNET2015 dataset and the ONEFlux processing pipeline for eddy covariance data}},
  journal = {Scientific Data},
  year    = {2020},
  volume  = {7},
  pages   = {225},
  doi     = {10.1038/s41597-020-0534-3}
}
```

Note: A successor publication describing the FLUXNET Annual 2026 dataset (Keenan,
Moore, Novick et al.) is in preparation. Update this citation when it publishes.

---

## Per-site citations

Each FLUXNET site has a unique DOI assigned by its contributing network
(AmeriFlux, ICOS, TERN, etc.). You **must** cite each site whose data you use.
Example 03 (`examples/03_cite.R`) generates these automatically from your manifest.
The output `.bib` file includes one `@misc` entry per site plus the mandated
network-level references above.

Do not omit per-site citations from your manuscript — the data providers depend
on citations to demonstrate impact, which supports continued funding.

---

## Network-level citations

Depending on which hub(s) your sites come from, additional acknowledgments and
citations may be required (e.g., Beringer et al. 2016 for OzFlux/TERN sites,
Ueyama et al. 2025 for AsiaFlux/JPF sites). The citation generator in example 03
adds these automatically when the relevant networks are present in your manifest.
See the `_acknowledgments.md` output from example 03 for the recommended
acknowledgment text.
