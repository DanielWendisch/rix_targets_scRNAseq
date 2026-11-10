# rix_targets_scRNAseq

Reproducible single-cell RNA-seq preprocessing with a **{targets}** pipeline inside a **Nix** environment built with **{rix}**. R package versions and system libraries are pinned to a date (2025-07-07), so the pipeline runs the same way on any machine.

## Structure

| File | Purpose |
|---|---|
| `create_env.R` | Generates `default.nix` with `rix()` (pinned CRAN date plus Git packages at fixed commits, e.g. BPCells, presto, STACAS) |
| `default.nix`, `.envrc` | The environment; `.envrc` activates it with direnv (`use nix`) |
| `_targets.R` | Pipeline definition, mapped over datasets (`hub_01`, `hub_02`) with `tar_map()` |
| `scripts/functions/` | Plain R functions used by the targets |
| `scripts/targets_*.R` | Target lists (config, preprocessing) |
| `run_targets.qmd` | Notebook to inspect the manifest, run the pipeline and view the dependency graph |

## Usage

```bash
nix-shell              # or: direnv allow
Rscript create_env.R   # only to regenerate default.nix
```

then in R:

```r
targets::tar_manifest()
targets::tar_make()
targets::tar_visnetwork()
```

Input data (cellranger / CellBender outputs) is not included; paths are set in `scripts/functions/config.R`.
