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
  
  OPKPI_Bad_Max_value <- reactive({input$OPKPI1})     
  OPKPI_Good_Min_value <- reactive({input$OPKPI2})
  rv <- reactiveValues(alpha = 0.50)
  observeEvent(input$lighter, { rv$alpha <- 0.25 })
  observeEvent(input$darker, { rv$alpha <- 0.55 })
  
  df1 <- eventReactive(input$clicksHosp, {data.frame(fromJSON(getURL(URLencode(gsub("\n", " ", 'skipper.cs.utexas.edu:5001/rest/native/?query=
                                                                                    "SELECT COUNTYNAME, ROUND(SUM(INCAMT),1) AS OPMARGIN, TYPEOFCONTROL,
                                                                                    case
                                                                                    when ((ROUND(SUM(INCAMT),1)) >= "p2") THEN \\\'01 Good\\\'
                                                                                    when ((ROUND(SUM(INCAMT),1)) >= "p1") THEN \\\'02 Neutral\\\'
                                                                                    else \\\'03 Bad\\\'
                                                                                    end OPKPI
                                                                                    FROM HOSPITAL_PROFITABILITY
                                                                                    WHERE INCOMESTATEMENTITEM=\\\'OPERATING_MARGIN\\\' AND YEAR=2011 AND TYPEOFCONTROL != \\\'(null)\\\'
                                                                                    GROUP BY COUNTYNAME, TYPEOFCONTROL
                                                                                    ORDER BY COUNTYNAME, TYPEOFCONTROL;"
                                                                                    ')), httpheader=c(DB='jdbc:oracle:thin:@sayonara.microlab.cs.utexas.edu:1521:orcl', USER='C##cs329e_jzp78', PASS='orcl_jzp78', 
                                                                                                      MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON', p1=OPKPI_Bad_Max_value(), p2=OPKPI_Good_Min_value()), verbose = TRUE)))
  })
  
  output$distPlot1 <- renderPlot({             
    plot <- ggplot() + 
      coord_cartesian() + 
      scale_x_discrete() +
      scale_y_discrete() +
      labs(title=isolate(input$title)) +
      labs(x=paste("OPERATING MARGIN"), y=paste("COUNTY")) +
      layer(data=df1(), 
            mapping=aes(x=TYPEOFCONTROL, y=COUNTYNAME, label=OPMARGIN), 
            stat="identity", 
            stat_params=list(), 
            geom="text",
            geom_params=list(colour="black"), 
            position=position_identity()
      ) +
      layer(data=df1(), 
            mapping=aes(x=TYPEOFCONTROL, y=COUNTYNAME, fill=OPKPI), 
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
  
  
})
