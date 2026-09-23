# ============================================================
# EMERGENCYCARE
# Hospital Emergency Triage & Resource Allocation System
# ============================================================

# ---------------------------
# 1. LOAD PACKAGES
# ---------------------------

library(shiny)
library(shinydashboard)
library(dplyr)
library(ggplot2)
library(DT)

# ---------------------------
# 2. READ CSV DATA
# ---------------------------

patients <- read.csv("patients_100.csv",
                     stringsAsFactors = FALSE)

# ---------------------------
# 3. PRIORITY FUNCTION
# ---------------------------

calculate_priority <- function(severity, waiting_time) {
  
  if (severity >= 9) {
    
    priority <- "CRITICAL"
    
  } else if (severity >= 7) {
    
    priority <- "HIGH"
    
  } else if (severity >= 4) {
    
    if (waiting_time > 60) {
      priority <- "HIGH ATTENTION"
    } else {
      priority <- "MODERATE"
    }
    
  } else {
    
    if (waiting_time > 60) {
      priority <- "MODERATE ATTENTION"
    } else {
      priority <- "LOW"
    }
  }
  
  return(priority)
}

# ---------------------------
# 4. PROCESS PATIENT DATA
# ---------------------------

patients$Priority <- ""

for (i in 1:nrow(patients)) {
  
  patients$Priority[i] <- calculate_priority(
    patients$Severity[i],
    patients$Waiting_Time[i]
  )
}

# ---------------------------
# 5. BED ALLOCATION
# ---------------------------

available_beds <- 20

patients$Bed_Status <- "NOT REQUIRED"

beds_left <- available_beds

for (i in 1:nrow(patients)) {
  
  if (patients$Bed_Required[i] == "Yes") {
    
    if (beds_left > 0) {
      
      patients$Bed_Status[i] <- "BED ALLOCATED"
      beds_left <- beds_left - 1
      
    } else {
      
      patients$Bed_Status[i] <- "WAITING - NO BED"
    }
  }
}

# ---------------------------
# 6. EMERGENCY ALERTS
# ---------------------------

patients$Alert <- "NO ALERT"

for (i in 1:nrow(patients)) {
  
  if (patients$Priority[i] == "CRITICAL") {
    
    patients$Alert[i] <- "EMERGENCY ALERT"
    
  } else if (patients$Priority[i] == "HIGH ATTENTION") {
    
    patients$Alert[i] <- "WAITING TIME ALERT"
  }
}

# ---------------------------
# 7. SUMMARY VALUES
# ---------------------------

total_patients <- nrow(patients)

critical_patients <- sum(
  patients$Priority == "CRITICAL"
)

high_patients <- sum(
  patients$Priority == "HIGH" |
    patients$Priority == "HIGH ATTENTION"
)

beds_required <- sum(
  patients$Bed_Required == "Yes"
)

beds_allocated <- sum(
  patients$Bed_Status == "BED ALLOCATED"
)

patients_waiting <- sum(
  patients$Bed_Status == "WAITING - NO BED"
)

average_waiting <- mean(
  patients$Waiting_Time
)

bed_shortage <- max(
  beds_required - available_beds,
  0
)

# ============================================================
# UI
# ============================================================

