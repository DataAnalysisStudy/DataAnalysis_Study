rm(list = ls())
library(plotly)
library(plyr)
library(mvtnorm)

####### 데이터 셋 구축

x1 <- rnorm(50, 10, 1)
x2 <- rnorm(50, 20, 1)
x3 <- rnorm(50, 30, 1)
y1 <- rnorm(50, 20, 1)
y2 <- rnorm(50, 10, 1)
y3 <- rnorm(50, 30, 1)

x <- c(x1, x2)
y <- c(y1, y2)
# 
# x <- c(x1, x2, x3)
# y <- c(y1, y2, y3)

data <- data.frame(x = x, y = y)

rm(x1, x2, x3, y1, y2, y3, x, y)

# plot_ly(data, x = ~x, y = ~y)

####### 원 중심과 sigma 1, 2 등고선 그리기 

graph <- function(dimension){
  

  ## 타원 만들기 
  lamb <- lapply(covTemp, function(mat) eigen(mat)$value )
  e <- lapply(covTemp, function(mat) eigen(mat)$vector )
  
  elliDat <- data.frame()
  elliDat2 <- data.frame()
  
  for(i in 1:dimension){
    
    elliTheta <- seq(-pi, pi, length = 1000)
    x1 <- sqrt(lamb[[i]][1]) * cos(elliTheta)
    y1 <- sqrt(lamb[[i]][2]) * sin(elliTheta)
    x2 <- as.vector(e[[i]][1, ] %*% t(cbind(x1, y1)) + mean(parameter[i, 1]))
    y2 <- as.vector(e[[i]][2, ] %*% t(cbind(x1, y1)) + mean(parameter[i, 2]))
    elliDat <- rbind(elliDat, data.frame(x2, y2, "class" = i))
    
    x1 <- 2 * sqrt(lamb[[i]][1]) * cos(elliTheta)
    y1 <- 2 * sqrt(lamb[[i]][2]) * sin(elliTheta)
    x2 <- as.vector(e[[i]][1, ] %*% t(cbind(x1, y1)) + mean(parameter[i, 1]))
    y2 <- as.vector(e[[i]][2, ] %*% t(cbind(x1, y1)) + mean(parameter[i, 2]))
    elliDat2 <- rbind(elliDat2, data.frame(x2, y2, "class" = i))
    
  }
  
  plot_ly(data, x = ~x, y = ~y, color = ~as.factor(class), type = "scatter") %>%
    add_trace(x = ~x2, y = ~y2, data = elliDat[elliDat$class == 1, ], type = "area") %>%
    add_trace(x = ~x2, y = ~y2, data = elliDat[elliDat$class == 2, ], type = "area") %>%
    add_trace(x = ~x2, y = ~y2, data = elliDat2[elliDat2$class == 1, ], type = "area") %>%
    add_trace(x = ~x2, y = ~y2, data = elliDat2[elliDat2$class == 2, ], type = "area")
  
}
# 
# graph <- function(data, dimension, parameter, cov){
#   
#   covTemp <- cov
#   ## 타원 만들기 
#   lamb <- lapply(covTemp, function(mat) eigen(mat)$value )
#   e <- lapply(covTemp, function(mat) eigen(mat)$vector )
#   
#   elliDat <- data.frame()
#   elliDat2 <- data.frame()
#   
#   for(i in 1:dimension){
#     
#     elliTheta <- seq(-pi, pi, length = 1000)
#     x1 <- sqrt(lamb[[i]][1]) * cos(elliTheta)
#     y1 <- sqrt(lamb[[i]][2]) * sin(elliTheta)
#     x2 <- as.vector(e[[i]][1, ] %*% t(cbind(x1, y1)) + mean(parameter[i, 1]))
#     y2 <- as.vector(e[[i]][2, ] %*% t(cbind(x1, y1)) + mean(parameter[i, 2]))
#     elliDat <- rbind(elliDat, data.frame(x2, y2, "class" = i))
#     
#     x1 <- 2 * sqrt(lamb[[i]][1]) * cos(elliTheta)
#     y1 <- 2 * sqrt(lamb[[i]][2]) * sin(elliTheta)
#     x2 <- as.vector(e[[i]][1, ] %*% t(cbind(x1, y1)) + mean(parameter[i, 1]))
#     y2 <- as.vector(e[[i]][2, ] %*% t(cbind(x1, y1)) + mean(parameter[i, 2]))
#     elliDat2 <- rbind(elliDat2, data.frame(x2, y2, "class" = i))
#     
#   }
#   
#   plot_ly(data, x = ~x, y = ~y, color = ~as.factor(class), type = "scatter") %>%
#     add_trace(x = ~x2, y = ~y2, data = elliDat[elliDat$class == 1, ], type = "area") %>%
#     add_trace(x = ~x2, y = ~y2, data = elliDat[elliDat$class == 2, ], type = "area") %>%
#     add_trace(x = ~x2, y = ~y2, data = elliDat2[elliDat2$class == 1, ], type = "area") %>%
#     add_trace(x = ~x2, y = ~y2, data = elliDat2[elliDat2$class == 2, ], type = "area")
#   
# }
# 
# graph <- function(dimension){
#   if(dimension == 2){
#     plot_ly(data, x = ~x, y = ~y, color = ~class, type = "scatter") %>%
#       add_trace(x = ~x, y = ~y, color = ~class, data = parameter, type = "scatter") %>%
#       layout(shapes = list(
#         list(xref = 'x', yref = 'y', 
#              x0 = parameter$x[1] - parameter$sigma[1], 
#              x1 = parameter$x[1] + parameter$sigma[1], 
#              y0 = parameter$y[1] - parameter$sigma[1],
#              y1 = parameter$y[1] + parameter$sigma[1], 
#              type = "circle", opacity = 0.2,
#              fillcolor = 'rgb(50, 20, 90)', line = list(color = 'rgb(50, 20, 90)')), 
#         list(xref = 'x', yref = 'y', 
#              x0 = parameter$x[2] - parameter$sigma[2], 
#              x1 = parameter$x[2] + parameter$sigma[2], 
#              y0 = parameter$y[2] - parameter$sigma[2],
#              y1 = parameter$y[2] + parameter$sigma[2], 
#              type = "circle", opacity = 0.2,
#              fillcolor = 'rgb(90, 200, 75)', line = list(color = 'rgb(90, 200, 75)'))
#       )
#       )
#   }else if(dimension == 3){
#     plot_ly(data, x = ~x, y = ~y, color = ~class, type = "scatter") %>%
#       add_trace(x = ~x, y = ~y, color = ~class, data = parameter, type = "scatter") %>%
#       layout(shapes = list(
#         list(xref = 'x', yref = 'y', 
#              x0 = parameter$x[1] - parameter$sigma[1], 
#              x1 = parameter$x[1] + parameter$sigma[1], 
#              y0 = parameter$y[1] - parameter$sigma[1],
#              y1 = parameter$y[1] + parameter$sigma[1], 
#              type = "circle", opacity = 0.2,
#              fillcolor = 'rgb(50, 20, 90)', line = list(color = 'rgb(50, 20, 90)')), 
#         list(xref = 'x', yref = 'y', 
#              x0 = parameter$x[2] - parameter$sigma[2], 
#              x1 = parameter$x[2] + parameter$sigma[2], 
#              y0 = parameter$y[2] - parameter$sigma[2],
#              y1 = parameter$y[2] + parameter$sigma[2], 
#              type = "circle", opacity = 0.2,
#              fillcolor = 'rgb(90, 200, 75)', line = list(color = 'rgb(90, 200, 75)')),
#         list(xref = 'x', yref = 'y', 
#              x0 = parameter$x[3] - parameter$sigma[3], 
#              x1 = parameter$x[3] + parameter$sigma[3], 
#              y0 = parameter$y[3] - parameter$sigma[3],
#              y1 = parameter$y[3] + parameter$sigma[3], 
#              type = "circle", opacity = 0.2,
#              fillcolor = 'rgb(140, 130, 20)', line = list(color = 'rgb(140, 130, 20)'))
#       )
#       )
#   }
#   
# }



