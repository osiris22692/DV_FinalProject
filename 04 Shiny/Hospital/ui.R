#ui.R

require(shiny)
require(shinydashboard)
require(leaflet)

dashboardPage(
  dashboardHeader(
  ),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Crosstab", tabName = "crosstab", icon = icon("dashboard")),
    )
  ),
  dashboardBody(
    tabItems(
      # First tab content
      tabItem(tabName = "crosstab",
              actionButton(inputId = "light", label = "Light"),
              actionButton(inputId = "dark", label = "Dark"),
              sliderInput("KPI1", "KPI_Low_Max_value:", 
                          min = 0, max = -0.1,  value = -0.1),
              sliderInput("KPI2", "KPI_Medium_Max_value:", 
                          min = 0, max = 22.26,  value = 22.26),
              textInput(inputId = "title", 
                        label = "Crosstab Title",
                        value = "Operating Margin by County and Region"),
              actionButton(inputId = "clicks1",  label = "Click me"),
              plotOutput("distPlot1")
      ),
      )
    )
  )
)
