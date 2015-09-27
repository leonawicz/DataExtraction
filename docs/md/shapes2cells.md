# Shapefiles to Raster Cell Indices
Matthew Leonawicz  




## Introduction
**R** code is provided showing how I convert polygon shapefiles to lists of raster cell indices.

### Motivation
At SNAP I often find myself performing large numbers of data extractions on raster layers using shapefiles.
This can be time consuming with respect to our high-resolution downscaled geotiffs.
Large raster layers in combination with large (or large numbers of) shapefiles can slow processing time considerably by repeatedly computing the raster cell indices from the shapefile for raster data extraction.
Repeating extraction by shapefile on millions of raster layers multiplies this computational overhead.

Such processing is commonplace at SNAP and almost any data extraction done once is bound to recur at a later date in some overlapping and redundant sense.
I have moved toward an a priori establishment of the more preliminary and repetitive aspects of common spatial data extraction tasks at SNAP.
One of the most convenient and beneficial steps taken is computing cells indices linking a shapefile to a raster layer once and storing the indices.
Subsequently, the indices can be used directly for extraction from a sequence of many rasters matching the geographical meta data of the initial template raster.
Having easy, immediate access to these cell indices pertaining to multiple shapefiles in the context of multiple rasterized source data sets
is convenient and speeds processing over having to use source shapefiles millions of times per project let alone across multiple projects..

### Details
I compile the following:

* Lists of commonly used groups of polygon shapefiles
* Key raster/geotiff format data sets from which we commonly extract data
* Settings pertaining to the methods and circumstances under which cell indexing can occur in anticipated, subsequent data extraction exercises

#### Capabilities
The most straightforward purpose here is to obtain a data table with factor columns (ID columns) and cell number columns describing the following:

* Source rasters, e.g., Alaska-Canada 1-km vs. Alaska-Canada 2-km raster data.
* Group names for similarly grouped shapefile inputs, e.g., political boundaries vs. ecologically defined regions.
* Individual shapefile region location names
* Cell indices are extracted from each shapefile and placed in a column with respect to each combination of factor levels.
* A second column of cell indices represents a transformation of the first for use when raster extractions require indexing based on a priori removal of NA-valued cells.
This can be highly efficient in certain contexts where maps are largely NA-valued. Many of our rasters already have millions of NA-valued cells outside of an oddly shaped geographic domain.
Raster layers can then become almost fully NA-valued when working with data such as annual fire perimiters across a large geographical area.
* The long format data table structure allows for easy ad hoc sampling by factor level grouping to extract data from rasters using a fixed sample size or sampling proportional to region size rather than using all cells.

#### Limitations and current scope
Obviously, the vector of cell indices for a shapefile differs for different rasterized data sets.
Currently, cell indices for 59 shapefiles are stored in a table and saved to an **R** workspace file for two common rasterized data products at SNAP:

* Alaska-Canada 2-km downscaled climate data
* Alaska-Canada 1-km Alfresco simulation data

## Related items

### Files and Data
Input files include polygon shapefiles commonly used at SNAP and two of SNAP's current geotiff data products, Alaska-Canada 2-km downscaled climate data and 1-km Alfresco simulation outputs.
Output files are **R** workspaces, .RData files.
There is one workspace storing each version of a nested list for each type of rasterized data set.

## R code

### Setup

Load required packages, define output directory, and load shapefiles.
Shapefiles are organized into related groups.
I ensure certain idiosyncrasies are addressed, such as reprojection of shapefiles with differing coordinate reference systems.
Some shapefiles also contain single polygon regions whereas others contain multiple.
Care must be taken to ensure all object manipulation is as intended.


