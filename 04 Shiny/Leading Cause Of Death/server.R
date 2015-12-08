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
  
  df1 <- eventReactive(input$clicks1, {data.frame(fromJSON(getURL(URLencode(gsub("\n", " ", 'skipper.cs.utexas.edu:5001/rest/native/?query=
                                                                                 "SELECT LEADINGCAUSESOFDEATH.YEARDATA, SUM(LEADINGCAUSESOFDEATH.COUNTDATA) AS SUM_COUNT, FREEZIPCODEDATABASE.CITYDATA, LEADINGCAUSESOFDEATH.CAUSES_OF_DEATH, 
case
                                                                                 when SUM(LEADINGCAUSESOFDEATH.COUNTDATA) >= "p2" THEN \\\'01 High\\\'
                                                                                 when SUM(LEADINGCAUSESOFDEATH.COUNTDATA) >= "p1" THEN \\\'02 Medium\\\'
                                                                                 else \\\'03 Low\\\'
                                                                                 end COUNTKPI
                                                                                 From FREEZIPCODEDATABASE JOIN LEADINGCAUSESOFDEATH On FREEZIPCODEDATABASE.Zipcode = LEADINGCAUSESOFDEATH.Zip_Code
                                                                                 GROUP BY LEADINGCAUSESOFDEATH.YEARDATA, FREEZIPCODEDATABASE.CITYDATA, LEADINGCAUSESOFDEATH.CAUSES_OF_DEATH
                                                                                 ORDER BY FREEZIPCODEDATABASE.CITYDATA;"
                                                                                 ')), httpheader=c(DB='jdbc:oracle:thin:@sayonara.microlab.cs.utexas.edu:1521:orcl', USER='C##cs329e_jzp78', PASS='orcl_jzp78', 
                                                                                                   MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON', p1=KPI_Low_Max_value(), p2=KPI_Medium_Max_value()), verbose = TRUE)))
  })
  
  output$distPlot1 <- renderPlot({             
    plot <- ggplot() + 
      coord_cartesian() + 
      scale_x_discrete() +
      scale_y_discrete() +
      labs(title=isolate(input$title)) +
      labs(x=paste("YEAR"), y=paste("CAUSES OF DEATH")) +
      layer(data=df1(), 
            mapping=aes(x=LEADINGCAUSESOFDEATH.YEARDATA, y=LEADINGCAUSESOFDEATH.CAUSES_OF_DEATH, label=SUM_COUNT), 
            stat="identity", 
            stat_params=list(), 
            geom="text",
            geom_params=list(colour="black"), 
            position=position_identity()
      ) +
      layer(data=df1(), 
            mapping=aes(x=LEADINGCAUSESOFDEATH.YEARDATA, y=LEADINGCAUSESOFDEATH.CAUSES_OF_DEATH, fill=COUNTKPI), 
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
  
  df2 <- eventReactive(input$clicks2, {data.frame(fromJSON(getURL(URLencode(gsub("\n", " ", 'skipper.cs.utexas.edu:5001/rest/native/?query=
                                                                                 "SELECT LEADINGCAUSESOFDEATH.YEARDATA, SUM(LEADINGCAUSESOFDEATH.COUNTDATA) AS SUM_COUNT, FREEZIPCODEDATABASE.CITYDATA, LEADINGCAUSESOFDEATH.CAUSES_OF_DEATH 
From FREEZIPCODEDATABASE JOIN LEADINGCAUSESOFDEATH On FREEZIPCODEDATABASE.Zipcode = LEADINGCAUSESOFDEATH.Zip_Code
                                                                                 WHERE FREEZIPCODEDATABASE.CITYDATA=\\\'LOS ANGELES\\\' OR FREEZIPCODEDATABASE.CITYDATA=\\\'SAN DIEGO\\\' OR FREEZIPCODEDATABASE.CITYDATA=\\\'SAN FRANCISCO\\\' OR FREEZIPCODEDATABASE.CITYDATA=\\\'OAKLAND\\\' OR FREEZIPCODEDATABASE.CITYDATA=\\\'SACRAMENTO\\\'
                                                                                 GROUP BY LEADINGCAUSESOFDEATH.YEARDATA, FREEZIPCODEDATABASE.CITYDATA, LEADINGCAUSESOFDEATH.CAUSES_OF_DEATH
                                                                                 ORDER BY FREEZIPCODEDATABASE.CITYDATA;"
                                                                                 ')), httpheader=c(DB='jdbc:oracle:thin:@sayonara.microlab.cs.utexas.edu:1521:orcl', USER='C##cs329e_UTEid', PASS='orcl_UTEid', 
                                                                                                   MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON'), verbose = TRUE)))
  })
  
  output$distPlot2 <- renderPlot(height=1000, width=2000, {
    plot1 <- ggplot() + 
      coord_cartesian() + 
      scale_x_discrete() +
      scale_y_continuous() +
      facet_wrap(~LEADINGCAUSESOFDEATH.CAUSES_OF_DEATH, ncol=1) +
      labs(title='Leading Cause Of Death For Major CA Cities, ') +
      labs(x=paste("Number Of Deaths"), y=paste("Causes Of Death")) +
      layer(data=df2(), 
            mapping=aes(x=SUM_COUNT, y=LEADINGCAUSESOFDEATH.CAUSES_OF_DEATH), 
            stat="identity", 
            stat_params=list(), 
            geom="bar",
            geom_params=list(colour="blue"), 
            position=position_identity()
      ) + coord_flip() +
      layer(data=df2(), 
            mapping=aes(x=SUM_COUNT, y=LEADINGCAUSESOFDEATH.CAUSES_OF_DEATH, label=SUM_COUNT), 
            stat="identity", 
            stat_params=list(), 
            geom="text",
            geom_params=list(colour="black", hjust=-1), 
            position=position_identity()
      )
    plot1
  })
  
})
