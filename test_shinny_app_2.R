############################################ Packages

# Required Libraries
library(shiny)
library(ggplot2)
library(ggtern)

############################################ Base data

nz_data <- data.frame (Clay=c(1,0.6,0.6,
                              0.6,0.6,0.35,0.35,
                              0.6,0.6,0.35,0.35,
                              0.35,0.35,0.18,0.18,
                              0.35,0.35,0.18,0.18,
                              0.35,0.35,0.18,0.18,
                              0.18,0.18,0.08,0.08,
                              0.08,0.08,0,0,
                              0.08,0.08,0,0,
                              0.18,0.18,0,0,
                              0,0.18,0),
                       
                       Sand=c(0,0.40,0,
                              0.1,0.4,0.65,0.35,
                              0,0.1,0.35,0,
                              0.50,0.65,0.82,0.67,
                              0.25,0.50,0.67,0.42,
                              0,0.25,0.42,0,
                              0.42,0.82,0.92,0.52,
                              0.80,0.92,1,0.80,
                              0.52,0.8,0.8,0.6,
                              0,0.42,0.60,0.18,
                              0,0,0.18),
                       
                       Silt=c(0,0,0.40,
                              0.3,0,0,0.30,
                              0.4,0.3,0.3,0.65,
                              0.15,0,0,0.15,
                              0.40,0.15,0.15,0.40,
                              0.65,0.40,0.40,0.82,
                              0.40,0,0,0.40,
                              0.12,0,0,0.20,
                              0.4,0.12,0.20,0.4,
                              0.82,0.4,0.4,0.82,
                              1,0.82,0.82),
                       
                       Label=c("Clay","Clay","Clay",
                               "Loamy Clay","Loamy Clay","Loamy Clay","Loamy Clay",
                               "Silt Clay","Silt Clay","Silt Clay","Silt Clay",
                               "Sandy Clay Loam","Sandy Clay Loam","Sandy Clay Loam","Sandy Clay Loam",
                               "Clay Loam","Clay Loam","Clay Loam","Clay Loam",
                               "Silt Loam","Silt Loam","Silt Loam","Silt Loam",
                               "Sandy Loam","Sandy Loam","Sandy Loam","Sandy Loam",
                               "Sand","Sand","Sand","Sand",
                               "Loamy Sand","Loamy Sand","Loamy Sand","Loamy Sand",
                               "Loamy Silt","Loamy Silt","Loamy Silt","Loamy Silt",
                               "Silt","Silt","Silt")
)

data_text <- nz_data  %>% group_by(Label) %>%
  summarise_if(is.numeric, mean, na.rm = TRUE)

############################################ Shinny app

# Define UI
ui <- fluidPage(
  tags$head(
    tags$style(HTML("#ternaryPlot { margin: 0px; }"))  # Adjust margin here
  ),
  titlePanel("Ternary Plot in Shiny"),
  sidebarLayout(
    sidebarPanel(
      style = "width: 220px;",  # Adjust the width here
      # Manual data entry section
      textInput("sampleName", "Sample Name"),
      numericInput("sandValue", "Sand", value = 50, min = 0, max = 100),
      numericInput("siltValue", "Silt", value = 25, min = 0, max = 100),
      numericInput("clayValue", "Clay", value = 25, min = 0, max = 100),
      actionButton("addManualDataBtn", "Add Data"),
      
      # Upload CSV section
      fileInput("fileUpload", "Upload CSV file", accept = ".csv"),
      
      # Buttons to clear data and download
      actionButton("clearDataBtn", "Clear Data"),
      downloadButton("downloadDataBtn", "Download Data")
    ),
    mainPanel(
      # Output: Ternary Plot
      plotOutput("ternaryPlot", height = "750px", width = "100%")  # Adjust height and width here
    )
  )
)


# Define server logic
server <- function(input, output) {
  
  # Initialize empty dataframe
  soil_data <- reactiveVal(data.frame(
    soil = character(),
    sand = numeric(),
    silt = numeric(),
    clay = numeric()
  ))
  
  # Update data with manual input
  observeEvent(input$addManualDataBtn, {
    newSample <- data.frame(
      soil = input$sampleName,
      sand = input$sandValue,
      silt = input$siltValue,
      clay = input$clayValue
    )
    current_data <- soil_data()
    new_data <- rbind(current_data, newSample)
    soil_data(new_data)
  })
  
  # Clear data
  observeEvent(input$clearDataBtn, {
    soil_data(data.frame(
      soil = character(),
      sand = numeric(),
      silt = numeric(),
      clay = numeric()
    ))
  })
  
  # Download data as CSV
  output$downloadDataBtn <- downloadHandler(
    filename = function() {
      paste("soil_data", ".csv", sep = "")
    },
    content = function(file) {
      write.csv(soil_data(), file, row.names = FALSE)
    }
  )
  
  # Upload data from CSV
  observeEvent(input$fileUpload, {
    inFile <- input$fileUpload
    if (!is.null(inFile)) {
      data <- read.csv(inFile$datapath)
      soil_data(data)
    }
  })
  
  # Render Plot
  output$ternaryPlot <- renderPlot({
    # Create ternary plot
    p <- ggplot(data = nz_data, aes(
      y = Clay,
      x = Sand,
      z = Silt
    )) +
      coord_tern(L = "x", T = "y", R = "z") +
      geom_polygon(
        aes(fill = Label),
        alpha = 0.4,
        size = 0.1, 
        color = "black" 
      ) +
      geom_text(data = data_text, 
                aes(label = Label), 
                color = 'black',
                size = 4)   +
      geom_point(
        data = soil_data(),
        aes(x = sand,
            y = clay, 
            z = silt
        ), size=5 
      ) +
      theme_showarrows() +
      theme_arrowcustomlength(.35, .65) +
      theme_anticlockwise() +
      scale_T_continuous(breaks = c(0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1))+
      scale_L_continuous(breaks = c(0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1))+
      scale_R_continuous(breaks = c(0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1)) +
      theme_mesh(n = 10)+
      theme(legend.position = "none") 
    
    print(p)
  })
}

# Run the application
shinyApp(ui = ui, server = server)
