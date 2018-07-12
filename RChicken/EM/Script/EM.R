rm(list = ls())
library(plotly)

####### ?곗씠????援ъ텞

x1 <- rnorm(50, 10, 2)
x2 <- rnorm(50, 20, 1.5)
x3 <- rnorm(50, 30, 2)
y1 <- rnorm(50, 20, 2)
y2 <- rnorm(50, 10, 2)
y3 <- rnorm(50, 30, 2)

x <- c(x1, x2)
y <- c(y1, y2)

x <- c(x1, x2, x3)
y <- c(y1, y2, y3)

data <- data.frame(x = x, y = y)

plot_ly(dat, x = ~x, y = ~y)


####### EM

dimension = 2

################# ?뺢퇋遺꾪룷 珥덇린 ?뚮씪誘명꽣 ?ㅼ젙
parameter <- data.frame()

#### mu??媛곴컖??李⑥썝???ш린 ?쒖쑝濡??뺣젹???ㅼ쓬, 李⑥썝 ?섎쭔??遺꾩쐞?섎줈 ?섎닎
mu <- apply(data, 2, function(x){
  quantile(x, seq(0, 1, length.out = 2 + dimension))
  
}
)
mu <- mu[-c(1, nrow(mu)), ]

#### sigma??媛곴컖??李⑥썝??0.841遺꾩쐞?쒖뿉??0.5遺꾩쐞??1sigma)瑜?類 媛?
sigma <- apply(data, 2, function(x){
  diff(quantile(x, c(0.5, 0.841)))
}
)

#### 媛곴컖??李⑥썝??異붿텧???뺣쪧? 洹좊벑遺꾪룷濡??ㅼ젙
tou <- rep(1/dimension, dimension)

#### ?뚮씪誘명꽣 ?곗씠???꾨젅???앹꽦 

parameter <- data.frame()
parameter <- rbind(parameter, mu)
parameter <- cbind(parameter, sigma)
parameter <- cbind(parameter, tou)


################# Expectation Step

#### 珥덇린 ?뚮씪誘명꽣 ?ㅼ젙?쒕?濡??곗씠??class 吏??
for(i in 1:dimension){
  
  if(i == 1){
    
    covTemp <- cov(data)
    covInv <- solve(covTemp)
    
    fx <- data.frame(apply(data, 1, function(x){
      x_mu <- as.numeric(x - parameter[i, 1:dimension])
      exp(-1/2 * t(x_mu) %*% covInv %*% x_mu) / sqrt((2 * pi)^dimension * det(covTemp)) ## i ?뺢퇋遺꾪룷???랁븷 ?뺣쪧
    }))
    
  }else{
    
    fx <- cbind(fx, apply(data, 1, function(x){
      x_mu <- as.numeric(x - parameter[i, 1:dimension])
      exp(-1/2 * t(x_mu) %*% covInv %*% x_mu) / sqrt((2 * pi)^dimension * det(covTemp)) ## i ?뺢퇋遺꾪룷???랁븷 ?뺣쪧
    }))
    
  }
  
  if(i == dimension){
    
    rm(covTemp)
    rm(covInv)
    rm(i)
    colnames(fx) <- colnames(mu)
    
  }
  
}

data$class <- as.factor(apply(fx, 1, which.max))

plot_ly(data, x = ~x, y = ~y, color = ~class)
parameter
fx

log(parameter$pi[i]) - 
  1/2 * log(abs(det(covTemp))) - 
  1/2 * x_mu %*% covInv %*% t(x_mu)

e <- x_mu %*% covInv
e <- e[1:10, ]

e


x         y
[1,] 20.900849 22.269930
[2,] 21.319102 22.223864
[3,] 17.937159 18.258445
[4,] 15.257954 20.421463

21.319102-10.97643
22.223864-10.78619
x        y
10.97643 10.78619

x  9.92442 10.34267 6.960729 4.281525 8.374418 7.134973  7.491791 7.116012 8.227562  8.401136 10.615756 10.996427
y 11.48374 11.43768 7.472257 9.635275 9.352603 5.888514 10.835

library(mvnfast)
dnorm()
?dnorm



