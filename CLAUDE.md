## Working directory convention

**All example scripts assume the user's working directory is the project root.** Paths like `data/raw`, `R/hr_workaround.R`, and `data/my_manifest.csv` are written relative to the root, not relative to `examples/`.

Each example begins with a directory check that errors out with a clear message if it's run from the wrong location. Maintain this discipline in any new examples.

## Vendored utilities are temporary scaffolding

`R/hr_workaround.R` and `R/generate_fluxnet_citations.R` exist here only because the `fluxnet` R package hasn't absorbed their functionality yet. They are scheduled for migration into the package over the coming months. When this happens:

- The vendored files in `R/` will be removed
- The example scripts will be updated to use the package's native functions
- This file should be updated to note the change
- Existing forks of the template will continue to work but won't auto-update

Do not extend these utilities or add features to them — extensions belong in the upstream `fluxnet` package. Bug fixes that are urgent enough to ship before the package update are acceptable but should also be reported as issues against the package.

The `R/hr_workaround.R` file currently addresses the inventory-label mismatch in `flux_discover_files()` where extracted hourly AmeriFlux files are labeled `time_resolution = "HR"` rather than `"HH"`. It is distinct from an older `flux_extract()` filename bug that was fixed in fluxnet v0.3.2.9000 (commit 2741bb8); the historical workaround for that older bug lives in `davidjpmoore/FluxCourseForecast` and is retired.

## End-to-end testing is required

Any change to the example scripts, the vendored utilities, or the working-directory assumptions must be verified by running all three examples end-to-end against the live FLUXNET shuttle. Code-review-only verification has missed real bugs in this repo's history (missing `source()` calls, working-directory drift) and is not a substitute for actually running the code.

The verification cost is real (a small FLUXNET download takes time and bandwidth) but is the right standard for a template that students will use. If a change can be verified against a smaller set of sites or against already-downloaded data, prefer that to skipping verification altogether.

## Audience-first writing

Documentation in this repo is written for users who may have no prior FLUXNET experience and may be new to R. Maintain this voice in any edits:

- Lean explanatory, not terse. Spell out acronyms on first use.
- Don't assume familiarity with eddy covariance, ONEFlux, BADM, or hub structures.
- Where the repo asks users to do something, explain why before how.
- Inline comments in the example scripts are heavy by design. Keep them.

The README in particular should remain accessible to a first-year graduate student.

## The credential conversation

AmeriFlux requests credentials but does not technically require them. The repo's framing of this is deliberate: it's a community-norm conversation, not a technical barrier. Phrase any future credential-related documentation as "the AmeriFlux community asks that you provide..." rather than "you must provide..." Students who choose not to provide credentials should be able to comment out the relevant lines and have everything else still work.

## Citation correctness is non-negotiable

The temporal-correctness principle from `fluxnet-citations` applies here too: citations must reflect the metadata that existed at the time of download, not whatever the FLUXNET registry says today. The manifest produced by `01_discover.R` is the durable record. Don't add features that pull fresh metadata at citation-generation time. Don't suggest workflows that let users generate citations for data they haven't downloaded.

## Session log convention

Append all structured reports (audits, investigations, summary tables, decision rationales) to `SESSION_LOG.md` at the project root under the current session's date header. Commit and push immediately after each append. Use minimal descriptive commit messages prefixed `SESSION_LOG:` (e.g., "SESSION_LOG: HR workaround audit"). Do not ask for confirmation before committing the log file. Prompts and conversational back-and-forth are NOT logged here, only structured reports.

If the most recent date header in SESSION_LOG.md is not today's date, add a new session header before logging anything.

## What this repo does not do

To prevent scope creep, the following are explicitly out of scope and should not be added without a deliberate scope-expansion conversation:

- Analysis examples beyond basic data access (analysis belongs in the user's own forks or in dedicated analysis repositories)
- Detailed FLUXNET science content (point users to fluxnet.org and the Pastorello synthesis paper)
- BADM metadata reading (the `fluxnet` package handles this; not a quickstart concern)
- Quality control beyond what `fluxnet::flux_qc()` provides natively
- Alternative output formats for citations (BibTeX only; add others if and when the community asks)
- A server-hosted version of the citation generator (privacy and trust concerns; the local R-script form is intentional)

If a user requests one of these, the answer is "here are the resources / packages that handle that," not "let's add it to the template."

## Related repositories

- **fluxnet** package: github.com/EcosystemEcologyLab/fluxnet-package (Eric Scott, transitioning to David Moore in mid-2026)
- **fluxnet-citations**: github.com/EcosystemEcologyLab/fluxnet-citations (the standalone citation tool that this template vendors)
- **fluxnet-annual-2026**: the paper repo where the citation generator and HR workaround patterns originated (not public-facing)

## Maintenance notes

- Issues and PRs are the canonical channel for student feedback. Watch for early reports — the first few weeks after release surface the largest set of "this doesn't quite work for my case" patterns.
- Two-week notice: maintenance of the `fluxnet` R package transfers from Eric Scott to David Moore in late June 2026. Expect changes in that package to begin landing thereafter. Watch for opportunities to retire vendored utilities here as the package absorbs them.