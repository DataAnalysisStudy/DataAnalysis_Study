rm(list = ls())
library(plotly)

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

graph <- function(){
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


################# Expectation Step

#### 초기 파라미터 설정한대로 데이터 class 지정 
for(i in 1:dimension){
  
  if(i == 1){
    
    covTemp <- cov(data)
    covInv <- solve(covTemp)
    
    fx <- data.frame(apply(data, 1, function(x){
      x_mu <- as.numeric(x - parameter[i, 1:dimension])
      exp(-1/2 * t(x_mu) %*% covInv %*% x_mu) / sqrt((2 * pi)^dimension * det(covTemp)) ## i 정규분포에 속할 확률
    }))
    
  }else{
    
    fx <- cbind(fx, apply(data, 1, function(x){
      x_mu <- as.numeric(x - parameter[i, 1:dimension])
      exp(-1/2 * t(x_mu) %*% covInv %*% x_mu) / sqrt((2 * pi)^dimension * det(covTemp)) ## i 정규분포에 속할 확률
    }))
    
  }
  
  if(i == dimension){
    
    rm(covTemp)
    rm(covInv)
    rm(i)
    colnames(fx) <- colnames(mu)
    
  }
  
}

data$class <- as.factor(apply(fx, 1, which.max)) ## 초기값을 이용하여 likelihood가 가장 높은 클러스터에 배정

graph() ## 그래프로 확인



  
