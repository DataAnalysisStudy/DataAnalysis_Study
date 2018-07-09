library(shiny)
library(devtools)
library(rCharts)

### Data 전처리
data(iris)
data(ruspini, package = "cluster")
data(Glass, package = "mlbench")

glass <- Glass
do_iris <- iris
do_ruspini <- ruspini
do_glass <- glass

colnames(iris) <- c("SepalLength", "SepalWidth", "PetalLength", "PetalWidth", "Species")
colnames(do_iris) <- c("SepalLength", "SepalWidth", "PetalLength", "PetalWidth", "Species")

Efac <- c("a", "b", "c", "d", "e", "f", "g", "h", "i", "j")

k=3


# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  analytics <- reactive({
    
    if(input$Cluster!=11){
      k <<- as.integer(input$Cluster)
    }
    if(input$Data == 'iris'){
      analytics <- do_iris
    }else if(input$Data == 'ruspini'){
      analytics <- do_ruspini
    }else if(input$Data == 'glass'){
      analytics <- do_glass
    }else{
      analytics <- do_random()
    }
     analytics
  })
  
  do_random <- reactive({
    
    input$Go==TRUE
      
      do_random1 <- data.frame(X = rnorm(100, 100,10), Y = rnorm(100, 100, 10))
      do_random2 <- data.frame(X = rnorm(100, 150,10), Y = rnorm(100, 150, 10))
      do_random3 <- data.frame(X = rnorm(100, 50,10), Y = rnorm(100, 50, 10))
      do_random4 <- data.frame(X = rnorm(200, runif(50) * 150), Y = rnorm(200, runif(50) * 150))
      
      do_random <- rbind(do_random1, do_random2, do_random3, do_random4)
      
    
    do_random
  })
  
  
  
  K_Data <- reactive({
    if(input$Data == 'iris'){
      
      do_iris <- analytics()
  
      K_F_iris <- kmeans(do_iris[,1:4], k,algorithm = "Forgy")
      K_M_iris <- kmeans(do_iris[,1:4], k,algorithm = "MacQueen")
      
      do_iris$F_Cluster <- as.integer(K_F_iris$cluster)
      do_iris$F_Cluster <- Efac[do_iris$F_Cluster]
      
      do_iris$M_Cluster <- as.integer(K_M_iris$cluster)
      do_iris$M_Cluster <- Efac[do_iris$M_Cluster]
      
      K_Data <- do_iris
      
    }else if(input$Data == 'ruspini'){
      
      do_ruspini <- analytics()
      
      K_F_ruspini <- kmeans(do_ruspini, k,algorithm = "Forgy")
      K_M_ruspini <- kmeans(do_ruspini, k,algorithm = "MacQueen")

      do_ruspini$F_Cluster <- as.integer(K_F_ruspini$cluster)
      do_ruspini$F_Cluster <- Efac[do_ruspini$F_Cluster]
      
      do_ruspini$M_Cluster <- as.integer(K_M_ruspini$cluster)
      do_ruspini$M_Cluster <- Efac[do_ruspini$M_Cluster]
      
      K_Data <- do_ruspini
      
    }else if(input$Data == 'glass'){
    
      do_glass <- analytics()
      
      K_F_glass <- kmeans(do_glass, k,algorithm = "Forgy")
      K_M_glass <- kmeans(do_glass, k,algorithm = "MacQueen")
 
      do_glass$F_Cluster <- as.integer(K_F_glass$cluster)
      do_glass$F_Cluster <- Efac[do_glass$F_Cluster]
      
      do_glass$M_Cluster <- as.integer(K_M_glass$cluster)
      do_glass$M_Cluster <- Efac[do_glass$M_Cluster]
      
      K_Data <- do_glass
      
    }else{
      
      do_random <- analytics()
      
      K_F_random <- kmeans(do_random, k, algorithm = "Forgy")
      K_M_random <- kmeans(do_random, k, algorithm = "MacQueen")
      
      do_random$F_Cluster <- as.integer(K_F_random$cluster)
      do_random$F_Cluster <- Efac[do_random$F_Cluster]
      
      do_random$M_Cluster <- as.integer(K_M_random$cluster)
      do_random$M_Cluster <- Efac[do_random$M_Cluster]
      
      K_Data <- do_random
      
    }
    
    K_Data
    
  })
  
  
  selectedData <- reactive({

    if(input$Data == 'iris'){
      
      selectedData <- K_Data()[, c(input$Iris_Y, input$Iris_X, "F_Cluster", "M_Cluster")]
      colnames(selectedData) <- c("Y", "X", "F_Cluster", "M_Cluster")
      
    }else if(input$Data == 'ruspini'){
      
      selectedData <- K_Data()[, c(input$Ruspini_Y, input$Ruspini_X, "F_Cluster", "M_Cluster")]
      colnames(selectedData) <- c("Y", "X", "F_Cluster", "M_Cluster")
      
    }else if(input$Data == 'glass'){
      
      selectedData <- K_Data()[, c(input$Glass_Y, input$Glass_X, "F_Cluster", "M_Cluster")]
      colnames(selectedData) <- c("Y", "X", "F_Cluster", "M_Cluster")
      
    }else{
      
      selectedData <- K_Data()[,c("Y", "X", "F_Cluster", "M_Cluster")]
      colnames(selectedData) <- c("Y", "X", "F_Cluster", "M_Cluster")
    }
     selectedData
  })
  
  
  ss <- reactive({
    
    if(input$Data == 'iris'){
      
      do_iris <- analytics()
      
      K_F_iris <- kmeans(do_iris[,1:4], k,algorithm = "Forgy")
      K_M_iris <- kmeans(do_iris[,1:4], k,algorithm = "MacQueen")
      ss <- data.frame(c(K_F_iris$withinss, K_M_iris$withinss), c(rep(c("Forgy", "MacQueen"), each = length(K_M_iris$withinss)))
                       ,c(Efac[1:length(K_M_iris$withinss)]))
      colnames(ss) <- c("SquareError", "Algorithm", "Cluster")
      
    }else if(input$Data == 'ruspini'){
      
      do_ruspini <- analytics()
      
      K_F_ruspini <- kmeans(do_ruspini, k,algorithm = "Forgy")
      K_M_ruspini <- kmeans(do_ruspini, k,algorithm = "MacQueen")
      ss <- data.frame(c(K_F_ruspini$withinss, K_M_ruspini$withinss), c(rep(c("Forgy","MacQueen"), each =length(K_M_ruspini$withinss)))
                       ,c(Efac[1:length(K_M_ruspini$withinss)]))
      colnames(ss) <- c("SquareError", "Algorithm", "Cluster")
   
      
    }else if(input$Data == 'glass'){
      
      do_glass <- analytics()
      
      K_F_glass <- kmeans(do_glass, k,algorithm = "Forgy")
      K_M_glass <- kmeans(do_glass, k,algorithm = "MacQueen")
      ss <- data.frame(c(K_F_glass$withinss, K_M_glass$withinss), c(rep(c("Forgy","MacQueen"), each =length(K_M_glass$withinss)))
                       ,c(Efac[1:length(K_M_glass$withinss)]))
      colnames(ss) <- c("SquareError", "Algorithm", "Cluster")
      
    }else{
      
      do_random <- analytics()
      
      K_F_random <- kmeans(do_random, k,algorithm = "Forgy")
      K_M_random <- kmeans(do_random, k,algorithm = "MacQueen")
      ss <- data.frame(c(K_F_random$withinss, K_M_random$withinss), c(rep(c("Forgy","MacQueen"), each =length(K_M_random$withinss)))
                       ,c(Efac[1:length(K_M_random$withinss)]))
      colnames(ss) <- c("SquareError", "Algorithm", "Cluster")
      
      
    }
    
    ss
    
  })
  
  

  output$pointGraph1 <- renderChart2({
    
    theGraph <- rPlot(Y ~ X, data = selectedData(), color = "F_Cluster", type = "point")
     
    return(theGraph)
    
  })
  
  output$pointGraph2 <- renderChart2({
    
    theGraph <- rPlot(Y ~ X, data = selectedData(), color = "M_Cluster", type = "point")
    
    return(theGraph)
    
  })
  
  
  output$barGraph <- renderChart2({
    
    theGraph <- nPlot(SquareError ~ Algorithm , group="Cluster", data = ss(), type = "multiBarChart")
    
    return(theGraph)
    
  })
  

  
 
})
