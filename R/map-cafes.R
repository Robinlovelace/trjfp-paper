# Global plot of RJFP locations
source("setup.R")

# Green = functioning; Yellow = setting up; Blue = shut-down
f <- "TRJFP CIO Network.xlsx"
jfps <- read_excel(f)
head(jfps)
# names(jfps)[c(3, 4)] <- c("District", "Name")

# Problem: blank spaces between cities and counties
# Solution 1: with a for loop - for cities first
for(i in 1:nrow(jfps)){
  if(is.na(jfps$City[i]) & is.na(jfps$County[i])){
    jfps$City[i] <- jfps$City[i - 1]
  }
}

head(jfps$City, 100)

# Now for counties
cnty <- jfps$County
for(i in 1:nrow(jfps)){
  if(is.na(cnty[i])){
    cnty[i] <- cnty[i - 1]
  }
}

jfps$County <- cnty

# Clean the data - remove rows with no contact
nrow(jfps)
jfps <- jfps[!is.na(jfps$Contacts),]
nrow(jfps)

jfps$fullname <- paste(jfps$City, jfps$County, jfps$`Town/district`, sep = " ")
jfps$fullname <- gsub(pattern = "NA", replacement = "", x = jfps$fullname)
jfps$fullname <- paste0(jfps$fullname, " UK")

xy_locs <- geocode(jfps$fullname)
plot(xy_locs) # most are in the UK; some are not!

jfps <- cbind(jfps, xy_locs)

jfps[jfps$lon < -20,] # places plotted outside uk

jfps$Status[is.na(jfps$Status)] <- "enquiry"

# Convert to geojson for plotting
jfpsp <- SpatialPointsDataFrame(coords = as.matrix(jfps[c("lon", "lat")]), data = jfps)

saveRDS(jfpsp, "data/jfpsp.Rds")

plot(jfpsp)

bb <- ggmap::make_bbox(jfps$lon, jfps$lat)

jfps$Status <- factor(jfps$Status)
jfps$Status <- factor(jfps$Status, levels = rev(levels(jfps$Status)))

levels(jfps$Status)
p2 <- ggmap(get_map(bb)) +
  geom_point(aes(x = lon, y = lat, shape = Status, color = Status, size = Status),
    data = jfps, alpha = 0.7) +
  theme_nothing(legend = T) +
  scale_color_manual(values = c("black", "red", "yellow", "blue")) +
  scale_size_manual(values = c(4, 3, 2, 4))

library(gridExtra)

bbwy <- nominatim::bb_lookup("West Yorkshire")
bbnum <- as.numeric(as.character(bbwy[1,c("left", "bottom", "right", "top")]))
make_bbox(bbnum)
p1 <- ggmap(get_map(location = c(-2, 53.6, -1.1988144, 53.9632249))) +
  geom_point(aes(x = lon, y = lat, shape = Status, color = Status, size = Status),
    data = jfps, alpha = 0.7) +
  theme_nothing(legend = T) +
  scale_color_manual(values = c("black", "red", "yellow", "blue")) +
  scale_size_manual(values = c(4, 3, 2, 4))

grid.arrange(p2, p1, nrow = 2)

# global distribution now!

sheets <- readxl::excel_sheets(f)



library(geojsonio)

# Pause; save
# dir.create("outputs")
# geojson_write(jfpsp, file = "outputs/ukpoints.geojson")
jfps <- readOGR("outputs/ukpoints.geojson", layer = "OGRGeoJSON")
jfps <- geojson_read("outputs/ukpoints.geojson")

cafs <- jfps[!is.na(jfps$Name),]
cafdat <- cbind(cafs@data, coordinates(cafs))
write.csv(cafs@data, "outputs/cafs.csv")
geojsonio::geojson_write(cafs, file = "outputs/cafs.geojson")

library(leaflet)

head(jfps, 30)
leaflet() %>% addTiles() %>% addCircles(data = jfps) %>%
  addPopups(data = jfps[!is.na(jfps$Name),], popup = jfps$Name[!is.na(jfps$Name)])

# cafs <- read_excel(paste0(ddir, "network opening dates.xlsx"))
# names(cafs)[1] <- "Name"
#
# cafs$Name[cafs$Name %in% jfps$Name]
# cafs$Name[!cafs$Name %in% jfps$Name]
