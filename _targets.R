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
    error="null"
)

# run target pipeline
list(
    tar_target(
        dataset,
        define_dataset()
    ),
    tar_target(
        path_list,
        make_proj_paths(dataset),
        pattern = map(dataset),
        iteration = "list"
    ),
    # tar_target(knee_plot_cellranger,
    # make_knee(bpcells_cellranger, data_type = "rna"),
    # format = "file"
    tar_target(
        bpcells_cellranger_cmo,
        convert_to_bp_cells_object(
            dataset,
            path_list,
            datasource = "cellranger",
            data_slot = "Multiplexing Capture"
        ),
        pattern = map(dataset, path_list),
        iteration = "list",
        format = "file"
    ),
    tar_target(
        bpcells_cellranger,
        convert_to_bp_cells_object(
            dataset,
            path_list,
            datasource = "cellranger",
            data_slot = "Gene Expression"
        ),
        pattern = map(dataset, path_list),
        iteration = "list",
        format = "file"
    ),
    tar_target(
        bpcells_cellbender,
        convert_to_bp_cells_object(
            dataset,
            path_list,
            datasource = "cellbender"
        ),
        pattern = map(dataset, path_list),
        iteration = "list",
        format = "file"
    ),
    tar_target(
        convert_vector,
        define_convert_vector(dataset),
        pattern = map(dataset)
    ),
    tar_target(
        seurat_obj_raw_joined,
        create_joined_seurat_obj(
            dataset,
            bpcells_cellbender,
            bpcells_cellranger,
            bpcells_cellranger_cmo,
            counts_per_cell_pre_filter = 50,
            convert_vector 
        ),
        pattern = map(
            dataset,
            bpcells_cellbender,
            bpcells_cellranger,
            bpcells_cellranger_cmo,
            convert_vector
        ),
        iteration = "list"
    )
)



#

# seurat_obj_raw_joined = create_joined_seurat_obj(
#   bpcells_cellbender,
#   bpcells_cellranger,
#   bpcells_cellranger_cmo,
#   counts_per_cell_pre_filter = 50,
#   convert_vector = define_convert_vector()
# )
