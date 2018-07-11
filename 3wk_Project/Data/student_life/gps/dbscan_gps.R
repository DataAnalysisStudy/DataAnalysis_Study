install.packages('maps')
library(ggplot2)
library(dplyr)
library(maps)
install.packages('dbscan')
library(dbscan)

data("world.cities")
CD <- world.cities %>% filter(country.etc == "US")

gps = gps1[,5:6]
str(gps)
EPS <- 0.15
clusters <- dbscan(select(gps,latitude, longitude), eps = EPS)
CD$cluster <- clusters$cluster
groups  <- CD %>% filter(cluster != 0)
noise  <- CD %>% filter(cluster == 0)

ggplot(CD, aes(x = long, y = lat, alpha = 0.5)) + 
  geom_point(aes(fill = "grey"), noise) +
  geom_point(aes(colour = as.factor(cluster)), groups,
             size = 3) +
  coord_map() +
  theme(legend.position = "none")
