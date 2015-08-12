# Aim: analyse the national stats
ns <- read_excel("data/TRJFP national stats sheet.xlsx")
head(ns)
plot(ns$Day, ns$`Meals Made`)
ggplot(ns) + geom_bar(aes(x = Day, y = `Meals Made`), stat = "identity") +
  xlab("Day of the month") + ggtitle("Meals made in Armley cafe in July. Total: 743")

ggsave("figures/meals-made-july-eg.png")


