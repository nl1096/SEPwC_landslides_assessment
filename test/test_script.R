suppressPackageStartupMessages({
library(testthat)
})

# Run like:
#jh1889@mirovia:~/work/teaching/SEPwC_assessments/sediment_assessment/test$ Rscript test_script.R 
# Test passed 🥇
# Test passed 🌈
# Test passed 🎊
# Test passed 🥳
# ── Warning: check main# 
# ...
#

# load in the script you want to test
source("../terrain_analysis.R")

# tests --------------------
# check the get_plot_limit function
  test_that("extract_values_from_raster", {
    library(terra)

    template <- rast("data/raster_template.tif")
    point <- vect("data/test_point.shp")
    values <- extract_values_from_raster(template, point)
    expect_equal(length(values[[1]]), 2)
    expect_equal(values[1,1], 2509.687)
    expect_equal(values[2,1], 2534.5088)
  })

  test_that("create_dataframe", {
    library(terra)

    template <- rast("data/raster_template.tif")
    point <- vect("data/test_point.shp")
    raster_stack <- rast(list(template, template, template))
    df <- create_dataframe(raster_stack, point, 0)
    expect_s3_class(df, "data.frame")
    expect_equal(length(df[[1]]),2)
    expect_identical(colnames(df), c('raster_template', 'raster_template.1', 'raster_template.2', 'ls'))
    expected <- c(0,0)
    expected <- as.factor(expected)
    expect_equal(df$ls, expected)
  })

  test_that("make_classifier", {

    test_data <- runif(20)
    data <- data.frame("x1" = test_data,
                       "x2" = test_data * 2.45,
                       "ls"  = as.factor(c(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1))
                       )
    classifier = make_classifier(data)
    expect_equal(classifier$forest$nclass, 2)
    expect_equal(classifier$classes, c("0","1"))
    expect_no_error(predict(classifier,data))
  })

  test_that("check main", {
      args <- c("topography" = "../data/AW3D30.tif",
                "geology" =    "../data/Geology.tif",
                "landcover" =  "../data/Landcover.tif",
                "faults" =     "../data/Confirmed_faults.shp",
                "output" =     "temp.tif",
                "landslides" = "../data/landslides.shp")
      args <- data.frame(t(args))
      main(args)
      expect_gt(file.info("temp.tif")$size,1000000)

      fn <- "temp.tif"
      #Check its existence
      if (file.exists(fn)) {
        file.remove(fn)
      }
  })



  if (requireNamespace("lintr")) {
    library(lintr)

    context("linting script")
    test_that("Coding style", {
      output<-lintr::lint("../terrain_analysis.R")
      expect_lt(length(output),500)
      expect_lt(length(output),400)
      expect_lt(length(output),250)
      expect_lt(length(output),100)
      expect_lt(length(output),50)
      expect_lt(length(output),10)
      expect_equal(length(output),0)
    })
  }
