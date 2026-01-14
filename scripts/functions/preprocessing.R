convert_to_bp_cells_object <- function(
    dataset_name,
    path_ls,
    data_slot = "Gene Expression",
    datasource = "cellranger") {
  if (datasource == "cellranger") {
    path_output <- path_ls$cellranger$raw_mtx
  }
  if (datasource == "cellbender") {
    path_output <- path_ls$cellbender$output
  }
  dat <- Read10X_h5(path_output, use.names = TRUE)


  if (data_slot == "Gene Expression") { # todo change names to janitor::make_names()
    # todo change to  case_when() syntax
    path_bp_cells <- here("BPcell_matrices", paste0("cellranger_", dataset_name))
  }
  if (data_slot == "Multiplexing Capture") {
    path_bp_cells <- here("BPcell_matrices", paste0("cellranger_cmo_", dataset_name))
  }
  if (datasource == "cellbender") {
    path_bp_cells <- here("BPcell_matrices", paste0("cellbender_", dataset_name))
    if (is.null(names(dat))) {
      write_matrix_dir(dat, path_bp_cells, overwrite = T)
    } else {
      write_matrix_dir(dat$`Gene Expression`, path_bp_cells, overwrite = T)
    }
    return(path_bp_cells)
  } else {
    write_matrix_dir(
      mat = dat[[data_slot]],
      dir = path_bp_cells,
      overwrite = T
    )
    return(path_bp_cells) # returns path as string, 
    #in order for targets to track modify calling tar_targets(.., format="file")
  }
}


create_joined_seurat_obj <- function(
  dataset_name,
    path_bp_cells_cellbender,
    path_bp_cells_cellranger,
    path_bp_cells_cellranger_cmo,
    counts_per_cell_pre_filter = counts_per_cell_pre_filter_global,
    convert_vec) {
      #browser()
  dat_ranger <- open_matrix_dir(dir = path_bp_cells_cellranger)
  rna_reads_per_cell <- dat_ranger |> colSums()

  dat_cmo <- open_matrix_dir(dir = path_bp_cells_cellranger_cmo)
  dat_ranger <- dat_ranger[, (rna_reads_per_cell > counts_per_cell_pre_filter)]
  dat_cellbender <- open_matrix_dir(dir = path_bp_cells_cellbender)


  ############ #inital trimming of data

  # cells that are present in celranger counts &cellranger hashtag & cellbender output
  intersecting_cells <- intersect(colnames(dat_cellbender), colnames(dat_ranger))
  intersecting_cells <- intersect(intersecting_cells, colnames(dat_cmo))


  seurat_obj <- CreateSeuratObject(dat_ranger[, intersecting_cells])
  assay_cellbender <- CreateAssay5Object(dat_cellbender[, intersecting_cells])

  seurat_obj[["cellbender_RNA"]] <- assay_cellbender

  dat_cmo <- dat_cmo[, intersecting_cells]
  dat_cmo_tbl <- as.data.frame(t(as.matrix(dat_cmo)))
  dat_cmo <- CreateAssay5Object(dat_cmo)

  seurat_obj[["hashtag_oligos"]] <- dat_cmo

  # add hashtag counts to metadata
  dat_cmo_tbl <- dat_cmo_tbl[, names(convert_vec)]
  colnames(dat_cmo_tbl) <- paste("hashtag_id", convert_vec, sep = "_")
  seurat_obj <- AddMetaData(object = seurat_obj, dat_cmo_tbl)
  seurat_obj <- AddMetaData(object = seurat_obj, dataset_name, "experiment")

  return(seurat_obj)
}




#### plots

make_knee <- function(path_bp_cells,dataset_name, project_paths, data_type = "rna") {
  dat <- open_matrix_dir(dir = path_bp_cells)
  testingthis <- 2
  rna_reads_per_cell <- dat |> colSums()
  knee_plot_rna <- plot_read_count_knee(rna_reads_per_cell, cutoff = 2e3) +
    plot_read_count_knee(rna_reads_per_cell, cutoff = 1e3) +
    plot_read_count_knee(rna_reads_per_cell, cutoff = 5e2) +
    plot_read_count_knee(rna_reads_per_cell, cutoff = 1e2) +
    plot_annotation(title = "RNA reads per cell")
  dir.create(project_paths$output$qc_process$plots_and_plot_data, recursive = TRUE, , showWarnings = FALSE)
  file_path <- here(
      project_paths$output$qc_process$plots_and_plot_data,
      paste(dataset_name, data_type, "read_count_knee.png", sep = "_")
      )
  ggsave(plot=knee_plot_rna,filename = file_path)
}
