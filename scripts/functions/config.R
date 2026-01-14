
define_dataset <- function() { # expand later
    dataset_name <- list("hub_10","hub_02")
    return(dataset_name)
}

define_convert_vector <- function(dataset_name) { # expand later
if(dataset_name=="hub_10"){vec=c(
  "CMO301" = "hLOA_BIHi001-B",
  "CMO302" = "hLOA_BIHi005-A",
  "CMO303" = "hLOA_BIHi250-A",
  "CMO304" = "hLOA_UCSFi001-A")
  }

  if(dataset_name=="hub_02"){vec=c(
  "CMO306" = "EC_BIHi005-A",
  "CMO305" = "EC_BIHi001-B",
  "CMO307" = "EC_BIHi250-A",
  "CMO308" = "EC_UCSFi001-A",
  "CMO309"= "EC_BIHi001-A")
  }

  return(vec)
}




# input directory paths
make_proj_paths <- function(dataset_name) {
    proj_paths <-  list()
    proj_paths$raw_data_dir <- here("..", "..", "raw_data", "cubi_cusco")
    proj_paths$cellranger$output_dir <- here(proj_paths$raw_data_dir, "cellranger", paste0(dataset_name, "_outs"), "multi")
    proj_paths$cellbender$output_dir <- here(proj_paths$raw_data_dir, "cellbender", dataset_name)
    proj_paths$vireo$output_dir <- here(proj_paths$raw_data_dir, "vireo")

    proj_paths$cellranger$tag_calls_per_cell <- here(proj_paths$cellranger$output_dir, "multiplexing_analysis", "tag_calls_per_cell.csv")
    proj_paths$cellranger$raw_mtx <- here(proj_paths$cellranger$output_dir, "count", "raw_feature_bc_matrix.h5")

    proj_paths$cellbender$output <- here(proj_paths$cellbender$output_dir, paste0(dataset_name, "_cellbender_corrected_filtered_seurat.h5"))
    #proj_paths$cellranger$output <-  here(proj_paths$cellranger$output_dir, )
    return(proj_paths)

}



