# Load libraries for targets
library(targets)
library(tarchetypes)

# Source the functions and sub-pipelines
tar_source("scripts")

# set options
future::plan("multicore", workers = 6)
options(future.globals.maxSize = 16000 * 1024^2)



# run target pipeline
list(
    targets_config,
    # tar_target(knee_plot_cellranger,
    # make_knee(bpcells_cellranger, data_type = "rna"),
    # format = "file"
    targets_preprocessing
)

# targets_preprocessing
