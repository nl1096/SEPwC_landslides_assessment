# SEPwC Landslide Risk Coursework (R)

## Introduction

Your task is to write code to read in muliple raster and shapefiles, perform some analysis, 
and then generate a risk (probability) map of landslides. You should output this as a 
raster (with values from 0 to 1).

## The tests

The test suite uses a number of test data sets. The tests will check these data
functions work. 

You can run the tests by running `Rscript test_script.R` in the `test` directory, 
or from R directly:

```R
library(testthat)
test_file("test_script.R")
```

from the test directory. Try it now, before you make any changes!

## The data


There are a number of rasters and shapefiles for this task:

 - `AW3D30.tif` - topography data
 - `Confirmed_faults.shp` - fault location data
 - `Geology.tif` - rock types across the region
 - `Lancover.tif` - landcover codes
 - `landslides.shp` - Landslide occurances

From those you will also need to generate slope raster and a "distance from fault" raster.

Your code should run like:

```bash
Rscript terrain_analysis.R --topography data/AW3D30.tif --geology data/geology_raster.tif --landcover data/Landcover.tif --faults data/Confirmed_faults.shp data/landslides.shp probability.tif
```

## Hints and tips

For randomForest you'll need a dataframe with each row having values of the 
rasters under the landslides and points *outside* the landslides. You'll
need to figure out how to randomly sample outside the landslide plygon. 

The `terra` library contains a lot of functionality, including slope
calculations, and proximity distances function. 

Both `terra` and `sf` can handle shapefiles, but you need to be able to switch 
an object between them. 


## The rules

You cannot alter any of the assert comments in `test/test_terrain.R`

If you alter any function names in the main code, you *can* alter the name
in the test file to match; however the rest of the test must remain unchanged. 
This will be checked.

If you wish to add more tests, please do, but place them in a separate file
in the `test` directory. Remember to name the file `test_something.R`.

You can also add extra functionality, but the command-line interface must pass
the tests set.

