#ui.R

require(shiny)
require(shinydashboard)
require(leaflet)

dashboardPage(
  dashboardHeader(
  ),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Causes of Death", tabName = "crosstab", icon = icon("dashboard")),
      menuItem("Hospital Profitability", tabName = "hospitalcrosstab", icon = icon("dashboard"))
      
    )
  ),
  
  dashboardBody(
    tabItems(
      # First tab content
      tabItem(tabName = "crosstab",
              actionButton(inputId = "light", label = "Light"),
              actionButton(inputId = "dark", label = "Dark"),
              sliderInput("KPI1", "KPI_Low_Max_value:", 
                          min = 1, max = 200,  value = 200),
              sliderInput("KPI2", "KPI_Medium_Max_value:", 
                          min = 400, max = 2000,  value = 2000),
              textInput(inputId = "title", 
                        label = "Crosstab Title",
                        value = "Cause Of Death Count For Los Angeles"),
              actionButton(inputId = "clicks1",  label = "Click me"),
              plotOutput("distPlot1")
      ),
      
      # Second tab content
      tabItem(tabName = "hospitalcrosstab",
              actionButton(inputId = "light", label = "Light"),
              actionButton(inputId = "dark", label = "Dark"),
              sliderInput("OPKPI1", "OPKPI_Bad_Max_value:", 
                          min = -240.0, max = -0.1,  value = -0.1),
              sliderInput("OPKPI2", "OPKPI_Good_Min_value:", 
                          min = 0, max = 320,  value = 0),
              textInput(inputId = "title", 
                        label = "Crosstab Title",
                        value = "Hospital Operating Margins by County and Type of Controller"),
              actionButton(inputId = "clicksHosp",  label = "Click me"),
              plotOutput("distPlot2", width = "100%", height = "1200px")
      )
      
    )
  )
)
