# server.R
require("jsonlite")
require("RCurl")
require(ggplot2)
require(dplyr)
require(shiny)
require(shinydashboard)
require(leaflet)
require(DT)

shinyServer(function(input, output) {
  
  KPI_Low_Max_value <- reactive({input$KPI1})     
  KPI_Medium_Max_value <- reactive({input$KPI2})
  rv <- reactiveValues(alpha = 0.50)
  observeEvent(input$light, { rv$alpha <- 0.50 })
  observeEvent(input$dark, { rv$alpha <- 0.75 })
  
  df1 <- eventReactive(input$clicks1, {data.frame(fromJSON(getURL(URLencode(gsub("\n", " ", 'skipper.cs.utexas.edu:5001/rest/native/?query="SELECT  LEADING_CAUSES_OF_DEATH.YEAR AS \\\"YEAR\\\", FREE_ZIPCODE_DATABASE.CITY AS CITY, LEADING_CAUSES_OF_DEATH.CAUSES_OF_DEATH AS CAUSES_OF_DEATH, SUM(LEADING_CAUSES_OF_DEATH.COUNT) AS SUM_COUNT, CASE WHEN SUM(LEADING_CAUSES_OF_DEATH.COUNT) >= "p2" THEN \\\'03 HIGH\\\' WHEN SUM(LEADING_CAUSES_OF_DEATH.COUNT) >= "p1" THEN \\\'02 MIDDLE\\\' ELSE \\\'01 LOW\\\' END COUNT_KPI FROM FREE_ZIPCODE_DATABASE JOIN LEADING_CAUSES_OF_DEATH ON FREE_ZIPCODE_DATABASE.ZIPCODE = LEADING_CAUSES_OF_DEATH.ZIP_CODE WHERE FREE_ZIPCODE_DATABASE.CITY = \\\'LOS ANGELES\\\' GROUP BY FREE_ZIPCODE_DATABASE.CITY, LEADING_CAUSES_OF_DEATH.YEAR, LEADING_CAUSES_OF_DEATH.CAUSES_OF_DEATH;"')), httpheader=c(DB='jdbc:oracle:thin:@sayonara.microlab.cs.utexas.edu:1521:orcl', USER='C##cs329e_jzp78', PASS='orcl_jzp78', MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON', p1=KPI_Low_Max_value(), p2=KPI_Medium_Max_value()), verbose = TRUE)))
  })
  
  output$distPlot1 <- renderPlot({             
    plot <- ggplot() + 
      coord_cartesian() + 
      scale_x_continuous() +
      scale_y_discrete() +
      labs(title=isolate(input$title)) +
      labs(x=paste("YEAR"), y=paste("CAUSES OF DEATH")) +
      layer(data=df1(), 
            mapping=aes(x=YEAR, y=CAUSES_OF_DEATH, label=SUM_COUNT), 
            stat="identity", 
            stat_params=list(), 
            geom="text",
            geom_params=list(colour="black"), 
            position=position_identity()
      ) +
      layer(data=df1(), 
            mapping=aes(x=YEAR, y=CAUSES_OF_DEATH, fill=COUNT_KPI), 
            stat="identity", 
            stat_params=list(), 
            geom="tile",
            geom_params=list(alpha=rv$alpha), 
            position=position_identity()
      )
    plot
  }) 
  
  observeEvent(input$clicks, {
    print(as.numeric(input$clicks))
  })
  
  # Begin code for Second Tab:

  
})
