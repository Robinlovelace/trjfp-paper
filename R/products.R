df <- read.csv("payf.csv")

tail(sort(table(df$product)), n = 50)

library(dplyr)

df$product %>%
  table() %>%
  sort() %>%
  tail(n = 10)
