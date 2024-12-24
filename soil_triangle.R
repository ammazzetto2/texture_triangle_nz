#------------------------------------------------- Required Libraries

library(shiny)
library(ggplot2)
library(ggtern)
library(dplyr)

#------------------------------------------------- NZ 
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

data_text_nz <- nz_data  %>% 
                group_by(Label) %>%
                summarise_if(is.numeric, mean, na.rm = TRUE)

#------------------------------------------------- USDA

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
                                 "Sandy \n Clay","Sandy \n Clay","Sandy \n Clay",
                                 "Sandy Clay Loam","Sandy Clay Loam","Sandy Clay Loam","Sandy Clay Loam","Sandy Clay Loam",
                                 "Sandy Loam","Sandy Loam","Sandy Loam","Sandy Loam","Sandy Loam","Sandy Loam","Sandy Loam",
                                 "Loamy Sand", "Loamy Sand","Loamy Sand","Loamy Sand",
                                 "Sand","Sand","Sand",
                                 "Clay Loam","Clay Loam","Clay Loam","Clay Loam",
                                 "Loam","Loam","Loam","Loam","Loam",
                                 "Silt Loam","Silt Loam","Silt Loam","Silt Loam","Silt Loam","Silt Loam",
                                 "Silty Clay","Silty Clay","Silty Clay",
                                 "Silty Clay \n Loam","Silty Clay \n Loam","Silty Clay \n Loam","Silty Clay \n Loam",
                                 "Silt","Silt","Silt","Silt")
)

data_text_usda <- usda_data  %>% 
                  group_by(Label) %>%
                  summarise_if(is.numeric, mean, na.rm = TRUE)

#------------------------------------------------- Australian

australian_data <- data.frame (Clay=c(0, 0, 0.09, 0.08,
                                      0.12, 0.1, 0.2, 0.32,
                                      0.75, 0.4, 0.4,
                                      0.08, 0.18, 0.2, 0.1,
                                      0.28, 0.5, 0.32,
                                      1, 0.5, 0.32, 0.4, 0.75,
                                      0.4, 0.4, 0.32, 0.32,
                                      0.32, 0.32, 0, 0,
                                      0.09, 0, 0, 0.12,
                                      0.18, 0.2, 0.32, 0.28,
                                      0.4, 0.32, 0.2, 0.32),
                                      
                               
                               Sand=c(1, 0.93, 0.85, 0.92,
                                      0.63, 0.765, 0.7, 0.43,
                                      0, 0.35, 0,
                                      0.92, 0.82, 0.7, 0.765,
                                      0.72, 0.5, 0.62,
                                      0, 0.5, 0.62, 0.35, 0,
                                      0.35, 0, 0, 0.43,
                                      0.43, 0, 0, 0.75,
                                      0.85, 0.93, 0.75, 0.63,
                                      0.82, 0.7, 0.62, 0.72,
                                      0.35, 0.43, 0.7, 0.62),
                               
                               Silt=c(0, 0.07, 0.06, 0,
                                      0.25, 0.135, 0.1, 0.25,
                                      0.25, 0.25, 0.6,
                                      0, 0, 0.1, 0.135,
                                      0, 0, 0.06,
                                      0, 0, 0.06, 0.25, 0.25,
                                      0.25, 0.6, 0.68, 0.25,
                                      0.25, 0.68, 1, 0.25,
                                      0.06, 0.07, 0.25, 0.25,
                                      0, 0.1, 0.06, 0,
                                      0.25, 0.25, 0.1, 0.06),
                               
                               Label=c("Sand","Sand","Sand", "Sand",
                                       "Loam", "Loam", "Loam", "Loam",
                                       "Silty Clay", "Silty Clay", "Silty Clay",
                                       "Sandy Loam", "Sandy Loam", "Sandy Loam", "Sandy Loam",
                                       "Sandy Clay", "Sandy Clay", "Sandy Clay",
                                       "Clay", "Clay", "Clay", "Clay", "Clay",
                                       "Silty Clay Loam", "Silty Clay Loam", "Silty Clay Loam", "Silty Clay Loam",
                                       "Silty Loam", "Silty Loam", "Silty Loam", "Silty Loam",
                                       "Loamy Sand", "Loamy Sand", "Loamy Sand", "Loamy Sand",
                                       "Sandy Clay Loam", "Sandy Clay Loam", "Sandy Clay Loam", "Sandy Clay Loam", 
                                       "Clay Loam", "Clay Loam", "Clay Loam", "Clay Loam")
)

data_text_australian <- australian_data  %>% 
                        group_by(Label) %>%
                        summarise_if(is.numeric, mean, na.rm = TRUE)

