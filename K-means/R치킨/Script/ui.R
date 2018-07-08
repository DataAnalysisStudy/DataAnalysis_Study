library(shiny)
library(rCharts)


# Define UI for application that draws a histogram
shinyUI(pageWithSidebar( 
    
    headerPanel("K-Means"), 
    
    sidebarPanel(selectInput(inputId = "Data", label = "Data",
                             choices = list("Iris" = "iris",
                                            "Ruspini" = "ruspini",
                                            "Glass" = "glass",
                                            "Random" = "random"),
                             selected = "iris"), 
                 br(),
                 selectInput(inputId = "Iris_X", label = "Iris_X",
                             choices = list("SepalLength" = "SepalLength", "SepalWidth" = "SepalWidth",
                                            "PetalLength" = "PetalLength", "PetalWidth" = "PetalWidth",
                                            "Species" = "Species", "F_Cluster" = "F_Cluster",
                                            "M_Cluster" = "M_Cluster")),
                 
                 selectInput(inputId = "Iris_Y", label = "Iris_Y",
                             choices = list("SepalLength" = "SepalLength", "SepalWidth" = "SepalWidth",
                                            "PetalLength" = "PetalLength", "PetalWidth" = "PetalWidth",
                                            "Species" = "Species", "F_Cluster" = "F_Cluster",
                                            "M_Cluster" = "M_Cluster"),
                             selected = "SepalWidth"),
                 br(),
                 selectInput(inputId = "Ruspini_X", label = "Ruspini_X",
                             choices = list("x" = "x", "y" = "y", "F_Cluster" = "F_Cluster",
                                            "M_Cluster" = "M_Cluster")),
                 
                 selectInput(inputId = "Ruspini_Y", label = "Ruspini_Y",
                             choices = list("x" = "x", "y" = "y", "F_Cluster" = "F_Cluster",
                                            "M_Cluster" = "M_Cluster"),
                             selected = "Y"),
                 br(),
                 selectInput(inputId = "Glass_X", label = "Glass_X",
                             choices = list("RI" = "RI", "Na" = "Na", "Mg" = "Mg", "Al" = "Al",
                                            "Si" = "Si", "K" = "K",
                                            "Ca" = "Ca", "Ba" = "Ba", "Fe" = "Fe", 
                                            "F_Cluster" = "F_Cluster", "M_Cluster" = "M_Cluster")),
                 
                 selectInput(inputId = "Glass_Y", label = "Glass_Y",
                             choices = list("RI" = "RI", "Na" = "Na", "Mg" = "Mg", "Al" = "Al",
                                            "Si" = "Si", "K" = "K",
                                            "Ca" = "Ca", "Ba" = "Ba", "Fe" = "Fe", 
                                            "F_Cluster" = "F_Cluster",
                                            "M_Cluster" = "M_Cluster"),
                             selected = "Na"),
                 
                 sliderInput(inputId = "Cluster", label = "Cluster",
                             min = 1, max = 10, value = 3, step = 1),
                 br(),
                 actionButton("Go", "Change")
    ),
    
    # Show a plot of the generated distribution

    mainPanel(
      h4("Forgy"),
      showOutput("pointGraph1","polycharts"),
      h4("MacQueen"),
      showOutput("pointGraph2","polycharts"),
      h4("Square Error"),
      showOutput("barGraph", "nvd3")
      
    )
    
  )
)
