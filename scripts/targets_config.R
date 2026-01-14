##################################################
# targets pipeline to set config variables and make bpcells-foramtted seurat object with
# cellranger rna and hashtag counts as well as cellbender corrected counts
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
        "purrr", # needed here?
        "ggplot2"
    ),
    format = "qs",
    error = "null"
)


targets_config <- list(
    tar_plan(
    path_list = make_proj_paths(dataset),
    ####
    tar_file(
        name= bpcells_cellranger,
        convert_to_bp_cells_object(
            dataset,
            path_list,
        )
    ),
    tar_file(
        name = bpcells_cellranger_cmo,
        convert_to_bp_cells_object(
            dataset,
            path_list,
            data_slot = "Multiplexing Capture"
        )
    ),
    tar_file(
        name = bpcells_cellbender,
        convert_to_bp_cells_object(
            dataset,
            path_list,
            datasource = "cellbender"
        )
    ),
    convert_vector = define_convert_vector(dataset),
    seurat_obj_raw_joined= 
    create_joined_seurat_obj(
            dataset,
            bpcells_cellbender,
            bpcells_cellranger,
            bpcells_cellranger_cmo,
            convert_vector
        )
)
)