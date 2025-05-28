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
}
