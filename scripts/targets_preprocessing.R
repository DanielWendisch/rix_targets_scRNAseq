##################################################
# targets pipeline for seurat object preprocessing
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
    format = "qs"#,
    #error = "null"
)


targets_preprocessing <- list(
    tar_plan(
        setup="0_setup",
        seurat_obj_basic_processed=
         basic_seurat_processing(
            obj = seurat_obj_raw_joined,
            convert_vec= convert_vector, 
            step_no. = setup,
    )
    ))


