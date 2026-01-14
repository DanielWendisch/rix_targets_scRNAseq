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
targets <- tar_map(
    values = values,
    tar_target(path_list, make_proj_paths(dataset)),
    ####
    tar_file(
        bpcells_cellranger,
        convert_to_bp_cells_object(
            dataset,
            path_list,
            datasource = "cellranger", # TODO probably better to split convert_to_bp_cells_object into seprate functions
            data_slot = "Gene Expression"
        )
    ),
    tar_file(
        bpcells_cellranger_cmo,
        convert_to_bp_cells_object(
            dataset,
            path_list,
            datasource = "cellranger",
            data_slot = "Multiplexing Capture"
        )
    ),
    tar_file(
        bpcells_cellbender,
        convert_to_bp_cells_object(
            dataset,
            path_list,
            datasource = "cellbender"
        )
    ),
    tar_target(
        convert_vector,
        define_convert_vector(dataset)
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
        )),

        ####### plots
        tar_file(
            knee_plot_cellranger,
            make_knee(bpcells_cellranger,dataset, data_type = "rna")
        )
    )



list(targets)
