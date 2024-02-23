# Load required libraries
library(shiny)
library(ggtern)

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
    ggtern() +
      theme_rgbg() +  # Add theme (optional)
      labs(title = "Ternary Plot", x = "Variable 1", y = "Variable 2", z = "Variable 3")
  })
}

# Run the application
shinyApp(ui = ui, server = server)



















