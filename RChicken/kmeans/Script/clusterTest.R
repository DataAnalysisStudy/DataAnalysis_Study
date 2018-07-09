########## kmeans

rm(list=ls())

library(plotly)

dat <- iris[, 1:4]
source("kmeans/Script/kmeans.R")
findCluster(data = dat) ## 5
sqrt(nrow(dat)/2)

result <- kmeans(dat, 3)
dat$cluster <- result$cluster
table(dat$cluster, iris$Species)
plot_ly(dat, x = ~Sepal.Length, y = ~Petal.Length, color = ~as.factor(cluster))
plot_ly(dat, x = ~Sepal.Length, y = ~Petal.Length, z = ~Petal.Width, color = ~as.factor(cluster))

########## radar graph
source("kmeans/Script/polarChart.R")
for(i in 1:(length(dat) - 1)) dat[, i] <- MaxMinScale(dat[, i]) 
dat <- dat[, c(5, 1:4)]

clusterResult <- ClusterMean(dat)
colNam <- colnames(iris)[1:4]
ggRadar(clusterResult[, c("cluster", colNam)], groupvar = "cluster") + facet_wrap("cluster") 


