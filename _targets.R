# Load libraries for targets
library(targets)
library(tarchetypes)

# Source the functions and sub-pipelines
tar_source("scripts")

# set options
future::plan("multicore", workers = 6)
options(future.globals.maxSize = 16000 * 1024^2)

tar_option_set(
    packages = c(
        "here",
        "Seurat",
        "BPCells",
        "qs",
        "patchwork",
        "readr",
        "dplyr",
        "tidyr",
        "purrr",
        "ggplot2"
    ),
    format = "qs",
    error = "null"
)


library(tibble)


values <- tibble(
    # method_function = rlang::syms(c("hub_01", "hub_02")),
    dataset = c("hub_01", "hub_02")
)
list( tar_map(
    values = values,
    targets_config,
        ####### plots
        tar_file(
            knee_plot_cellranger,
            make_knee(bpcells_cellranger,dataset, path_list, data_type = "rna")
        )
    )
)


