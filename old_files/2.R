# Required Libraries
library(shiny)
library(ggplot2)
library(ggtern)
library(dplyr)

# Base data
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
                               "Sandy \n Clay \n Loam","Sandy \n Clay \n Loam","Sandy \n Clay \n Loam","Sandy \n Clay \n Loam",
                               "Clay Loam","Clay Loam","Clay Loam","Clay Loam",
                               "Silt Loam","Silt Loam","Silt Loam","Silt Loam",
                               "Sandy Loam","Sandy Loam","Sandy Loam","Sandy Loam",
                               "Sand","Sand","Sand","Sand",
                               "Loamy Sand","Loamy Sand","Loamy Sand","Loamy Sand",
                               "Loamy Silt","Loamy Silt","Loamy Silt","Loamy Silt",
                               "Silt","Silt","Silt")
)

data_text_nz <- nz_data  %>% group_by(Label) %>%
  summarise_if(is.numeric, mean, na.rm = TRUE)

# Base data
usda_data <- data.frame (Clay=c(1,0.55,0.4,0.4,0.6,
                                0.55,0.35,0.35,
                                0.35,0.2,0.2,0.275,0.35,
                                0.2,0.15,0,0,0.05,0.05,0.2,
                                0.15,0.1,0,0,
                                0.1,0,0,
                                0.4,0.275,0.275,0.4,
                                0.275,0.2,0.05,0.05,0.275,
                                0.275,0,0,0.125,0.125,0.275,
                                0.6,0.4,0.4,
                                0.4,0.275,0.275,0.4,
                                0.125,0,0,0.125),
                         
                         Sand=c(0,0.45,0.45,0.2,0,
                                0.45,0.65,0.45,
                                0.65,0.8,0.525,0.45,0.45,
                                0.8,0.85,0.7,0.5,0.45,0.525,0.525,
                                0.85,0.9,0.85,0.7,
                                0.9,1,0.85,
                                0.45,0.45,0.2,0.2,
                                0.45,0.525,0.525,0.45,0.225,
                                0.225,0.5,0.2,0.075,0,0,
                                0,0.2,0,
                                0.2,0.2,0,0,
                                0.075,0.2,0,0),
                         
                         Silt=c(0,0,0.15,0.4,0.4,
                                0,0,0.2,
                                0,0,0.275,0.275,0.2,
                                0,0,0.3,0.5,0.5,0.425,0.275,
                                0,0,0.15,0.3,
                                0,0,0.15,
                                0.15,0.275,0.525,0.4,
                                0.275,0.275,0.425,0.5,0.5,
                                0.5,0.5,0.8,0.8,0.875,0.725,
                                0.4,0.4,0.6,
                                0.4,0.525,0.725,0.6,
                                0.8,0.8,1,0.875),
                         
                         Label=c("Clay","Clay","Clay","Clay","Clay",
                                 "Sandy Clay","Sandy Clay","Sandy Clay",
                                 "Sandy Clay Loam","Sandy Clay Loam","Sandy Clay Loam","Sandy Clay Loam","Sandy Clay Loam",
                                 "Sandy Loam","Sandy Loam","Sandy Loam","Sandy Loam","Sandy Loam","Sandy Loam","Sandy Loam",
                                 "Loamy Sand", "Loamy Sand","Loamy Sand","Loamy Sand",
                                 "Sand","Sand","Sand",
                                 "Clay Loam","Clay Loam","Clay Loam","Clay Loam",
                                 "Loam","Loam","Loam","Loam","Loam",
                                 "Silt Loam","Silt Loam","Silt Loam","Silt Loam","Silt Loam","Silt Loam",
                                 "Silty Clay","Silty Clay","Silty Clay",
                                 "Silty Clay Loam","Silty Clay Loam","Silty Clay Loam","Silty Clay Loam",
                                 "Silt","Silt","Silt","Silt")
)

data_text_usda <- usda_data  %>% group_by(Label) %>%
  summarise_if(is.numeric, mean, na.rm = TRUE)

# Define UI
ui <- fluidPage(
  
  titlePanel("Ternary Plot in Shiny"),
  sidebarLayout(
    sidebarPanel(
      style = "width: 400px;",
      tabsetPanel(
        tabPanel("Data Selection",
                 selectInput("dataset", "Select Dataset:",
                             choices = c("New Zealand", "USDA"),
                             selected = "New Zealand"),
                 hr(),
                 # Manual data entry section
                 conditionalPanel(
                   condition = "input.dataset == 'New Zealand'",
                   textInput("sampleName", "Sample Name"),
                   numericInput("sandValue", "Sand", value = 50, min = 0, max = 100),
                   numericInput("siltValue", "Silt", value = 25, min = 0, max = 100),
                   numericInput("clayValue", "Clay", value = 25, min = 0, max = 100),
                   actionButton("addManualDataBtn", "Add Data")
                 ),
                 conditionalPanel(
                   condition = "input.dataset == 'USDA'",
                   textInput("sampleName", "Sample Name"),
                   numericInput("sandValue", "Sand", value = 50, min = 0, max = 100),
                   numericInput("siltValue", "Silt", value = 25, min = 0, max = 100),
                   numericInput("clayValue", "Clay", value = 25, min = 0, max = 100),
                   actionButton("addManualDataBtn", "Add Data")
                 ),
                 br(),
                 actionButton("clearDataBtn_manual", "Clear Data"),
                 downloadButton("downloadDataBtn_manual", "Download Data")
        ),
        tabPanel("Upload CSV",
                 selectInput("dataset_upload", "Select Dataset:",
                             choices = c("New Zealand", "USDA"),
                             selected = "New Zealand"),
                 fileInput("fileUpload", "Upload CSV file", accept = ".csv"),
                 downloadButton("downloadTemplateBtn", "Download Template CSV"),
                 br(),
                 actionButton("clearDataBtn_upload", "Clear Data"),
                 downloadButton("downloadDataBtn_upload", "Download Data")
        )
      )
    ),
    mainPanel(
      # Output: Ternary Plot
      plotOutput("ternaryPlot", height = "700px", width = "100%")
    )
  )
)