ui <- dashboardPage(
  
  # ----------------------------------------------------------
  # HEADER
  # ----------------------------------------------------------
  
  dashboardHeader(
    title = span(
      icon("hospital"),
      " EmergencyCare"
    )
  ),
  
  # ----------------------------------------------------------
  # SIDEBAR
  # ----------------------------------------------------------
  
  dashboardSidebar(
    
    sidebarMenu(
      
      menuItem(
        "Dashboard",
        tabName = "dashboard",
        icon = icon("dashboard")
      ),
      
      menuItem(
        "Patient Records",
        tabName = "patients",
        icon = icon("users")
      ),
      
      menuItem(
        "Analytics",
        tabName = "analytics",
        icon = icon("chart-column")
      ),
      
      menuItem(
        "Alerts",
        tabName = "alerts",
        icon = icon("bell")
      )
    )
  ),
  
  # ----------------------------------------------------------
  # BODY
  # ----------------------------------------------------------
  
  dashboardBody(
    
    # Custom CSS
    tags$head(
      
      tags$style(HTML("
      
        /* Main background */
        .content-wrapper,
        .right-side {
          background-color: #f4f6f9;
        }
        
        /* Dashboard title */
        .dashboard-title {
          font-size: 28px;
          font-weight: bold;
          margin-bottom: 5px;
        }
        
        .dashboard-subtitle {
          font-size: 15px;
          color: #6c757d;
          margin-bottom: 20px;
        }
        
        /* Box styling */
        .small-box {
          border-radius: 12px;
          box-shadow: 0 3px 10px rgba(0,0,0,0.10);
        }
        
        /* Info panels */
        .box {
          border-radius: 10px;
          box-shadow: 0 2px 8px rgba(0,0,0,0.08);
        }
        
        /* Tables */
        table.dataTable tbody tr:hover {
          background-color: #f0f7ff !important;
        }
        
        /* Alert box */
        .emergency-alert {
          background-color: #fff3f3;
          border-left: 6px solid #dc3545;
          padding: 15px;
          border-radius: 8px;
          margin-bottom: 15px;
        }
        
        /* Footer */
        .project-footer {
          text-align: center;
          color: #777;
          padding: 20px;
          font-size: 13px;
        }
        
      "))
    ),
    
    tabItems(
      
      # ======================================================
      # DASHBOARD TAB
      # ======================================================
      
      tabItem(
        tabName = "dashboard",
        
        div(
          class = "dashboard-title",
          "🏥 EmergencyCare Dashboard"
        ),
        
        div(
          class = "dashboard-subtitle",
          "Hospital Emergency Triage & Resource Allocation System"
        ),
        
        # KPI CARDS
        fluidRow(
          
          valueBoxOutput(
            "totalPatients",
            width = 3
          ),
          
          valueBoxOutput(
            "criticalPatients",
            width = 3
          ),
          
          valueBoxOutput(
            "bedsAvailable",
            width = 3
          ),
          
          valueBoxOutput(
            "waitingPatients",
            width = 3
          )
        ),
        
        # SECOND ROW
        fluidRow(
          
          box(
            title = "Priority Distribution",
            status = "primary",
            solidHeader = TRUE,
            width = 6,
            plotOutput(
              "priorityPlot",
              height = "320px"
            )
          ),
          
          box(
            title = "Bed Resource Status",
            status = "success",
            solidHeader = TRUE,
            width = 6,
            plotOutput(
              "bedPlot",
              height = "320px"
            )
          )
        ),
        
        # THIRD ROW
        fluidRow(
          
          box(
            title = "Severity Distribution",
            status = "warning",
            solidHeader = TRUE,
            width = 6,
            plotOutput(
              "severityPlot",
              height = "320px"
            )
          ),
          
          box(
            title = "Waiting Time Analysis",
            status = "info",
            solidHeader = TRUE,
            width = 6,
            plotOutput(
              "waitingPlot",
              height = "320px"
            )
          )
        ),
        
        # RESOURCE SUMMARY
        fluidRow(
          
          box(
            title = "Resource Summary",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            
            fluidRow(
              
              column(
                3,
                h4("Total Beds"),
                h3(available_beds)
              ),
              
              column(
                3,
                h4("Beds Required"),
                h3(beds_required)
              ),
              
              column(
                3,
                h4("Beds Allocated"),
                h3(beds_allocated)
              ),
              
              column(
                3,
                h4("Bed Shortage"),
                h3(bed_shortage)
              )
            )
          )
        )
      ),
      
      # ======================================================
      # PATIENT RECORDS TAB
      # ======================================================
      
      tabItem(
        tabName = "patients",
        
        h2("Patient Records"),
        
        fluidRow(
          
          box(
            title = "Filters",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            
            fluidRow(
              
              column(
                4,
                textInput(
                  "patientSearch",
                  "Search Patient ID:",
                  placeholder = "Example: P001"
                )
              ),
              
              column(
                4,
                selectInput(
                  "priorityFilter",
                  "Priority:",
                  choices = c(
                    "All",
                    "CRITICAL",
                    "HIGH",
                    "HIGH ATTENTION",
                    "MODERATE",
                    "MODERATE ATTENTION",
                    "LOW"
                  ),
                  selected = "All"
                )
              ),
              
              column(
                4,
                selectInput(
                  "bedFilter",
                  "Bed Status:",
                  choices = c(
                    "All",
                    "BED ALLOCATED",
                    "WAITING - NO BED",
                    "NOT REQUIRED"
                  ),
                  selected = "All"
                )
              )
            )
          )
        ),
        
        fluidRow(
          
          box(
            title = "Patient Details",
            status = "info",
            solidHeader = TRUE,
            width = 12,
            
            DTOutput("patientTable")
          )
        )
      ),
      
      # ======================================================
      # ANALYTICS TAB
      # ======================================================
      
      tabItem(
        tabName = "analytics",
        
        h2("Emergency Analytics"),
        
        fluidRow(
          
          box(
            title = "Severity vs Waiting Time",
            status = "warning",
            solidHeader = TRUE,
            width = 8,
            
            plotOutput(
              "scatterPlot",
              height = "400px"
            )
          ),
          
          box(
            title = "Key Statistics",
            status = "primary",
            solidHeader = TRUE,
            width = 4,
            
            h4("Average Waiting Time"),
            h3(
              paste0(
                round(average_waiting, 1),
                " minutes"
              )
            ),
            
            hr(),
            
            h4("Critical Patients"),
            h3(critical_patients),
            
            hr(),
            
            h4("High Priority Patients"),
            h3(high_patients),
            
            hr(),
            
            h4("Patients Without Beds"),
            h3(patients_waiting)
          )
        ),
        
        fluidRow(
          
          box(
            title = "Waiting Time by Priority",
            status = "info",
            solidHeader = TRUE,
            width = 12,
            
            plotOutput(
              "priorityWaitingPlot",
              height = "400px"
            )
          )
        )
      ),
      
      # ======================================================
      # ALERTS TAB
      # ======================================================
      
      tabItem(
        tabName = "alerts",
        
        h2("Emergency Alerts"),
        
        fluidRow(
          
          box(
            title = "Critical Patient Alerts",
            status = "danger",
            solidHeader = TRUE,
            width = 12,
            
            uiOutput("alertPanel")
          )
        ),
        
        fluidRow(
          
          box(
            title = "Patients Waiting for Beds",
            status = "warning",
            solidHeader = TRUE,
            width = 12,
            
            DTOutput("waitingTable")
          )
        )
      )
    ),
    
    # FOOTER
    div(
      class = "project-footer",
      "EmergencyCare | Academic R Shiny Project | Hospital Emergency Triage Simulation"
    )
  )
)

# ============================================================
# SERVER
# ============================================================

server <- function(input, output, session) {
  
  # ----------------------------------------------------------
  # KPI 1 - TOTAL PATIENTS
  # ----------------------------------------------------------
  
  output$totalPatients <- renderValueBox({
    
    valueBox(
      total_patients,
      "Total Patients",
      icon = icon("users"),
      color = "aqua"
    )
  })
  
  
  # ----------------------------------------------------------
  # KPI 2 - CRITICAL PATIENTS
  # ----------------------------------------------------------
  
  output$criticalPatients <- renderValueBox({
    
    valueBox(
      critical_patients,
      "Critical Patients",
      icon = icon("triangle-exclamation"),
      color = "red"
    )
  })
  
  
  # ----------------------------------------------------------
  # KPI 3 - AVAILABLE BEDS
  # ----------------------------------------------------------
  
  output$bedsAvailable <- renderValueBox({
    
    valueBox(
      available_beds,
      "Total Beds",
      icon = icon("bed"),
      color = "green"
    )
  })
  
  
  # ----------------------------------------------------------
  # KPI 4 - WAITING PATIENTS
  # ----------------------------------------------------------
  
  output$waitingPatients <- renderValueBox({
    
    valueBox(
      patients_waiting,
      "Waiting for Beds",
      icon = icon("clock"),
      color = "yellow"
    )
  })
  
  
  # ----------------------------------------------------------
  # PRIORITY CHART
  # ----------------------------------------------------------
  
  output$priorityPlot <- renderPlot({
    
    priority_data <- patients %>%
      count(Priority)
    
    ggplot(
      priority_data,
      aes(
        x = reorder(Priority, n),
        y = n
      )
    ) +
      geom_col() +
      coord_flip() +
      labs(
        x = "Priority",
        y = "Number of Patients"
      ) +
      theme_minimal(base_size = 13)
  })
  
  
  # ----------------------------------------------------------
  # BED CHART
  # ----------------------------------------------------------
  
  output$bedPlot <- renderPlot({
    
    bed_data <- patients %>%
      count(Bed_Status)
    
    ggplot(
      bed_data,
      aes(
        x = reorder(Bed_Status, n),
        y = n
      )
    ) +
      geom_col() +
      coord_flip() +
      labs(
        x = "Bed Status",
        y = "Number of Patients"
      ) +
      theme_minimal(base_size = 13)
  })
  
  
  # ----------------------------------------------------------
  # SEVERITY CHART
  # ----------------------------------------------------------
  
  output$severityPlot <- renderPlot({
    
    ggplot(
      patients,
      aes(x = Severity)
    ) +
      geom_histogram(
        binwidth = 1,
        boundary = 0.5
      ) +
      scale_x_continuous(
        breaks = 1:10
      ) +
      labs(
        x = "Severity Level",
        y = "Number of Patients"
      ) +
      theme_minimal(base_size = 13)
  })
  
  
  # ----------------------------------------------------------
  # WAITING TIME CHART
  # ----------------------------------------------------------
  
  output$waitingPlot <- renderPlot({
    
    ggplot(
      patients,
      aes(x = Waiting_Time)
    ) +
      geom_histogram(
        bins = 15
      ) +
      labs(
        x = "Waiting Time (minutes)",
        y = "Number of Patients"
      ) +
      theme_minimal(base_size = 13)
  })
  
  
  # ----------------------------------------------------------
  # PATIENT SEARCH + FILTER
  # ----------------------------------------------------------
  
  filteredPatients <- reactive({
    
    data <- patients
    
    # Search Patient ID
    if (input$patientSearch != "") {
      
      data <- data[
        grepl(
          input$patientSearch,
          data$Patient_ID,
          ignore.case = TRUE
        ),
      ]
    }
    
    # Priority filter
    if (input$priorityFilter != "All") {
      
      data <- data[
        data$Priority == input$priorityFilter,
      ]
    }
    
    # Bed filter
    if (input$bedFilter != "All") {
      
      data <- data[
        data$Bed_Status == input$bedFilter,
      ]
    }
    
    data
  })
  
  
  # ----------------------------------------------------------
  # PATIENT TABLE
  # ----------------------------------------------------------
  
  output$patientTable <- renderDT({
    
    datatable(
      filteredPatients(),
      
      options = list(
        pageLength = 10,
        scrollX = TRUE
      ),
      
      rownames = FALSE
    )
  })
  
  
  # ----------------------------------------------------------
  # SCATTER PLOT
  # ----------------------------------------------------------
  
  output$scatterPlot <- renderPlot({
    
    ggplot(
      patients,
      aes(
        x = Waiting_Time,
        y = Severity
      )
    ) +
      geom_point(
        size = 3
      ) +
      labs(
        title = "Severity vs Waiting Time",
        x = "Waiting Time (minutes)",
        y = "Severity"
      ) +
      theme_minimal(base_size = 14)
  })
  
  
  # ----------------------------------------------------------
  # PRIORITY WAITING TIME PLOT
  # ----------------------------------------------------------
  
  output$priorityWaitingPlot <- renderPlot({
    
    ggplot(
      patients,
      aes(
        x = Priority,
        y = Waiting_Time
      )
    ) +
      geom_boxplot() +
      coord_flip() +
      labs(
        x = "Priority",
        y = "Waiting Time (minutes)"
      ) +
      theme_minimal(base_size = 13)
  })
  
  
  # ----------------------------------------------------------
  # EMERGENCY ALERT PANEL
  # ----------------------------------------------------------
  
  output$alertPanel <- renderUI({
    
    alerts <- patients %>%
      filter(
        Alert != "NO ALERT"
      )
    
    if (nrow(alerts) == 0) {
      
      return(
        div(
          class = "emergency-alert",
          "No emergency alerts."
        )
      )
    }
    
    alert_list <- lapply(
      1:nrow(alerts),
      function(i) {
        
        div(
          class = "emergency-alert",
          
          tags$b(
            paste(
              alerts$Patient_ID[i],
              "-",
              alerts$Alert[i]
            )
          ),
          
          br(),
          
          paste(
            "Severity:",
            alerts$Severity[i]
          ),
          
          br(),
          
          paste(
            "Waiting Time:",
            alerts$Waiting_Time[i],
            "minutes"
          ),
          
          br(),
          
          paste(
            "Priority:",
            alerts$Priority[i]
          )
        )
      }
    )
    
    tagList(alert_list)
  })
  
  
  # ----------------------------------------------------------
  # WAITING FOR BED TABLE
  # ----------------------------------------------------------
  
  output$waitingTable <- renderDT({
    
    waiting_data <- patients %>%
      filter(
        Bed_Status == "WAITING - NO BED"
      ) %>%
      select(
        Patient_ID,
        Severity,
        Waiting_Time,
        Priority,
        Bed_Status,
        Alert
      )
    
    datatable(
      waiting_data,
      
      options = list(
        pageLength = 10,
        scrollX = TRUE
      ),
      
      rownames = FALSE
    )
  })
}

# ============================================================
# RUN APPLICATION
# ============================================================

shinyApp(
  ui = ui,
  server = server
)