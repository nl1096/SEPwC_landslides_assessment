# Required packages: argparse, terra, randomForest
# Optional: ggplot2

# Load libraries
suppressPackageStartupMessages({
  library(argparse)
  library(terra)
  library(randomForest)
  library(ggplot2)
})

# Suppress global variable warnings for ggplot aesthetics
utils::globalVariables(c("x", "y", "prob", "Variable", "MeanDecreaseGini"))

# Extract raster values from landslide points
extract_values_from_raster <- function(raster_stack, shapefile) {
  terra::extract(raster_stack, shapefile)
}

# Create a training dataframe with raster values and a landslide label
create_dataframe <- function(raster_stack, shapefile, landslide) {
  values <- terra::extract(raster_stack, shapefile)[, -1]
  values$ls <- as.factor(landslide)
  values
}

# Train a random forest classifier using the labeled data
make_classifier <- function(dataframe) {
  randomForest::randomForest(ls ~ ., data = dataframe)
}

# Predict landslide probability for every cell in the raster stack
make_probability_raster <- function(raster_stack, classifier) {
  terra::predict(raster_stack, classifier, type = "prob", index = 2)
}

main <- function(args) {
  # Load all raster and vector data
  topo <- terra::rast(args$topography)
  geology <- terra::rast(args$geology)
  landcover <- terra::rast(args$landcover)
  faults <- suppressWarnings(terra::vect(args$faults))
  landslides <- suppressWarnings(terra::vect(args$landslides))

  # Derive slope and distance from faults
  slope <- terra::terrain(topo, v = "slope", unit = "degrees")
  template <- topo
  values(template) <- NA
  faults_raster <- terra::rasterize(faults, template, field = 1)
  dist <- terra::distance(faults_raster)

  # Stack rasters
  stack <- c(topo, geology, landcover, slope, dist)

  # Create training data
  pos_df <- create_dataframe(stack, landslides, 1)
  set.seed(123)
  bg_points <- terra::spatSample(
    stack,
    size = nrow(pos_df),
    method = "random",
    as.points = TRUE,
    na.rm = TRUE
  )
  neg_df <- create_dataframe(stack, bg_points, 0)

  # Combine and train
  df <- rbind(pos_df, neg_df)
  model <- make_classifier(df)

  # Predict probability map
  prob_map <- make_probability_raster(stack, model)
  terra::writeRaster(prob_map, args$output, overwrite = TRUE)

  # Print model summary if verbose
  if (!is.null(args$verbose) && isTRUE(args$verbose)) {
    print("Training completed")
    print(model)
  }

  # Optional plots (ggplot package)
  if (!is.null(args$plot)) {
    raster_df <- as.data.frame(prob_map, xy = TRUE, na.rm = TRUE)
    colnames(raster_df)[3] <- "prob"

    print(
      ggplot(raster_df, aes(x = x, y = y, fill = prob)) +
        geom_raster() +
        scale_fill_viridis_c(
                             name = "Landslide Probability",
                             option = "plasma") +
        coord_equal() +
        theme_minimal() +
        labs(title = "Predicted Landslide Probability Map")
    )

    # Feature importance plot
    importance_df <- as.data.frame(randomForest::importance(model))
    importance_df$Variable <- rownames(importance_df)

    print(
      ggplot(
             importance_df,
             aes(x = reorder(Variable, MeanDecreaseGini),
                 y = MeanDecreaseGini)) +
        geom_col(fill = "steelblue") +
        coord_flip() +
        labs(
             title = "Feature Importance",
             y = "Mean Decrease in Gini",
             x = "Variable") +
        theme_minimal()
    )
  }

}

# Main program, called via Rscript
if (sys.nframe() == 0) {   # or if (!interactive()) {
  parser <- ArgumentParser(
    prog = "Landslide Risk",
    description = "Calculate landslide probability risk using Random Forests"
  )
  parser$add_argument(
    "--topography",
    required = TRUE,
    help = "Topographic raster file"
  )
  parser$add_argument(
    "--geology",
    required = TRUE,
    help = "Geology raster file"
  )
  parser$add_argument(
    "--landcover",
    required = TRUE,
    help = "Landcover raster file"
  )
  parser$add_argument(
    "--faults",
    required = TRUE,
    help = "Fault location shapefile"
  )
  parser$add_argument(
    "landslides",
    help = "Landslide location shapefile"
  )
  parser$add_argument(
    "output",
    help = "Output raster file"
  )
  parser$add_argument(
    "-v",
    "--verbose",
    action = "store_true",
    default = FALSE,
    help = "Print progress"
  )
  parser$add_argument(
    "--plot",
    action = "store_true",
    help = "Show plots"
  )

  args <- parser$parse_args()
  main(args)
}
