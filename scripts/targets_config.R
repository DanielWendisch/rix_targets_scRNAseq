##################################################
# targets pipeline to set config variables and make_combined_bpcell_targets_seurat_target
##################################################

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


targets_config <- list(
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
        ))
)
