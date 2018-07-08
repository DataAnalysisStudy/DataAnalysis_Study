########## Cluster 수 찾기 
findCluster <- function(data, nc = 15){
  wss <- (nrow(data) - 1) * sum(apply(data, 2, var))
  for(i in 2:nc){
    wss[i] <- sum(kmeans(data, k = i)$wss)
  }
  plot(2:nc, wss[2:nc], type = 'b')
}


########## Kmeans 기본 알고리즘 Forgy
kmeans <- function(data, k){
  
  ######## 초기 배정 및 wss 구함 
  
  index <- sort(sample(1:nrow(data), k))
  di <- as.data.frame(as.matrix(dist(data)))
  di <- di[, index]
  cluster <- as.vector(apply(di, 1, which.min))
  center <- as.data.frame(matrix(0, nrow = k, ncol = length(data)))
  colnames(center) <- colnames(data)
  wss <- as.numeric()
  wssNew <- 0
  
  for(i in 1:k){
    wssTemp <- di[cluster == i, i]
    wss <- c(wss, sum(wssTemp))
    rm(wssTemp)
  }
  
  # plot_ly(data, x = ~Sepal.Length, y = ~Petal.Length, color = as.factor(cluster))
  # plot_ly(data, x = ~Sepal.Length, y = ~Petal.Length, z = ~Petal.Width, color = as.factor(cluster))
  
  ##### 분류된 클러스터로 재반복 실시 
  count = 0
  while(sum(wssNew) < sum(wss)){
    
    if(count != 0){
      wss <- wssNew
      cluster <- clusterNew
    }
    
    for(centerCol in 1:length(data)){
      center[, centerCol] <- tapply(data[, centerCol], cluster, mean)
    }
    
    di <- as.data.frame(as.matrix(dist(rbind(center, data))))
    di <- di[-c(1:k), 1:k]
    
    clusterNew <- as.vector(apply(di, 1, which.min))
    wssNew <- as.numeric()
    
    for(i in 1:k){
      wssTemp <- di[clusterNew == i, i]
      wssNew <- c(wssNew, sum(wssTemp))
      rm(wssTemp)
    }
    
    count <- count + 1
    
  }
  
  wssMean = wss/tapply(cluster, cluster, length)
  
  return(list(cluster = cluster, wss = wss, wssMean = wssMean, center = center, count = count))
  
}