#################################################### Define UI
ui <- fluidPage(
  titlePanel("Soil Classification Tool"),
  sidebarLayout(
    sidebarPanel(
      style = "width: 400px;",
      tabsetPanel(
        tabPanel("Introduction",
                 tags$div(
                   style = "margin-top: 15px;",
                   tags$p("TBC text", style = "font-size: 16px; margin-bottom: 20px;"),  # Placeholder for text
                   img(src = "lincoln_uni.jpg", height = "80px", width = "40%", style = "margin-bottom: 20px;"),
                   tags$a("Contact - Josie Mazzetto", 
                          href = "mailto:josiane.lopesmazzetto@lincoln.ac.nz", 
                          style = "display: block; text-align: left; color: #007bff;")
                 )
        ),
        tabPanel("Data Selection",
                 tags$div(
                   style = "margin-top: 15px;",  # Adds spacing from the top
                   selectInput("dataset", "Select Classification:",
                               choices = c("New Zealand", "USDA", "Australian"),
                               selected = "New Zealand")
                 ),
                 hr(),
                 # Manual data entry section
                 textInput("sampleName", "Sample Name"),
                 numericInput("sandValue", "% Sand (0 to 100)", value = 50, min = 0, max = 100),
                 numericInput("siltValue", "% Silt (0 to 100)", value = 25, min = 0, max = 100),
                 numericInput("clayValue", "% Clay (0 to 100)", value = 25, min = 0, max = 100),
                 tags$div(
                   tags$div(
                     actionButton("addManualDataBtn", "Add Data", style = "width: 100%;"),
                     actionButton("clearDataBtn_manual", "Clear Data", style = "width: 100%;"),
                     style = "display: flex; flex-direction: column; gap: 10px;"  # Vertically aligned buttons with spacing
                   ),
                   tags$div(
                     downloadButton("downloadDataBtn_manual", "Download Data", style = "width: 100%;"),
                     style = "margin-top: 15px;"  # Add space above the download button
                   )
                 ),
                 tags$div(
                   img(src = "lincoln_uni.jpg", height = "80px", width = "40%", style = "margin-top: 20px;"),
                   tags$a("Contact - Josie Mazzetto", 
                          href = "mailto:josiane.lopesmazzetto@lincoln.ac.nz", 
                          style = "display: block; margin-top: 10px; text-align: left; color: #007bff;")
                 )
        ),
        tabPanel("Upload data",
                 tags$div(
                   style = "margin-top: 15px;",  # Adds spacing from the top
                   selectInput("dataset_upload", "Select Classification:",
                               choices = c("New Zealand", "USDA", "Australian"),
                               selected = "New Zealand")
                 ),
                 tags$div(
                   downloadButton("downloadTemplateBtn", "Download Template CSV", style = "width: 100%;"),
                   style = "display: flex; flex-direction: column; gap: 15px; margin-top: 15px;" # Vertically aligned buttons
                ),     
                fileInput("fileUpload", "Upload CSV file", accept = ".csv"),
                 tags$div(
                   actionButton("clearDataBtn_upload", "Clear Data", style = "width: 100%;"),
                   downloadButton("downloadDataBtn_upload", "Download Data", style = "width: 100%;"),
                   style = "display: flex; flex-direction: column; gap: 15px; margin-top: 15px;" # Vertically aligned buttons
                 ),
                 tags$div(
                   img(src = "lincoln_uni.jpg", height = "80px", width = "40%", style = "margin-top: 20px;"),
                   tags$a("Contact - Josie Mazzetto", 
                          href = "mailto:josiane.lopesmazzetto@lincoln.ac.nz", 
                          style = "display: block; margin-top: 10px; text-align: left; color: #007bff;")
                 )
        )
      )
    ),
    mainPanel(
      style = "margin-top: -250px; margin-left: -100px; padding: 0;",  # Adjust the top margin to move chart upwards
      plotOutput("ternaryPlot", height = "1200px", width = "110%")
    )
  )
)



# Define server logic
# Load necessary libraries
library(pracma)

