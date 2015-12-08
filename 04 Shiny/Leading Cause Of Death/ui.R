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
      menuItem("Barchart", tabName = "barchart", icon = icon("th")),
      menuItem("Blending", tabName = "blending", icon = icon("th")),
      menuItem("Map", tabName = "map", icon = icon("th")),
      menuItem("Table", tabName = "table", icon = icon("th"))
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
      )
    )
  )
)
