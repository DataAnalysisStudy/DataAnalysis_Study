gps1 <- read.csv('gps_u00.csv')
str(gps1)
install.packages('ggmap')
library(ggmap)
mapImageData <- get_googlemap(center = c(lon = median(gps1$longitude), lat = median(gps1$latitude)),
                              zoom = 8,
                              # size = c(500, 500),
                              maptype = c("terrain"))
ggmap(mapImageData,
      extent = "device") + # takes out axes, etc.
  geom_point(aes(x = longitude,
                 y = latitude),
             data = gps1,
             colour = "red",
             size = 1,
             pch = 20)

gps2 <- read.csv('gps_u01.csv')
str(gps2)

ggmap(mapImageData,
      extent = "device") + # takes out axes, etc.
  geom_point(aes(x = longitude,
                 y = latitude),
             data = gps2,
             colour = "green",
             size = 1,
             pch = 20)

