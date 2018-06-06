reprex::reprex(si = T, {
# aim: extract regional stats from data

# setup -------------------------------------------------------------------

setwd("/home/robin/paper-repos/trjfp-paper/")
library(future)
plan("multisession")
library(tidyverse)
devtools::install_github("robinlovelace/ukboundaries")
library(ukboundaries)
# run these lines in bash on Ubuntu or manually unrar pre-downloaded files:
# sudo apt-get install p7zip-rar
# 7z x AllInterceptsToDate.rar
# d %<-% gdata::read.xls("AllInterceptsToDate.xls")
# d = as_tibble(d)
# saveRDS(d, "AllInterceptsToDate.rds")
d = readRDS("AllInterceptsToDate.rds")
d$DateIntercepted = lubridate::as_date(d$DateIntercepted)

# sanity checks and viz ---------------------------------------------------

# summary of the data
dim(d)
summary(d)

# cafes by number of items - with at least n items:
n = 50
cafes_working = d %>% 
  group_by(Cafe) %>% 
  summarise(n = n()) %>% 
  arrange(desc(n)) %>% 
  filter(n > 50)
cafes_working

d = d %>% filter(Cafe %in% cafes_working$Cafe)

# filter-out very large quantities - more than 50 tonnes - most say 100 Tonnes
max_quantity = 50e6
d %>% filter(Quantity > max_quantity)
d = d %>% filter(Quantity < max_quantity)

# filter-out quantities that are not weights (for now)
d = d %>% filter(IsWeight == 1)

# separate large from small cafes
# plot(cafes_working$n) # most productive: top 10
large_cafe = cafes_working$Cafe[1:5] %>% 
  as.character()
d$Cafes = d$Cafe
d$Cafes = as.character(d$Cafes)
d$Cafes[!d$Cafe %in% large_cafe] = NA
d$Cafes[is.na(d$Cafes)] = "Other"
summary(as.factor(d$Cafes))
summary(nchar(large_cafe))
# (longest_name = large_cafe[which.max(nchar(large_cafe))])
# d$Cafes[d$Cafes == longest_name] = "Bethesda"

# time series analysis ----------------------------------------------------

# plot(d$Quantity, d$DateIntercepted)
d$month = lubridate::round_date(d$DateIntercepted, unit = "month")
dym = d %>% 
  group_by(month) %>% 
  summarise(n = n(), tonnes = sum(Quantity) / 1e6)
# plot(dym$month, dym$tonnes)
ggplot(dym) +
  geom_line(aes(month, tonnes))
dym_cafes = d %>% 
  group_by(month, Cafes) %>% 
  summarise(n = n(), tonnes = sum(Quantity) / 1e6) %>% 
  arrange(Cafes, tonnes)
ggplot(dym_cafes) +
  geom_bar(aes(month, tonnes, fill = Cafes), position = "stack", stat = "identity")

})
