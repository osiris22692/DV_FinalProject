#ui.R

require(shiny)
require(shinydashboard)
require(leaflet)

dashboardPage(
  dashboardHeader(
  ),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Hospital Profitability", tabName = "hospitalcrosstab", icon = icon("dashboard"))
      
    )
  ),
  
  dashboardBody(
    tabItems(
      # First tab content
      tabItem(tabName = "hospitalcrosstab",
              actionButton(inputId = "lighter", label = "Lighter"),
              actionButton(inputId = "darker", label = "Darker"),
              sliderInput("OPKPI1", "OPKPI_Bad_Max_value:", 
                          min = -240.0, max = -0.1,  value = -0.1),
              sliderInput("OPKPI2", "OPKPI_Good_Min_value:", 
                          min = 0, max = 320,  value = 0),
              textInput(inputId = "title", 
                        label = "Crosstab Title",
                        value = "Hospital Operating Margins by County and Type of Controller"),
              actionButton(inputId = "clicksHosp",  label = "Click me"),
              plotOutput("distPlot1", width = "100%", height = "1200px")
      )
      
      )
    )
  )
