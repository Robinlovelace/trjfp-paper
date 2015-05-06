# Global plot of RJFP locations
source("setup.R")

jfps <- read_excel("TRJFP CIO Network.xlsx")

# Problem: blank spaces between cities and counties
# Solution 1: with a for loop - for cities first
for(i in 1:nrow(jfps)){
  if(is.na(jfps$City[i]) & is.na(jfps$County[i])){
    jfps$City[i] <- jfps$City[i - 1]
  }
}

# Now for counties
cnty <- jfps$County
for(i in 1:nrow(jfps)){
  if(is.na(cnty[i])){
    cnty[i] <- cnty[i - 1]
  }
}

jfps$County <- cnty

jfps$fullname <- paste(jfps$City, jfps$County, jfps$`Town/district`, sep = " ")
jfps$fullname <- gsub(pattern = "NA", replacement = "", x = jfps$fullname)

xy_locs <- geocode(jfps$fullname)
plot(xy_locs) # most are in the UK; some are not!

jfps <- cbind(jfps, xy_locs)
jfps[jfps$lon < -20,] # places plotted outside uk
jfps$fullname[jfps$lon < -20] <- paste0(jfps$fullname[jfps$lon < -20], " UK")
newlatlon <- geocode(jfps$fullname[jfps$lon < -20])
jfps$lat[jfps$lon < -20] <- newlatlon$lat
jfps$lon[jfps$lon < -20] <- newlatlon$lon

plot(jfps$lon, jfps$lat)
jfps <- jfps[-which(jfps$lon < -20), ]

# Convert to geojson for plotting
jfpsp <- SpatialPointsDataFrame(coords = as.matrix(jfps[c("lon", "lat")]), data = jfps)

plot(jfpsp)
library(geojsonio)
dir.create("outputs")
geojson_write(jfpsp, file = "outputs/ukpoints.geojson")

# I
