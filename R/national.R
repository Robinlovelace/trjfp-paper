# Load, plot national stats
pkgs <- c("XLConnect", "ggplot2", "dplyr", "gridExtra")
lapply(pkgs, library, character.only = T)

wb = loadWorkbook("Stats & Figures/2014 TRJFP national stats.xls")
nstat <- readWorksheet(object = wb, sheet = 1)
names(nstat) <- abbreviate(nstat[1,], minlength = 5)
names(nstat)[c(1, 4, 7, 8)] <- c("Location", "Intercepted", "Donations", "Hours")
nstat <- nstat[-1,]
nstat <- nstat[-nrow(nstat),]

nstat[c("Intercepted", "Pplfd", "Mlsmd", "Donations", "Hours")] <-
  apply(nstat[c("Intercepted", "Pplfd", "Mlsmd", "Donations", "Hours")], 2, FUN = function(x) as.numeric(as.character(x)))

nstat$Location <- gsub(pattern = "TRJFP |CURB: ", "", nstat$Location)
nstat$Location <- declutter(nstat$Location)
# nstat$Location[nstat$Location == "Veggie Shack"] <- "Portales"
nstat$Intercepted <- nstat$Intercepted / 1000000

(p1 <- ggplot(nstat) +
  geom_bar(aes(Location, Intercepted, fill = Location), stat = "identity") +
  theme(axis.text.x = element_text(angle = 90),
    axis.title.x = element_blank()) +
  scale_fill_discrete(guide = F) +
  ylab("Tonnes Intercepted") +
  ggtitle("2014"))

wb = loadWorkbook("Stats & Figures/2014 TRJFP national stats.xls")
nstat <- readWorksheet(object = wb, sheet = 2)
names(nstat) <- abbreviate(nstat[1,], minlength = 5)
names(nstat)[c(1, 4, 7, 8)] <- c("Location", "Intercepted", "Donations", "Hours")
nstat <- nstat[-1,]
nstat <- nstat[-nrow(nstat),]

nstat[c("Intercepted", "Pplfd", "Mlsmd", "Donations", "Hours")] <-
  apply(nstat[c("Intercepted", "Pplfd", "Mlsmd", "Donations", "Hours")], 2, FUN = function(x) as.numeric(as.character(x)))

nstat$Location <- gsub(pattern = "TRJFP |CURB: ", "", nstat$Location)
nstat$Location[nstat$Location == "All Hallows"] <- "Hyde Park"
nstat$Location <- declutter(nstat$Location)
nstat$Location[nstat$Location == "Veggie Shack"] <- "Portales"
nstat$Intercepted <- nstat$Intercepted / 1000000

(p2 <- ggplot(nstat) +
  geom_bar(aes(Location, Intercepted, fill = Location), stat = "identity") +
  theme(axis.text.x = element_text(angle = 90)) +
  scale_fill_discrete(guide = F) +
  ylab("Tonnes Intercepted") +
  ggtitle("2015"))


grid.arrange(p2, p1)
