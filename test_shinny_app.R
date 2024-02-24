# Load required libraries
library(shiny)
library(ggtern)
library(dplyr)

###################################### Draw polygons

g <- data.frame(y=c(1,0,0),
                x=c(0,1,.4),
                z=c(0,0,.6),         Series="Green")

p <- data.frame(y=c(1,0.475,0.6),
                x=c(0,0.210,0),
                z=c(0,0.315,.4),         Series="Red")

q <- data.frame(y=c(0.575,0.475,0.0,0.0),
                x=c(0.040,0.210,0.4,0.1),
                z=c(0.385,0.315,0.6,0.9),         Series="Yellow")

f <- data.frame(y=c(0.6,0.575,0.0,0.0),
                x=c(0.0,0.040,0.1,0.0),
                z=c(0.4,0.385,0.9,1.0),         Series="Blue")

DATA = rbind(g, p, q, f)

###################################### Dummy data for points

dummy <- data.frame(label = "A",
                    colour = "green",
                    clay = 50,
                    sand = 30,
                    silt = 20)

###################################### Shinny app

# Define UI
ui <- fluidPage(
  titlePanel("Ternary Plot in Shiny"),
  mainPanel(
    # Output: Ternary Plot
    plotOutput("ternaryPlot")
  )
)

# Define server logic
server <- function(input, output) {
  output$ternaryPlot <- renderPlot({
    # Create ternary plot
    print( 
      
      dummy %>%
        ggtern(aes(  #<<
          x = sand,  #<<
          y = clay,  #<<
          z = silt,
          color = colour
        ))   #<<
      
      
      ) 
    
  })
}

# Run the application
shinyApp(ui = ui, server = server)



















