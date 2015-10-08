# @knitr setup
library(raster)
library(maptools)
library(data.table)
library(dplyr)
library(parallel)

outDir <- "/workspace/UA/mfleonawicz/projects/DataExtraction/workspaces"
shpDir <- "/workspace/UA/mfleonawicz/projects/DataExtraction/data/shapefiles"

# Political boundaries
# Alaska
Alaska_shp <- shapefile(file.path(shpDir, "Political/Alaska.shp"))
# Western Canada regions
#Alberta_shp <- shapefile(file.path(shpDir, "Political/alberta_albers")) # OLD
#BC_shp <- shapefile(file.path(shpDir, "Political/BC_albers")) # OLD
Canada_shp <- shapefile(file.path(shpDir, "Political/CanadianProvinces_NAD83AlaskaAlbers.shp"))
Canada_IDs <- c("Alberta", "Saskatchewan", "Manitoba", "Yukon Territory", "British Columbia")
Canada_shp <- subset(Canada_shp, NAME %in% Canada_IDs)

# Alaska ecoregions
eco32_shp <- shapefile(file.path(shpDir, "AK_ecoregions/akecoregions.shp"))
eco32_shp <- spTransform(eco32_shp, CRS(projection(Alaska_shp)))
eco9_shp <- unionSpatialPolygons(eco32_shp, eco32_shp@data$LEVEL_2)
eco3_shp <- unionSpatialPolygons(eco32_shp, eco32_shp@data$LEVEL_1)

eco32_IDs <- gsub("\\.", "", as.data.frame(eco32_shp)[,1])
eco9_IDs <- sapply(slot(eco9_shp, "polygons"), function(x) slot(x, "ID"))
eco3_IDs <- sapply(slot(eco3_shp, "polygons"), function(x) slot(x, "ID"))

# LCC regions
LCC_shp <- shapefile(file.path(shpDir, "LCC/LCC_summarization_units_singlepartPolys.shp"))
LCC_IDs <- gsub(" LCC", "", gsub("South", "S", gsub("western", "W", gsub("Western", "W", gsub("North", "N", gsub("  ", " ", gsub("\\.", "", as.data.frame(LCC_shp)[,1])))))))

# CAVM regions
CAVM_shp <- shapefile(file.path(shpDir, "CAVM/CAVM_complete.shp"))
CAVM_IDs <- as.data.frame(CAVM_shp)[,4]

# shapefile lists, names, and associated metadata
grp.names <- c(rep("Political Boundaries", 2), paste0("Alaska L", 3:1, " Ecoregions"), "LCC Regions", "CAVM Regions")
shp.list <- list(Alaska_shp, Canada_shp, eco32_shp, eco9_shp, eco3_shp, LCC_shp, CAVM_shp)
shp.names.list <- list("Alaska", Canada_IDs, eco32_IDs, eco9_IDs, eco3_IDs, LCC_IDs, CAVM_IDs)

# function to extract cell indices from raster by shapefile and return data table
get_cells <- function(i, r, shp, grp, loc, idx=Which(!is.na(r),cells=T)){
    stopifnot(length(shp)==length(grp) & length(shp)==length(loc))
    x <- extract(r, shp[[i]], cellnumbers=T)
    stopifnot(length(x)==length(loc[[i]]))
    for(j in 1:length(x)) if(!is.null(x[[j]])) x[[j]] <- data.table(LocGroup=grp[i], Location=loc[[i]][j], Cell=sort(intersect(x[[j]][,1], idx)))
    rbindlist(x)
}

# @knitr 1km_2km_AKCAN
# For AK-CAN 1-km Alfresco and 2-km climate extractions
dirs <- list.files("/big_scratch/apbennett/Calibration/FinalCalib", pattern=".*.sres.*.", full=T) # alternate
r1km <- readAll(raster(list.files(file.path(dirs[1], "Maps"), pattern="^Age_0_.*.tif$", full=T)[1])) # template
r2km <- readAll(raster("/Data/Base_Data/Climate/AK_CAN_2km/projected/AR5_CMIP5_models/rcp60/5modelAvg/pr/pr_total_mm_AR5_5modelAvg_rcp60_01_2006.tif")) # template
idx1 <- Which(!is.na(r1km),cells=T)
idx2 <- Which(!is.na(r2km),cells=T)

cells1 <- data.table(Source="akcan1km", rbindlist(mclapply(1:length(shp.list), get_cells, r=r1km, shp=shp.list, grp=grp.names, loc=shp.names.list, idx=idx1, mc.cores=32)))
cells1 <- bind_rows(data.table(Source="akcan1km", LocGroup="Political Boundaries", Location="AK-CAN", Cell=idx1), cells1)
cells1 <- data.table(cells1) %>% group_by(Location) %>% mutate(Cell_rmNA=which(c(1:ncell(r1km) %in% Cell)[idx1]))
cells2 <- data.table(Source="akcan2km", rbindlist(mclapply(1:length(shp.list), get_cells, r=r2km, shp=shp.list, grp=grp.names, loc=shp.names.list, idx=idx2, mc.cores=32)))
cells2 <- bind_rows(data.table(Source="akcan2km", LocGroup="Political Boundaries", Location="AK-CAN", Cell=idx2), cells2)
cells2 <- data.table(cells2) %>% group_by(Location) %>% mutate(Cell_rmNA=which(c(1:ncell(r2km) %in% Cell)[idx2]))

cells <- bind_rows(cells1, cells2) %>% data.table %>% group_by(Source, LocGroup, Location) %>% setkey
save(cells, file=file.path(outDir, "shapes2cells_akcan1km2km.RData"))