# Define server logic
server <- function(input, output, session) {
  
  observeEvent(input$dataset, {
    updateSelectInput(session, "dataset_upload", selected = input$dataset)
  })
  
  observeEvent(input$dataset_upload, {
    updateSelectInput(session, "dataset", selected = input$dataset_upload)
  })
  
  # Initialize empty dataframe
  soil_data <- reactiveVal(data.frame(
    soil = character(),
    sand = numeric(),
    silt = numeric(),
    clay = numeric()
  ))
  
  # Update data with manual input
  observeEvent(input$addManualDataBtn, {
    # Check if the sum of sand, silt, and clay is equal to 100
    if (input$sandValue + input$siltValue + input$clayValue != 100) {
      showModal(modalDialog(
        title = "Error",
        "The sum of Clay, Silt, and Sand must be equal to 100%"
      ))
    } else {
      newSample <- data.frame(
        soil = input$sampleName,
        sand = input$sandValue,
        silt = input$siltValue,
        clay = input$clayValue
      )
      current_data <- soil_data()
      new_data <- rbind(current_data, newSample)
      soil_data(new_data)
    }
  })
  
  # Clear data (manual entry)
  observeEvent(input$clearDataBtn_manual, {
    soil_data(data.frame(
      soil = character(),
      sand = numeric(),
      silt = numeric(),
      clay = numeric()
    ))
  })
  
  # Clear data (upload)
  observeEvent(input$clearDataBtn_upload, {
    soil_data(data.frame(
      soil = character(),
      sand = numeric(),
      silt = numeric(),
      clay = numeric()
    ))
  })
  
  # Download data as CSV (manual entry)
  output$downloadDataBtn_manual <- downloadHandler(
    filename = function() {
      paste("soil_data_manual", ".csv", sep = "")
    },
    content = function(file) {
      write.csv(soil_data(), file, row.names = FALSE)
    }
  )
  
  # Download data as CSV (upload)
  output$downloadDataBtn_upload <- downloadHandler(
    filename = function() {
      paste("soil_data_upload", ".csv", sep = "")
    },
    content = function(file) {
      write.csv(soil_data(), file, row.names = FALSE)
    }
  )
  
  # Download template CSV
  output$downloadTemplateBtn <- downloadHandler(
    filename = function() {
      "template_soil_data.csv"
    },
    content = function(file) {
      # Create a template dataframe with headers
      template_data <- data.frame(
        soil = character(),
        sand = numeric(),
        silt = numeric(),
        clay = numeric()
      )
      # Write to CSV
      write.csv(template_data, file, row.names = FALSE)
    }
  )
  
  # Upload data from CSV
  observeEvent(input$fileUpload, {
    inFile <- input$fileUpload
    if (!is.null(inFile)) {
      data <- read.csv(inFile$datapath)
      # Check if the sum of sand, silt, and clay exceeds 100 in any row
      invalid_rows <- which(rowSums(data[, c("sand", "silt", "clay")]) > 100)
      if (length(invalid_rows) > 0) {
        showModal(modalDialog(
          title = "Error",
          paste("The sum of Sand, Silt, and Clay exceeds 100% in rows:", paste(invalid_rows, collapse = ", "))
        ))
      } else {
        soil_data(data)
      }
    }
  })
  
  # Render Plot
  output$ternaryPlot <- renderPlot({
    # Create ternary plot
    if(input$dataset == "New Zealand") {
      data <- nz_data
      data_text <- data_text_nz
      theme_function <- theme_anticlockwise()
    } else {
      data <- usda_data
      data_text <- data_text_usda
      theme_function <- theme_clockwise()
    }
    
    p <- ggplot(data = data, aes(
      y = Clay,
      x = Sand,
      z = Silt
    )) +
      coord_tern(L = "x", T = "y", R = "z") +
      geom_polygon(
        aes(fill = Label),
        alpha = 0.4,
        size = 0.5, 
        color = "black" 
      ) +
      geom_text(data = data_text, 
                aes(label = Label), 
                color = 'black',
                size = 5)   +
      geom_point(
        data = soil_data(),
        aes(x = sand,
            y = clay, 
            z = silt
        ), size=5, color="red" 
      ) +
      geom_text(
        data = soil_data(),
        aes(x = sand,
            y = clay, 
            z = silt,
            label = soil),
        color = 'red',
        size = 4,
        hjust=-1
      ) +
      theme_custom(base_size = 20,
                   col.T = "black",
                   col.L = "black",
                   col.R = "black") +
      theme_showarrows() +
      scale_T_continuous(breaks = c(0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1))+
      scale_L_continuous(breaks = c(0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1))+
      scale_R_continuous(breaks = c(0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1)) +
      theme_mesh(n = 10)+
      theme(legend.position = "none")  + 
      labs( x       = "",
            xarrow  = "Sand",
            y       = "",
            yarrow  = "Clay",
            z       = "",
            zarrow  = "Silt") +
      theme_arrowcustomlength(.35, .65) +
      theme_function
    
    print(p)
  })
}

# Run the application
shinyApp(ui = ui, server = server)

