rm(list = ls())
library(plotly)
library(plyr)

####### 데이터 셋 구축

x1 <- rnorm(50, 10, 2)
x2 <- rnorm(50, 20, 1.5)
x3 <- rnorm(50, 30, 2)
y1 <- rnorm(50, 20, 2)
y2 <- rnorm(50, 10, 2)
y3 <- rnorm(50, 30, 2)

x <- c(x1, x2)
y <- c(y1, y2)
# 
# x <- c(x1, x2, x3)
# y <- c(y1, y2, y3)

data <- data.frame(x = x, y = y)



####### 원 중심과 sigma 1, 2 등고선 그리기 

graph <- function(dimension){
  if(dimension == 2){
    plot_ly(data, x = ~x, y = ~y, color = ~class, type = "scatter") %>%
      add_trace(x = ~x, y = ~y, color = ~class, data = parameter, type = "scatter") %>%
      layout(shapes = list(
        list(xref = 'x', yref = 'y', 
             x0 = parameter$x[1] - parameter$sigma[1], 
             x1 = parameter$x[1] + parameter$sigma[1], 
             y0 = parameter$y[1] - parameter$sigma[1],
             y1 = parameter$y[1] + parameter$sigma[1], 
             type = "circle", opacity = 0.2,
             fillcolor = 'rgb(50, 20, 90)', line = list(color = 'rgb(50, 20, 90)')), 
        list(xref = 'x', yref = 'y', 
             x0 = parameter$x[2] - parameter$sigma[2], 
             x1 = parameter$x[2] + parameter$sigma[2], 
             y0 = parameter$y[2] - parameter$sigma[2],
             y1 = parameter$y[2] + parameter$sigma[2], 
             type = "circle", opacity = 0.2,
             fillcolor = 'rgb(90, 200, 75)', line = list(color = 'rgb(90, 200, 75)'))
      )
      )
  }else if(dimension == 3){
    plot_ly(data, x = ~x, y = ~y, color = ~class, type = "scatter") %>%
      add_trace(x = ~x, y = ~y, color = ~class, data = parameter, type = "scatter") %>%
      layout(shapes = list(
        list(xref = 'x', yref = 'y', 
             x0 = parameter$x[1] - parameter$sigma[1], 
             x1 = parameter$x[1] + parameter$sigma[1], 
             y0 = parameter$y[1] - parameter$sigma[1],
             y1 = parameter$y[1] + parameter$sigma[1], 
             type = "circle", opacity = 0.2,
             fillcolor = 'rgb(50, 20, 90)', line = list(color = 'rgb(50, 20, 90)')), 
        list(xref = 'x', yref = 'y', 
             x0 = parameter$x[2] - parameter$sigma[2], 
             x1 = parameter$x[2] + parameter$sigma[2], 
             y0 = parameter$y[2] - parameter$sigma[2],
             y1 = parameter$y[2] + parameter$sigma[2], 
             type = "circle", opacity = 0.2,
             fillcolor = 'rgb(90, 200, 75)', line = list(color = 'rgb(90, 200, 75)')),
        list(xref = 'x', yref = 'y', 
             x0 = parameter$x[3] - parameter$sigma[3], 
             x1 = parameter$x[3] + parameter$sigma[3], 
             y0 = parameter$y[3] - parameter$sigma[3],
             y1 = parameter$y[3] + parameter$sigma[3], 
             type = "circle", opacity = 0.2,
             fillcolor = 'rgb(140, 130, 20)', line = list(color = 'rgb(140, 130, 20)'))
      )
      )
  }
 
}



####### EM

dimension = 2

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

#### 각각의 차원에 추출될 확률은 균등분포로 설정
tou <- rep(1/dimension, dimension)

#### 파라미터 데이터 프레임 생성 

parameter <- data.frame()
parameter <- rbind(parameter, mu)
parameter <- cbind(parameter, sigma)
parameter <- cbind(parameter, tou)
parameter <- cbind(parameter, class = paste("center", factor(1:dimension), sep = "_"))
rownames(parameter) <- 1:dimension

################# EM 알고리즘 

EM <- function(data, dimension = dimension){
  
  ############# Expectation Step
  count <- 0
  theta <- c()

  #### likelihood 최대화 파라미터 구하기 
  fxCal <- function(data){
   
    count <<- count + 1 

    ## 첫 시작이면 공통 sigma, 두번째부터 class 별로 나누어서 sigma 넣기 
    if(count == 1){
      
      covTemp <- rep(list(cov(data)), dimension)
      covInv <- lapply(covTemp, solve)
      
    }else{
      
      ############# Max Step의 변수 변환 부분 
      parameter$tou <<- apply(expectation$tou, 2, sum)/sum(expectation$tou) ## tou 변경
      parameter[, 1:dimension] <<- aggregate(. ~ class, data = data, mean)[, -1] ## mu 변경
      
      dataTemp <- data
      covTemp <- list()
      for(j in 1:dimension){
        
        index <- dataTemp$class == j
        x_mu <- as.matrix(dataTemp[index, 1:dimension] - as.matrix(parameter[j, 1:dimension]))
        covTemp[[j]] <- t(as.matrix(expectation$tou[index, ]) * x_mu) %*% x_mu / sum(expectation$tou[index, ])
        
      }

      covInv <- lapply(covTemp, solve)
      
      parameter[, "sigma"] <<- unlist(lapply(covTemp, function(x){
        mean(x * diag(1, dimension))
      }))
      
      rm(j)
      
    }

    for(i in 1:dimension){
      
      #### 초기 파라미터 설정한대로 데이터 class 지정 
      if(i == 1){ 
        
        fx <- data.frame(apply(data[, 1:dimension], 1, function(rowData){
          x_mu <- as.numeric(rowData - parameter[i, 1:dimension])
          exp(-1/2 * t(x_mu) %*% covInv[[i]] %*% x_mu) / sqrt((2 * pi)^dimension * det(covTemp[[i]])) ## i 정규분포에 속할 확률
        }))
        
      }else{
        
        fx <- cbind(fx, apply(data[, 1:dimension], 1, function(rowData){
          x_mu <- as.numeric(rowData - parameter[i, 1:dimension])
          exp(-1/2 * t(x_mu) %*% covInv[[i]] %*% x_mu) / sqrt((2 * pi)^dimension * det(covTemp[[i]])) ## i 정규분포에 속할 확률
        }))
        
      }
      
      if(i == dimension){
       
        colnames(fx) <- colnames(mu)
        
        tou <- data.frame(t(apply(t(t(fx) * parameter$tou), 1, function(rowData){
          rowData/sum(rowData)
          })))
        
        }
    }
    
    return(list(fx = fx, tou = tou))
    
  }

  ############# Max Step
  expectation <- fxCal(data)
  data$class <- as.factor(apply(expectation$fx, 1, which.max)) ## likelihood가 가장 높은 클러스터 배정
  theta <- c(theta, sum(expectation$tou * expectation$fx))
  graph(dimension)
  parameter
  
}

cbind(head(expectation$tou), head(expectation$fx), head(expectation$tou * expectation$fx))



graph() ## 그래프로 확인


