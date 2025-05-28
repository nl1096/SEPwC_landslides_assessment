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
