**Landslide Susceptibility Mapping with Random Forests**

This project uses geospatial data and machine learning (Random Forest) to generate a probability map of landslide susceptibility. Raster and vector layers are combined to extract terrain, geology, landcover, and proximity features. The model is trained on known landslide locations and used to predict risk across the study area.

---

**Features**

- Extracts raster values at known landslide locations
- Randomly samples background (non-landslide) points
- Trains a Random Forest classifier
- Generates a raster map showing landslide probability (0 to 1)
- **Optional:** Plots the resulting map and shows feature importance

---

**Dependencies**

The script uses the following R packages:

- `terra` — for spatial raster/vector processing
- `argparse` — to handle command-line arguments
- `randomForest` — for classification
- `ggplot2` — for pretty plots (optional)
- `dplyr` — used to help format data for plotting (optional)

Install them (if needed) using:

install.packages(c("terra", "argparse", "randomForest", "ggplot2", "dplyr"))

---

**Usage**

Run the script using `Rscript` from the command line:

Rscript terrain_analysis.R --topography data/AW3D30.tif --geology data/geology.tif --landcover data/Landcover.tif --faults data/Confirmed_faults.shp data/landslides.shp probability.tif

**Optional Features**

Use `--plot` to display:

- A probability map using `ggplot2`
- A bar chart showing feature importance

Use `--verbose` to print model details and training progress

Run the script interactively via R:

source("terrain_analysis.R")
args <- list(
  topography = "data/AW3D30.tif",
  geology = "data/geology.tif",
  landcover = "data/Landcover.tif",
  faults = "data/Confirmed_faults.shp",
  landslides = "data/landslides.shp",
  output = "probability.tif",
  verbose = TRUE,
  plot = FALSE
)
main(args)

---

**Output**

The script produces:

- A **raster map** (`probability.tif`) where each cell value is the predicted landslide probability.
- Optional: probability map and feature importance plots (`plots.pdf`) (only if `--plot` is set).

---

**Author**

Natalia Lukomska — Undergraduate project for SEPwC module (UoY)
