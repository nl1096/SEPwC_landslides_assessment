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

There are built in functions in R packages (`terra`) to calculate slope and distance from a shapefile. Use them

The `randomForest` library can create the classifier required. It needs a column (e.g. `ls~.`) and
a dataframe to work. You can create test and train samples form a dataframe using the `sample` package from
the `caret` library. 

You need positive (i.e. values of all rasters where landslides occur) and negative data (values where they don't occur) 
from the rasters. This can be done by extracting data from 
all of your rasters under the landslides shapefile using `terra` library. 
You send these data into The RF classifier 
and then use predict to make a probability map.

It might be helpful to print the accuracy score
or other metrics from the classifier if the verbose flag is on, perhaps.
[This website]<https://www.r-bloggers.com/2021/04/random-forest-in-r/> might
help with this.

## The rules

You cannot alter any of the assert comments in `test/test_terrain.R`

If you alter any function names in the main code, you *can* alter the name
in the test file to match; however the rest of the test must remain unchanged. 
This will be checked.

If you wish to add more tests, please do, but place them in a separate file
in the `test` directory. Remember to name the file `test_something.R`.

You can also add extra functionality, but the command-line interface must pass
the tests set.

