library(RODBC)
library(dplyr)
# library(ggplot2)
# Note: you must connect to 'uni1' via pulse from the bottom panel in windows to access this database
# channel <- odbcDriverConnect('driver={SQL Server};server=SEEDSQL1;database=RealJunkFood;trusted_connection=true')
channel <- odbcDriverConnect('driver={SQL Server};server=SEEDSQL1;database=RealJunkFoodProject_080616;trusted_connection=true')

# which databases are we interested in?
# sqlTables(channel, tableType = "TABLE")

intercepts <- sqlQuery(channel, "SELECT * FROM [RealJunkFood].[dbo].[tblIntercept]")
sources = sqlQuery(channel = channel, "SELECT * FROM [RealJunkFood].[dbo].[tblSource]")
donations = sqlQuery(channel = channel, "SELECT * FROM [RealJunkFood].[dbo].[tblDonation]")
cafes = sqlQuery(channel = channel, "SELECT * FROM [RealJunkFood].[dbo].[tlkpCafe]")

# names(intercepts)
# unique(intercepts$CafeId)

intercepts = left_join(intercepts, sources, by = "SourceId")


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