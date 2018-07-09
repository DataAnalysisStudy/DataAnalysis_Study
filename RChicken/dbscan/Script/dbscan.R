rm(list = ls())
library(dplyr)
library(plotly)

iris <- iris
data <- iris[1:4]

theta <- seq(-pi, pi, length = 1000)
x1 <- 30 * cos(theta) + rnorm(1000, 0, 1)
y1 <- 30 * sin(theta) + rnorm(1000, 0, 1)
z1 <- 60 + rnorm(1000, 0, 1)
x2 <- 20 * cos(theta) + rnorm(1000, 0, 1)
y2 <- 20 * sin(theta) + rnorm(1000, 0, 1)
z2 <- 40 + rnorm(1000, 0, 1)
x3 <- 10 * cos(theta) + rnorm(1000, 0, 1)
y3 <- 10 * sin(theta) + rnorm(1000, 0, 1)
z3 <- 20 + rnorm(1000, 0, 1)

data <- data.frame(x = c(x1, x2, x3),
                   y = c(y1, y2, y3),
                   z = c(z1, z2, z3))

plot_ly(data, x = ~x, y = ~y)
plot_ly(data, x = ~x, y = ~y, z = ~z)

dbscan <- function(data, eps = NA, minPts = NA){
  
  ## minPts와 eps 계산 ####
  minPts <- round(nrow(data) * 0.002) ## 데이터 수 X 0.2%
  k <- minPts - 1 ## 각 데이터에서 k번째로 떨어진 거리를 이용하여 Eps 구함
  
  di <- tbl_df(as.matrix(dist(data)))
  kDi <- apply(di, 1, function(x){
    sort(as.numeric(x))[7] ## 거리 
    })
  q1q3 <- quantile(kDi, c(0.25, 0.75))
  eps <- as.numeric(q1q3[2] + diff(q1q3)) ## Q3 + IQR
  
  ## label 설정 
  di <- tbl_df(ifelse(di > eps, T, F))
  
  neighborCount <- apply(di, 1, function(x){
    nrow(data) - length(which(x))
  })
  
  label <- ifelse(neighborCount >= minPts, "core", NA)
  label[neighborCount < minPts & neighborCount == 1] <- "outlier"
  label[is.na(label)] <- "neighbor"
  
  ## Queue ####
  queue <- function()
  { 
    queue <- new.env()
    queue$vector <- vector()
    queue$size <- function() return( length(vector) )
    queue$pushHead <- function(value) vector <<- unique(c(value, vector))
    queue$pushTail <- function(value) vector <<- unique(c(vector, value))
    queue$popHead <- function() {
      value <- vector[1]
      vector <<- vector[-1]
      return(value)
    }
    queue$popTail <- function() {
      value <- vector[length(vector)]
      vector <<- vector[-length(vector)]
      return(value)
    }
    environment(queue$size)     <- as.environment(queue)
    environment(queue$pushHead) <- as.environment(queue)
    environment(queue$popHead)  <- as.environment(queue)
    environment(queue$pushTail) <- as.environment(queue)
    environment(queue$popTail)  <- as.environment(queue)
    class(queue) <- "queue"
    return(queue)
  }
  
  ## cluster 선정
  cluster <- rep(NA, nrow(data))
  coreSet <- which(label == "core")
  neighborSet <- which(label == "neighbor")
  outlierSet <- which(label == "outlier")
  
  count <- 0
  c <- 0
  tempQueue <- queue() 
  clusterQueue <- queue()
  
  while(length(coreSet) != 0){
    
    c <- c + 1
    tempQueue$pushTail(sample(coreSet, 1)) ## 임의의 core 데이터 추출
    
    while(tempQueue$size() != 0){
      
      count <- count + 1 
      point <- tempQueue$popHead() 
      tempQueue$pushTail(which(!di[[point]])) ## core point와 이웃인 데이터 tempQueue에 저장
      clusterQueue$pushTail(point) ## 다 탐색한 point는 clusterQueue에 저장 
      tempQueue$vector <- dplyr::setdiff(tempQueue$vector, clusterQueue$vector) ## 이미 탐색한 point는 tempQueue에 추가 안되게 
      
    }
    
    coreSet <- dplyr::setdiff(coreSet, clusterQueue$vector) 
    cluster[clusterQueue$vector] <- c
    clusterQueue <- queue()
    
  }
  
  cluster[outlierSet] <- 0
  
  return(list(cluster = cluster, outlier = outlierSet, count = count, eps = eps, minPts = minPts))
  
}

dbscanResult <- dbscan(data)
data$cluster <- dbscanResult$cluster

plot_ly(data, x = ~x, y = ~y, z = ~z, color = ~cluster)