```r
library(raster)
library(maptools)
library(data.table)
library(dplyr)
library(parallel)

outDir <- "/workspace/UA/mfleonawicz/projects/DataExtraction/workspaces"
shpDir <- "/workspace/UA/mfleonawicz/projects/DataExtraction/data/shapefiles"

# Political boundaries Alaska
Alaska_shp <- shapefile(file.path(shpDir, "Political/Alaska"))
# Western Canada regions Alberta_shp <- shapefile(file.path(shpDir,
# 'Political/alberta_albers')) # OLD BC_shp <- shapefile(file.path(shpDir,
# 'Political/BC_albers')) # OLD
Canada_shp <- shapefile(file.path(shpDir, "Political/CanadianProvinces_NAD83AlaskaAlbers"))
Canada_IDs <- c("Alberta", "Saskatchewan", "Manitoba", "Yukon Territory", "British Columbia")
Canada_shp <- subset(Canada_shp, NAME %in% Canada_IDs)

# Alaska ecoregions
eco32_shp <- shapefile(file.path(shpDir, "AK_ecoregions/akecoregions"))
eco32_shp <- spTransform(eco32_shp, CRS(projection(Alaska_shp)))
eco9_shp <- unionSpatialPolygons(eco32_shp, eco32_shp@data$LEVEL_2)
eco3_shp <- unionSpatialPolygons(eco32_shp, eco32_shp@data$LEVEL_1)

eco32_IDs <- gsub("\\.", "", as.data.frame(eco32_shp)[, 1])
eco9_IDs <- sapply(slot(eco9_shp, "polygons"), function(x) slot(x, "ID"))
eco3_IDs <- sapply(slot(eco3_shp, "polygons"), function(x) slot(x, "ID"))

# LCC regions
LCC_shp <- shapefile(file.path(shpDir, "LCC/LCC_summarization_units_singlepartPolys"))
LCC_IDs <- gsub(" LCC", "", gsub("South", "S", gsub("western", "W", gsub("Western", 
    "W", gsub("North", "N", gsub("  ", " ", gsub("\\.", "", as.data.frame(LCC_shp)[, 
        1])))))))

# CAVM regions
CAVM_shp <- shapefile(file.path(shpDir, "CAVM/CAVM_complete"))
CAVM_IDs <- as.data.frame(CAVM_shp)[, 4]

# shapefile lists, names, and associated metadata
grp.names <- c(rep("Political Boundaries", 2), paste0("Alaska L", 3:1, " Ecoregions"), 
    "LCC Regions", "CAVM Regions")
shp.list <- list(Alaska_shp, Canada_shp, eco32_shp, eco9_shp, eco3_shp, LCC_shp, 
    CAVM_shp)
shp.names.list <- list("Alaska", Canada_IDs, eco32_IDs, eco9_IDs, eco3_IDs, 
    LCC_IDs, CAVM_IDs)

# function to extract cell indices from raster by shapefile and return data
# table
get_cells <- function(i, r, shp, grp, loc, idx = Which(!is.na(r), cells = T)) {
    stopifnot(length(shp) == length(grp) & length(shp) == length(loc))
    x <- extract(r, shp[[i]], cellnumbers = T)
    stopifnot(length(x) == length(loc[[i]]))
    for (j in 1:length(x)) if (!is.null(x[[j]])) 
        x[[j]] <- data.table(LocGroup = grp[i], Location = loc[[i]][j], Cell = sort(intersect(x[[j]][, 
            1], idx)))
    rbindlist(x)
}
```

### Example
Representative map layers are loaded with the `raster` package.
Cell indices with respect to each template raster layer are obtained efficiently for several shapefiles using `mclapply` from the `parallel` package.
A full domain (Alaska-Canada) set of indices using all data-valued cells is prepended to the table for each source layer since no full-domain shapefile was used.
Tables for each source are combined.
Results are saved.


```r
# For AK-CAN 1-km Alfresco and 2-km climate extractions
dirs <- list.files("/big_scratch/apbennett/Calibration/FinalCalib", pattern = ".*.sres.*.", 
    full = T)  # alternate
r1km <- readAll(raster(list.files(file.path(dirs[1], "Maps"), pattern = "^Age_0_.*.tif$", 
    full = T)[1]))  # template
r2km <- readAll(raster("/Data/Base_Data/Climate/AK_CAN_2km/projected/AR5_CMIP5_models/rcp60/5modelAvg/pr/pr_total_mm_AR5_5modelAvg_rcp60_01_2006.tif"))  # template
idx1 <- Which(!is.na(r1km), cells = T)
idx2 <- Which(!is.na(r2km), cells = T)

cells1 <- data.table(Source = "akcan1km", rbindlist(mclapply(1:length(shp.list), 
    get_cells, r = r1km, shp = shp.list, grp = grp.names, loc = shp.names.list, 
    idx = idx1, mc.cores = 32)))
cells1 <- bind_rows(data.table(Source = "akcan1km", LocGroup = "Political Boundaries", 
    Location = "AK-CAN", Cell = idx1), cells1)
cells1 <- data.table(cells1) %>% group_by(Location) %>% mutate(Cell_rmNA = which(c(1:ncell(r1km) %in% 
    Cell)[idx1]))
cells2 <- data.table(Source = "akcan2km", rbindlist(mclapply(1:length(shp.list), 
    get_cells, r = r2km, shp = shp.list, grp = grp.names, loc = shp.names.list, 
    idx = idx2, mc.cores = 32)))
cells2 <- bind_rows(data.table(Source = "akcan2km", LocGroup = "Political Boundaries", 
    Location = "AK-CAN", Cell = idx2), cells2)
cells2 <- data.table(cells2) %>% group_by(Location) %>% mutate(Cell_rmNA = which(c(1:ncell(r2km) %in% 
    Cell)[idx2]))

cells <- bind_rows(cells1, cells2) %>% data.table %>% group_by(Source, LocGroup, 
    Location) %>% setkey
save(cells, file = file.path(outDir, "shapes2cells_akcan1km2km.RData"))
```
