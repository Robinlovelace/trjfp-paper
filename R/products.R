# Re-format dates

ints <- read.csv("data/TRJFP-all-intercepts.csv", stringsAsFactors = FALSE)
ints <- ints[!ints$date == "",]

# Re-format data from Armley
schar <- grepl(pattern = "[a-z]", x = ints$date)
sum(schar)
plot(schar)
dwrong <- ints$date[schar]
head(dwrong)
s2014 <- grepl(pattern = "Dec", dwrong)
dwrong[s2014] <- paste0(dwrong[s2014], "-2014")
dwrong[!s2014] <- paste0(dwrong[!s2014], "-2015")
dright <- strptime(x = dwrong, format = "%d-%b-%Y")
length(dright)
summary(dright)
length(ints$date[schar])
dgood <- ints$date[!schar]
dgood <- strptime(x = dgood, format = "%m/%d/%Y")
summary(dgood)
newdate <- c(dright, dgood)
summary(newdate)
ints$date <- newdate
write.csv(ints, "data/TRJFP-all-intercepts.csv")

library(readxl)
library(tidyr)
km <- read_excel("data/TRJFP national stats-Nov.xlsx", sheet = "Leeds Kirkgate Market")
km <- km[1:105]
names(km)[1] <- "Date"
# sort out dates
head(km$Date)
km$Date <- as.Date(km$Date, origin="1899-12-30")

km <- gather(km, product, weight, -Date)
head(km)

km <- km[!is.na(km$weight),]

# write the output
# devtools::install_github("marcschwartz/WriteXLS")
# WriteXLS::WriteXLS(km, "/tmp/kirkgate.xlsx")
# install.packages("xlsx")
km$Location <- "Leeds Kirkgate Market"
xlsx::write.xlsx(km, "/tmp/kirkgate.xlsx")

# Morrisons
m <- read_excel("data/TRJFP national stats-Nov.xlsx", sheet = "Morrisons")

m$Date <- zoo::na.locf(m$Date)
m$Date <- as.Date(m$Date, origin="1899-12-30")
m <- m[rep(seq_len(nrow(m)), 8),]

for(i in 2:8){
  col2move <- i * 2
  col2move2 <- col2move + 1
  endrow <- nrow(m) / 8
  newstart <- nrow(m) / 8 * (i - 1) + 1
  newend <- newstart + nrow(m) / 8 - 1
  m[newstart:newend, 2:3] <- m[1:(nrow(m) / 8), col2move:col2move2]
}

m <- m[!is.na(m[2]),]
m <- m[1:3]
m$Location <- "Morrisons Leeds"
xlsx::write.xlsx(m, "/tmp/morrisons.xlsx")

# Find top n. items
df <- read.csv("payf.csv")

tail(sort(table(df$product)), n = 50)

library(dplyr)

df$product %>%
  table() %>%
  sort() %>%
  tail(n = 10)
