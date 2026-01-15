
basic_seurat_processing <- function(obj,
                                    convert_vec,
                                    dataset_name,
                                    step_no.,
                                    leiden_or_louvain = "louvain",
                                    counts_per_cell_pre_filter_global = 50,
                                    resolution_clustering_1 = 0.8,
                                    resolution_clustering_2 = 0.2,
                                    dim_number_pca_and_neighbors = 15){
  for (assay_iter in Assays(obj)) {
    print("new assay ##########################################")
    print("          ##########################################")
    print(assay_iter)

    if (assay_iter=="hashtag_oligos") {
      dimensions <- 1:length(convert_vec)}else{dimensions <- c(1:dim_number_pca_and_neighbors)}

    DefaultAssay(obj) <- assay_iter
    obj <- obj |>
      NormalizeData()

    print("scale data")
    obj <- obj |>
      FindVariableFeatures(assay = assay_iter) |>
      ScaleData()

    print("runPCA")
    obj[[assay_iter]]$scale.data  <- obj[[assay_iter]]$scale.data %>% write_matrix_memory(compress=FALSE)
    obj <- obj |>
      RunPCA(assay = assay_iter, reduction.name = paste0("pca.", assay_iter),npcs =max(dimensions))

    print("neighbors")
    obj <- obj |> FindNeighbors(
      dims = dimensions,
      reduction = paste0("pca.", assay_iter),
      assay = assay_iter)
    gc()

    print("clustering no 1")
    obj <- obj |> FindClusters(
      resolution = resolution_clustering_1,
      verbose = TRUE,
      cluster.name = paste(assay_iter, "clusters", leiden_or_louvain, "res." , resolution_clustering_1, sep = "_"),
      algorithm = ifelse(leiden_or_louvain=="louvain",1,4)
      # graph.name = paste0("kNN_","pca.",assay_iter)
    )

    print("clustering no 2")
    obj <- obj |> FindClusters(
      resolution = resolution_clustering_2,
      verbose = TRUE,
      cluster.name = paste(assay_iter, "clusters", leiden_or_louvain, "res." , resolution_clustering_2, sep = "_"),
      algorithm = ifelse(leiden_or_louvain=="louvain",1,4)
      # graph.name = paste0("kNN_","pca.",assay_iter)
    )


    obj <- obj |>
      RunUMAP(
        dims = dimensions,
        reduction = paste0("pca.", assay_iter),
        assay = assay_iter,
        reduction.name = paste0("umap.", assay_iter)
      )

    # gc()
  }
  
  DefaultAssay(obj) <- "RNA"
  # path_intermediate_data_root <- here("intermediate_data", dataset_name, step_no. )
  
  # if (!dir.exists(path_intermediate_data_root)) {
  #   dir.create(path_intermediate_data_root, recursive = TRUE)
  # }
  # rds_path <- make_path_seurat_object(step.=step_no.,
  #                                     dataset.=dataset_name,
  #                                     path_interdat_root.=path_intermediate_data_root)
  # obj |>  write_rds(rds_path)
  # 
  # return(rds_path)
  return(obj)
}