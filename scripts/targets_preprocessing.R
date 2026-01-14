##################################################
# targets pipeline for seurat object preprocessing
##################################################

# Set target options
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
)

# Define the targets pipeline
targets_preprocessing <-
  tar_plan(
    bpcells_cellranger_cmo = convert_to_bp_cells_object(
      dataset,
      path_list,
      datasource = "cellranger",
      data_slot = "Multiplexing Capture"
      # TODOmaybe change to format=file outside of tarchetypes::tar_plan()
      # to allow checking of file changes
    ),
    bpcells_cellranger = convert_to_bp_cells_object(
      dataset,
      path_list,
      datasource = "cellranger",
      data_slot = "Gene Expression"
    ),
    bpcells_cellbender = convert_to_bp_cells_object(
      dataset,
      path_list,
      datasource = "cellbender"
    ),
    seurat_obj_raw_joined = create_joined_seurat_obj(
      bpcells_cellbender,
      bpcells_cellranger,
      bpcells_cellranger_cmo,
      counts_per_cell_pre_filter = 50,
      convert_vector = define_convert_vector()
    )
    # bpcells_cellranger_cmo = convert_to_bp_cells_object(dataset, path_list, datasource="cellranger", data_slot = "Multiplexing Capture"),
  )
