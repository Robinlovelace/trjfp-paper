library(RODBC)
library(dplyr)
library(lubridate)
# library(ggplot2)
# Note: you must connect to 'uni1' via pulse from the bottom panel in windows to access this database
# channel <- odbcDriverConnect('driver={SQL Server};server=SEEDSQL1;database=RealJunkFoodProject;trusted_connection=true')
channel <- odbcDriverConnect('driver={SQL Server};server=SEEDSQL1;database=RealJunkFoodProject_080616;trusted_connection=true')

# which databases are we interested in?
# sqlTables(channel, tableType = "TABLE")

intercepts <- sqlQuery(channel, "SELECT * FROM tblIntercept")
sources = sqlQuery(channel = channel, "SELECT * FROM tlkpSource")
donations = sqlQuery(channel = channel, "SELECT * FROM tblDonation")
cafes = sqlQuery(channel = channel, "SELECT * FROM tlkpCafe")
product = sqlQuery(channel = channel, "SELECT * FROM tlkpProduct")

# names(intercepts)
# unique(intercepts$CafeId)

# Pre-processing
intercepts$Quarter = floor_date(intercepts$DateIntercepted, "quarter")
intercepts$Month = floor_date(intercepts$DateIntercepted, "month")
intercepts$Week = floor_date(intercepts$DateIntercepted, "week")
intercepts = left_join(intercepts, sources, by = "SourceId")
intercepts = left_join(intercepts, product)

# class(intercepts$DateIntercepted)

# Analysis
# (main_sources = tail(sort(table(intercepts$Source)), 10))
#
# ggplot(data = intercepts) +
#   geom_bar(aes(Source))





# install.packages("RMySQL") # with new RMySQL package
# library(dplyr)
# library(RMySQL)
# ?`RMySQL-package`
# con <- dbConnect(RMySQL::MySQL(), dbname = "RealJunkFood", server="SEEDSQL1", trusted_connection = "true")
# src_mysql(dbname = "RealJunkFoodProject_080616", host = "SEEDSQL1")