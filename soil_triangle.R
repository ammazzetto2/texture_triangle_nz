#------------------------------------------------- Required Libraries

source("R/dependencies.R", local = TRUE)
ensure_project_dependencies()

library(shiny)
library(ggplot2)
library(ggtern)
library(dplyr)

source("R/validation.R", local = TRUE)

source("R/classification_data.R", local = TRUE)
source("R/classification.R", local = TRUE)

data_text_nz <- nz_data  %>% 
                group_by(Label) %>%
                summarise_if(is.numeric, mean, na.rm = TRUE)

data_text_usda <- usda_data  %>% 
                  group_by(Label) %>%
                  summarise_if(is.numeric, mean, na.rm = TRUE)

data_text_australian <- australian_data  %>% 
                        group_by(Label) %>%
                        summarise_if(is.numeric, mean, na.rm = TRUE)

#################################################### Define UI
ui <- fluidPage(
  
  # Add CSS to ensure consistent zoom and scaling
  tags$head(
    tags$style(HTML("
    body {
      zoom: 100% !important;
    }
    @media (max-width: 1600px) {
      body { zoom: 90% !important; }
    }
    @media (max-width: 1366px) {
      body { zoom: 80% !important; }
    }
    .sidebarPanel {
      font-size: 18px !important;
    }
    label, .shiny-input-container {
      font-size: 18px !important;
    }
    .btn, .action-button, .download-button {
      font-size: 18px !important;
      padding: 10px;
    }
  "))
  ),
  
  
  titlePanel("Soil Classification Tool"),
  sidebarLayout(
    sidebarPanel(
      style = "min-width: 450px; max-width: 600px; width: 40%; font-size: 18px;", # Adjusted width & font size
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
                   style = "margin-top: 15px; padding: 15px;",  # Adds spacing & padding for better alignment
                   selectInput("dataset_upload", "Select Classification:",
                               choices = c("New Zealand", "USDA", "Australian"),
                               selected = "New Zealand"),
                   
                   tags$div(style = "margin-top: 10px;"),  # Add spacing
                   
                   fileInput("fileUpload", "Upload CSV file", accept = ".csv"),
                   
                   tags$div(style = "margin-top: 10px;"),  # Add spacing
                   
                   actionButton("clearDataBtn_upload", "Clear Data", style = "width: 100%;"),
                   
                   tags$div(style = "margin-top: 10px;"),  # Add spacing
                   
                   downloadButton("downloadDataBtn_upload", "Download Data", style = "width: 100%;"),
                   
                   tags$div(
                     img(src = "lincoln_uni.jpg", height = "80px", width = "20%", style = "margin-top: 20px;"),
                     tags$a("Contact - Josie Mazzetto", 
                            href = "mailto:josiane.lopesmazzetto@lincoln.ac.nz", 
                            style = "display: block; margin-top: 10px; text-align: left; color: #007bff;")
                   )
                 )
        )
      )
    ),
    mainPanel(
      style = "margin-top: -200px; margin-left: -80px; padding: 0;",  # Adjust the top margin to move chart upwards
      plotOutput("ternaryPlot", height = "1200px", width = "110%")
    )
  )
)



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
  
  # Keep the existing dataset intact when validation fails.
  add_samples <- function(read_samples) {
    samples <- tryCatch(
      read_samples(),
      error = function(e) {
        showModal(modalDialog(
          title = "Check sample data",
          conditionMessage(e),
          easyClose = TRUE
        ))
        NULL
      }
    )
    if (!is.null(samples)) {
      soil_data(rbind(soil_data(), samples))
    }
  }

  observeEvent(input$addManualDataBtn, {
    add_samples(function() {
      values <- list(input$sampleName, input$sandValue,
                     input$siltValue, input$clayValue)
      if (any(lengths(values) != 1L)) {
        stop("Enter a sample name and all three percentages.", call. = FALSE)
      }
      validate_soil_data(data.frame(
        soil = input$sampleName,
        sand = input$sandValue,
        silt = input$siltValue,
        clay = input$clayValue
      ))
    })
  })

  observeEvent(input$fileUpload, {
    req(input$fileUpload)
    add_samples(function() read_soil_csv(input$fileUpload$datapath))
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
  
  # Both download paths share the same classifier and export schema.
  output$downloadDataBtn_manual <- downloadHandler(
    filename = function() "soil_data_manual.csv",
    content = function(file) {
      write.csv(classify_soil_data(soil_data(), input$dataset), file,
                row.names = FALSE)
    }
  )

  output$downloadDataBtn_upload <- downloadHandler(
    filename = function() "classified_soil_data_upload.csv",
    content = function(file) {
      write.csv(classify_soil_data(soil_data(), input$dataset_upload), file,
                row.names = FALSE)
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
      geom_text(data = data_text %>% 
                  mutate(angle = ifelse(Label == "Loamy Sand" & input$dataset == "USDA", 330, 0)),
                aes(label = Label, angle = angle),
                color = 'black',
                size = 6)+
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