# Define server logic
# Define server logic
server <- function(input, output, session) {
  
  # Update the selected dataset in both tabs
  observeEvent(input$dataset, {
    updateSelectInput(session, "dataset_upload", selected = input$dataset)
  })
  
  observeEvent(input$dataset_upload, {
    updateSelectInput(session, "dataset", selected = input$dataset_upload)
  })
  
  # Initialize empty dataframe to hold soil data
  soil_data <- reactiveVal(data.frame(
    soil = character(),
    sand = numeric(),
    silt = numeric(),
    clay = numeric()
  ))
  
  # Update soil data with manual input
  observeEvent(input$addManualDataBtn, {
    # Check if the sum of sand, silt, and clay is 100
    if (input$sandValue + input$siltValue + input$clayValue != 100) {
      showModal(modalDialog(
        title = "Error",
        "The sum of Sand, Silt, and Clay must be equal to 100%"
      ))
    } else {
      newSample <- data.frame(
        soil = input$sampleName,
        sand = input$sandValue,
        silt = input$siltValue,
        clay = input$clayValue
      )
      current_data <- soil_data()
      updated_data <- rbind(current_data, newSample)
      soil_data(updated_data)
    }
  })
  
  # Process uploaded CSV file
  observeEvent(input$fileUpload, {
    req(input$fileUpload) # Ensure a file is uploaded
    
    # Read the uploaded CSV file
    uploaded_data <- read.csv(input$fileUpload$datapath)
    
    # Validate the uploaded data
    if (!all(c("soil", "sand", "silt", "clay") %in% colnames(uploaded_data))) {
      showModal(modalDialog(
        title = "Error",
        "The uploaded file must contain columns: 'soil', 'sand', 'silt', and 'clay'."
      ))
    } else {
      # Check if sand, silt, and clay add up to 100 for all rows
      if (any(rowSums(uploaded_data[, c("sand", "silt", "clay")]) != 100)) {
        showModal(modalDialog(
          title = "Error",
          "The sum of Sand, Silt, and Clay must equal 100% in all rows."
        ))
      } else {
        # Add uploaded data to soil_data
        current_data <- soil_data()
        updated_data <- rbind(current_data, uploaded_data)
        soil_data(updated_data)
      }
    }
  })
  
  # Clear manually added soil data
  observeEvent(input$clearDataBtn_manual, {
    soil_data(data.frame(
      soil = character(),
      sand = numeric(),
      silt = numeric(),
      clay = numeric()
    ))
  })
  
  # Clear uploaded soil data
  observeEvent(input$clearDataBtn_upload, {
    soil_data(data.frame(
      soil = character(),
      sand = numeric(),
      silt = numeric(),
      clay = numeric()
    ))
  })
  
  # Download template CSV
  output$downloadTemplateBtn <- downloadHandler(
    filename = function() {
      "template_soil_data.csv"
    },
    content = function(file) {
      template <- data.frame(
        soil = character(),
        sand = numeric(),
        silt = numeric(),
        clay = numeric()
      )
      write.csv(template, file, row.names = FALSE)
    }
  )
  
  # Function to classify points based on polygons using pracma::inpolygon
  classify_points <- function(points, polygons) {
    classification <- rep(NA, nrow(points))  # Initialize classifications as NA
    for (i in seq_along(polygons)) {
      polygon <- polygons[[i]]
      inside <- inpolygon(points$sand / 100, points$clay / 100, polygon$Sand, polygon$Clay)
      classification[inside] <- names(polygons)[i]
    }
    return(classification)
  }
  
  # Download handler for manually entered data
  output$downloadDataBtn_manual <- downloadHandler(
    filename = function() {
      paste("soil_data_manual", ".csv", sep = "")
    },
    content = function(file) {
      points <- soil_data()
      
      if (nrow(points) > 0) {
        # Select dataset polygons based on the selected dataset
        if (input$dataset == "New Zealand") {
          polygons <- split(nz_data[, c("Sand", "Silt", "Clay")], nz_data$Label)
          classification_system <- "New Zealand"
        } else if (input$dataset == "USDA") {
          polygons <- split(usda_data[, c("Sand", "Silt", "Clay")], usda_data$Label)
          classification_system <- "USDA"
        } else if (input$dataset == "Australian") {
          polygons <- split(australian_data[, c("Sand", "Silt", "Clay")], australian_data$Label)
          classification_system <- "Australian"
        }
        
        # Classify points into polygons
        points$classification <- classify_points(points, polygons)
        points$classification_system <- classification_system  # Add classification system column
      } else {
        points <- data.frame(
          soil = character(0),
          sand = numeric(0),
          silt = numeric(0),
          clay = numeric(0),
          classification = character(0),
          classification_system = character(0)
        )
      }
      
      write.csv(points, file, row.names = FALSE)
    }
  )
  
  # Download handler for uploaded data
  output$downloadDataBtn_upload <- downloadHandler(
    filename = function() {
      paste("classified_soil_data_upload", ".csv", sep = "")
    },
    content = function(file) {
      points <- soil_data()
      
      if (nrow(points) > 0) {
        # Select dataset polygons based on the selected dataset
        if (input$dataset_upload == "New Zealand") {
          polygons <- split(nz_data[, c("Sand", "Silt", "Clay")], nz_data$Label)
          classification_system <- "New Zealand"
        } else if (input$dataset_upload == "USDA") {
          polygons <- split(usda_data[, c("Sand", "Silt", "Clay")], usda_data$Label)
          classification_system <- "USDA"
        } else if (input$dataset_upload == "Australian") {
          polygons <- split(australian_data[, c("Sand", "Silt", "Clay")], australian_data$Label)
          classification_system <- "Australian"
        }
        
        # Classify points into polygons
        points$classification <- classify_points(points, polygons)
        points$classification_system <- classification_system  # Add classification system column
      } else {
        points <- data.frame(
          soil = character(0),
          sand = numeric(0),
          silt = numeric(0),
          clay = numeric(0),
          classification = character(0),
          classification_system = character(0)
        )
      }
      
      write.csv(points, file, row.names = FALSE)
    }
  )
  
  # Render ternary plot
  output$ternaryPlot <- renderPlot({
    # Dynamically assign data based on the selected dataset
    if (input$dataset == "New Zealand") {
      polygon_data <- nz_data
      data_text <- data_text_nz
      theme_function <- theme(
        tern.axis.arrow = element_line(colour = "black", size = 1.5),
        tern.axis.arrow.text.L = element_text(hjust = 0.5, vjust = -1.0),
        tern.axis.arrow.text.T = element_text(hjust = 0.5, vjust = -1.0),
        tern.axis.arrow.text.R = element_text(hjust = 1.2, vjust = 1.0),
        tern.axis.arrow.sep = 0.05,
        tern.grid.major = element_blank(),
        tern.grid.minor = element_blank(),
        tern.panel.background = element_blank(),
        tern.axis.clockwise = FALSE,
        axis.text = element_text(size = 20, colour = "black")
      )
    } else if (input$dataset == "USDA") {
      polygon_data <- usda_data
      data_text <- data_text_usda
      theme_function <- theme(
        tern.axis.arrow = element_line(colour = "black", size = 1.5),
        tern.axis.arrow.text.L = element_text(hjust = 1.2, vjust = 1.0),
        tern.axis.arrow.text.T = element_text(hjust = 0.5, vjust = -1.0),
        tern.axis.arrow.text.R = element_text(hjust = -0.5, vjust = -1.0),
        tern.axis.arrow.sep = 0.05,
        tern.grid.major = element_blank(),
        tern.grid.minor = element_blank(),
        tern.panel.background = element_blank(),
        tern.axis.clockwise = TRUE,
        axis.text = element_text(size = 20, colour = "black")
      )
    } else if (input$dataset == "Australian") {
      polygon_data <- australian_data
      data_text <- data_text_australian
      theme_function <- theme(
        tern.axis.arrow = element_line(colour = "black", size = 1.5),
        tern.axis.arrow.text.L = element_text(hjust = 1.2, vjust = 1.0),
        tern.axis.arrow.text.T = element_text(hjust = 0.5, vjust = -1.0),
        tern.axis.arrow.text.R = element_text(hjust = -0.5, vjust = -1.0),
        tern.axis.arrow.sep = 0.05,
        tern.grid.major = element_blank(),
        tern.grid.minor = element_blank(),
        tern.panel.background = element_blank(),
        tern.axis.clockwise = TRUE,
        axis.text = element_text(size = 20, colour = "black")
      )
    }
    
    # Outer triangle coordinates (no need to change)
    outer_triangle <- data.frame(
      x = c(0, 1, 0, 0),
      y = c(0, 0, 1, 0),
      z = c(1, 0, 0, 1)
    )
    
    # Plot
    p <- ggplot(data = polygon_data, aes(
      x = Sand,
      y = Clay,
      z = Silt
    )) +
      coord_tern(L = "x", T = "y", R = "z") +
      geom_polygon(
        aes(fill = Label),
        alpha = 0.4,
        size = 1,
        color = "black"
      ) +
      geom_text(data = data_text,
                aes(label = Label),
                color = 'black',
                size = 6) +
      geom_point(
        data = soil_data(),
        aes(x = sand,
            y = clay,
            z = silt),
        size = 7, color = "red"
      ) +
      geom_text(
        data = soil_data(),
        aes(x = sand,
            y = clay,
            z = silt,
            label = soil),
        color = 'red',
        size = 6,
        hjust = -1
      ) +
      geom_path(
        data = outer_triangle,
        aes(x = x, y = y, z = z),
        size = 2,
        color = "black"
      ) +
      
      theme_showarrows() +
      
      scale_T_continuous(breaks = seq(0.1, 1, by = 0.1)) +
      
      scale_L_continuous(breaks = seq(0.1, 1, by = 0.1)) +
      
      scale_R_continuous(breaks = seq(0.1, 1, by = 0.1)) +
      
      theme(legend.position = "none") +
      
      labs(
        x = "",
        xarrow = ifelse(input$dataset == "USDA", "Sand", "Sand"),
        y = "",
        yarrow = ifelse(input$dataset == "USDA", "Clay", "Clay"),
        z = "",
        zarrow = ifelse(input$dataset == "USDA", "Silt", "Silt")
      ) +
      theme_function  # Apply the dynamic theme
    
    print(p)
  })
  
}
  
# Run the application
shinyApp(ui = ui, server = server)