####### EM

dimension = 2

################# EM 알고리즘 

EM <- function(data, dimension = dimension, elipsions = 0.001){
  
  ######################################## 초기값 설정 ####################################
  
  ################# 정규분포 초기 파라미터 설정
  parameter <- data.frame()
  
  #### mu는 각각의 차원을 크기 순으로 정렬한 다음, 차원 수만큼 분위수로 나눔
  mu <- apply(data, 2, function(x){
    quantile(x, seq(0, 1, length.out = 2 + dimension))
    
  }
  )
  mu <- mu[-c(1, nrow(mu)), ]
  
  #### sigma는 각각의 차원의 0.841분위서에서 0.5분위수(1sigma)를 뺀 값 
  
  sigma <- apply(data, 2, function(x){
    diff(quantile(x, c(0.5, 0.841)))
  }
  )
  sigma <- rep(mean(sigma), dimension)
  
  #### 각각의 차원에 추출될 확률은 균등분포로 설정
  tou <- rep(1/dimension, dimension)
  
  #### 파라미터 데이터 프레임 생성 
  
  parameter <- data.frame()
  parameter <- rbind(parameter, mu)
  parameter <- cbind(parameter, sigma)
  parameter <- cbind(parameter, tou)
  parameter <- cbind(parameter, class = paste("center", factor(1:dimension), sep = "_"))
  rownames(parameter) <- 1:dimension
  
  rm(mu, sigma, tou)
  
  #### 초기 공분산 생성 (차원에 맞게 단위행렬 생성) 
  
  covTemp <- apply(parameter, 1, function(x){
    
    data.frame(cov(mapply(rnorm,
                          rep(100, dimension),
                          mean = as.numeric(x[1:dimension]),
                          sd = as.numeric(rep(x[dimension + 1], dimension)))))
    
  })
  
  covTemp <- lapply(covTemp, as.matrix)
  
  
  ######################################## E Step ####################################
  
  count <- 0
  theta <- c()
  elipsions = 0.0001
  elipsionsTemp <- elipsions 
  
  #### likelihood 최대화 파라미터 구하기 
  fxCal <- function(data, covTemp){
    
    count <<- count + 1 
    
    for(i in 1:dimension){
      
      #### 초기 파라미터 설정한대로 데이터 class 지정 
      
      fxTemp <- apply(data[, 1:dimension], 1, function(rowData){
        
        dmvnorm(as.numeric(rowData), 
                mean = as.numeric(parameter[i, 1:dimension]), 
                sigma = covTemp[[i]])
        
      })
      
      if(i == 1){
        fx <- data.frame(fxTemp)
      }else{
        fx <- cbind(fx, fxTemp)
      }
      
      if(i == dimension){
        
        colnames(fx) <- paste0("c", 1:dimension)
        
        tou <- data.frame(t(apply(t(t(fx) * parameter$tou), 1, function(rowData){
          rowData/sum(rowData)
        })))
        
      }
    }
    
    return(list(fx = fx, tou = tou))
    
  }
  
  ############# Max Step
  while(elipsionsTemp >= elipsions){
    expectation <- fxCal(data, covTemp)
    data$class <- as.factor(apply(expectation$fx, 1, which.max)) ## likelihood가 가장 높은 클러스터 배정
    theta <- c(theta, sum(parameter$tou %*% t(expectation$fx)))
    elipsionsTemp <- ifelse(count == 1, 99999, theta[count] - theta[count - 1])
    # graph(data = data[, 1:dimension], dimension = 2, parameter = parameter, cov = covTemp)
    graph(dimension = 2)
    
    ############# Max Step의 변수 변환 부분
    parameter[, "tou"] <- apply(expectation$tou, 2, mean) ## tou
    parameter[, 1:dimension] <- t(apply(expectation$tou, 2, function(clusterTou){
      
      apply(clusterTou * data[, 1:dimension], 2, function(x){
        sum(x)/sum(clusterTou)
      })
      
    })) ## mu
    
    covTemp <- list()
    
    for(j in 1:dimension){
      
      dataTemp <- data[, 1:dimension] - 
        matrix(unlist(rep(parameter[j, 1:dimension], nrow(data))), ncol = 2, byrow = T)
      
      covTemp[[j]] <- t(expectation$tou[, j] * dataTemp) %*% as.matrix(dataTemp)/sum(expectation$tou[, j])
      
    }
    # parameter[, "sigma"] <- unlist(lapply(covTemp, function(x){
    #   mean(x * diag(1, dimension))
    # }))
    
    rm(j)
  }
  
  return(list(cluster = data$class, count = count, 
              parameter = parameter, expectation = expectation,
              theta = theta, sigma = covTemp))
  
}

result <- EM(data = data, dimension = 2, elipsions = 0.00000001)

result$theta
data$class <- result$cluster
graph(data = cbind(data, "class" = result$cluster), dimension = 2, parameter = result$parameter, cov = result$sigma) ## 그래프로 확인
