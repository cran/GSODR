## ----check_packages, echo=FALSE, messages=FALSE, warning=FALSE-----------
required <- c("ggplot2", "tidyr", "lubridate")

if (!all(unlist(lapply(required, function(pkg) requireNamespace(pkg, quietly = TRUE)))))

  knitr::opts_chunk$set(eval = FALSE, collapse = TRUE, comment = "#>", fig.width = 7, fig.height = 7, fig.align = "center")

## ---- eval=TRUE----------------------------------------------------------
library(GSODR)
library(dplyr)
load(system.file("extdata", "country_list.rda", package = "GSODR"))
load(system.file("extdata", "isd_history.rda", package = "GSODR"))

station_locations <- left_join(isd_history, country_list,
                               by = c("CTRY" = "FIPS"))

# create data.frame for Australia only
Oz <- filter(station_locations, COUNTRY_NAME == "AUSTRALIA")

Oz

Oz %>%
  filter(grepl("TOOWOOMBA", STN_NAME))

## ---- eval=TRUE----------------------------------------------------------
tbar <- get_GSOD(years = 2010, station = "955510-99999")

tbar

## ---- eval=FALSE---------------------------------------------------------
#  tbar_stations <- nearest_stations(LAT = -27.5598,
#                                    LON = 151.9507,
#                                    distance = 50)
#  
#  tbar <- get_GSOD(years = 2010, station = tbar_stations)

## ---- eval=FALSE, message=FALSE------------------------------------------
#  remove <- c("949999-00170", "949999-00183")
#  
#  tbar_stations <- tbar_stations[!tbar_stations %in% remove]
#  
#  tbar <- get_GSOD(years = 2010,
#                   station = tbar_stations,
#                   dsn = "~/")

## ---- eval=TRUE, fig.width = 7, fig.height = 7, fig.align = "center"-----
library(ggplot2)
library(lubridate)
library(tidyr)

# Create a dataframe of just the date and temperature values that we want to
# plot
tbar_temps <- tbar[, c("YEARMODA", "TEMP", "MAX", "MIN")]

# Gather the data from wide to long
tbar_temps <- gather(tbar_temps, Measurement, gather_cols = TEMP:MIN)

ggplot(data = tbar_temps, aes(x = ymd(YEARMODA), y = value,
                              colour = Measurement)) +
  geom_line() +
  scale_color_brewer(type = "qual", na.value = "black") +
  scale_y_continuous(name = "Temperature") +
  scale_x_date(name = "Date") +
  theme_bw()

## ---- eval=FALSE---------------------------------------------------------
#  get_GSOD(years = 2015, country = "Australia", dsn = "~/", filename = "AUS",
#           CSV = FALSE, GPKG = TRUE)
#  #> trying URL 'ftp://ftp.ncdc.noaa.gov/pub/data/gsod/2015/gsod_2015.tar'
#  #> Content type 'unknown' length 106352640 bytes (101.4 MB)
#  #> ==================================================
#  #> downloaded 101.4 MB
#  
#  
#  #> Finished downloading file.
#  
#  #> Starting data file processing.
#  
#  
#  #> Writing GeoPackage file to disk.

## ---- eval=FALSE---------------------------------------------------------
#  library(rgdal)
#  #> Loading required package: sp
#  #> rgdal: version: 1.1-10, (SVN revision 622)
#  #>  Geospatial Data Abstraction Library extensions to R successfully loaded
#  #>  Loaded GDAL runtime: GDAL 1.11.5, released 2016/07/01
#  #>  Path to GDAL shared files: /usr/local/Cellar/gdal/1.11.5_1/share/gdal
#  #>  Loaded PROJ.4 runtime: Rel. 4.9.3, 15 August 2016, [PJ_VERSION: 493]
#  #>  Path to PROJ.4 shared files: (autodetected)
#  #>  Linking to sp version: 1.2-3
#  
#  AUS_stations <- readOGR(dsn = path.expand("~/AUS.gpkg"), layer = "GSOD")
#  #> OGR data source with driver: GPKG
#  #> Source: "/Users/asparks/AUS-2015.gpkg", layer: "GSOD"
#  #> with 186977 features
#  #> It has 46 fields
#  
#  class(AUS_stations)
#  #> [1] "SpatialPointsDataFrame"
#  #> attr(,"package")
#  #> [1] "sp"

## ---- eval=FALSE---------------------------------------------------------
#  AUS_sqlite <- tbl(src_sqlite(path.expand("~/AUS.gpkg")), "GSOD")
#  class(AUS_sqlite)
#  #> [1] "tbl_dbi"  "tbl_sql"  "tbl_lazy" "tbl"

## ---- eval=FALSE---------------------------------------------------------
#  y <- c("~/GSOD/gsod_1960/200490-99999-1960.op.gz",
#         "~/GSOD/gsod_1961/200490-99999-1961.op.gz")
#  x <- reformat_GSOD(file_list = y)

## ---- eval=FALSE---------------------------------------------------------
#  x <- reformat_GSOD(dsn = "~/GSOD/gsod_1960")

## ---- eval=FALSE---------------------------------------------------------
#  inventory <- get_inventory()
#  
#  inventory
#  
#  subset(inventory, STNID == "955510-99999")

## ---- eval=FALSE---------------------------------------------------------
#  #install.packages("devtools")
#  devtools::install_github("adamhsparks/GSODRdata")
#  library("GSODRdata")

## ---- eval=TRUE, message = FALSE, echo = FALSE, warning=FALSE, fig.width = 7, fig.height = 5, fig.align = "center"----
if (requireNamespace("ggplot2", quietly = TRUE) &&
    requireNamespace("ggthemes", quietly = TRUE) &&
    requireNamespace("maps", quietly = TRUE) &&
    requireNamespace("mapproj", quietly = TRUE) &&
    requireNamespace("gridExtra", quietly = TRUE) &&
    requireNamespace("grid", quietly = TRUE)) {
  library(ggplot2)
  library(mapproj)
  library(ggthemes)
  library(maps)
  library(grid)
  library(gridExtra)
  library(GSODR)
  load(system.file("extdata", "isd_history.rda", package = "GSODR"))
  world_map <- map_data("world")

  GSOD_stations <- ggplot(isd_history, aes(x = LON, y = LAT)) +
    geom_polygon(data = world_map, aes(x = long, y = lat, group = group),
                 color = grey(0.7),
                 fill = NA) +
    geom_point(color = "red",
               size = 0.05) +
    coord_map(xlim = c(-180, 180)) +
    theme_map() +
    labs(title = "GSOD Station Locations",
         caption = "Data: US NCEI GSOD and CIA World DataBank II")

  # Using the gridExtra and grid packages add a neatline to the map
  grid.arrange(GSOD_stations, ncol = 1)
  grid.rect(width = 0.98,
            height = 0.98,
            gp = grid::gpar(lwd = 0.25,
                            col = "black",
                            fill = NA))
}

