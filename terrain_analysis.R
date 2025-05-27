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
