library(RODBC)

# Note: you must connect to 'uni1' via pulse from the bottom panel in windows to access this database
channel <- odbcDriverConnect('driver={SQL Server};server=SEEDSQL1;database=RealJunkFood;trusted_connection=true')

# which databases are we interested in?
sqlTables(channel, tableType = "TABLE")


sel <- sqlQuery(channel, "SELECT *
                FROM [RealJunkFood].[dbo].[tblIntercept]")

sources = sqlQuery(channel = channel, "SELECT *
                   FROM [RealJunkFood].[dbo].[tblSource]")

library(dplyr)

sel2 = left_join(sel, sources, by = "SourceId")

library(ggplot2)

main_sources = tail(sort(table(sel2$Source)), 10)
s3 = sel2[sel2$Source %in% names(main_sources),]

ggplot(data = s3) +
  geom_bar(aes(Source))
