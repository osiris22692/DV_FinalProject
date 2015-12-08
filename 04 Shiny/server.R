# server.R
require("jsonlite")
require("RCurl")
require(ggplot2)
require(dplyr)
require(shiny)
require(shinydashboard)
require(leaflet)
require(DT)
require("dplyr")
require("tidyr")
shinyServer(function(input, output) {
  KPI_Low_Max_value <- reactive({input$KPI1})     
  KPI_Medium_Max_value <- reactive({input$KPI2})
  rv <- reactiveValues(alpha = 0.50)
  observeEvent(input$light, { rv$alpha <- 0.50 })
  observeEvent(input$dark, { rv$alpha <- 0.75 })
  
  df1 <- eventReactive(input$clicks1, {df_Data2 <- data.frame(fromJSON(getURL(URLencode('skipper.cs.utexas.edu:5001/rest/native/?query="Select * from HOUSEHOLD_POWER_CONSUMPTION"'),httpheader=c(DB='jdbc:oracle:thin:@sayonara.microlab.cs.utexas.edu:1521:orcl', USER='C##cs329e_jzp78', PASS='orcl_jzp78', MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON'), verbose = TRUE), ))
  df_Data2 <- df_Data2 %>% mutate(DayMonthYear = strsplit(as.character(DateFull), "/")) 
  df_Data2 <- df_Data2 %>% separate(DayMonthYear, c("c", "DAY", "MONTH", "YEAR"))
  df_Data2 <- df_Data2 %>% mutate(HourMinuteSecond = strsplit(as.character(df_Data2$TimeFull), ";")) 
  df_Data2 <- df_Data2 %>% separate(HourMinuteSecond, c("d", "Hour", "Minute", "Second"))
  df_Data2 <- df_Data2 %>% mutate(ActiveEnergyConsumedPerMinute = GLOBALACTIVEPOWER * 1000/60 - SUBMETERING1 - SUBMETERING2 - SUBMETERING3)
  df_Data2 <- df_Data2 %>% group_by(Hour, MONTH) %>% summarise(AvgActiveEnergyConsumedPerMinute = mean(ActiveEnergyConsumedPerMinute))
  df_Data2 <- df_Data2 %>% mutate(KPI = AvgActiveEnergyConsumedPerMinute > KPI_Low_Max_value)
  })
  
  output$distPlot1 <- renderPlot({             
    plot <- ggplot() + 
      coord_cartesian() + 
      scale_x_discrete() +
      scale_y_discrete() +
      #facet_grid(PCLASS~SURVIVED, labeller=label_both) +
      labs(x="Month", y="Hour") +
      layer(data=df1(), 
            mapping=aes(x=MONTH, y=Hour, label=AvgActiveEnergyConsumedPerMinute), 
            stat="identity", 
            stat_params=list(), 
            geom="text",
            geom_params=list(colour="black"), 
            #position=position_identity()
            position=position_identity()
      ) +
      layer(data=df1(), 
            mapping=aes(x=MONTH, y=Hour, fill=KPI), 
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
  
  
  
  df2 <- eventReactive(input$clicks3, {df_mainData <- data.frame(fromJSON(getURL(URLencode('skipper.cs.utexas.edu:5001/rest/native/?query="Select DATE_TIME, GLOBALACTIVEPOWER, GLOBALREACTIVEPOWER, VOLTAGE, GLOBALINTENSITY, SUBMETERING1, SUBMETERING2, SUBMETERING3, GLOBALACTIVEPOWER * 1000/60 - SUBMETERING1 - SUBMETERING2 - SUBMETERING3 as ActiveEnergyConsumedPerMinute from HOUSEHOLD_POWER_CONSUMPTION"'),httpheader=c(DB='jdbc:oracle:thin:@sayonara.microlab.cs.utexas.edu:1521:orcl', USER='C##cs329e_jzp78', PASS='orcl_jzp78', MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON'), verbose = TRUE), ))
  })
  output$distPlot2 <- renderPlot({             
    plot <- ggplot() + 
      coord_cartesian() + 
      scale_x_continuous() +
      scale_y_continuous() +
      #facet_wrap(~SURVIVED) +
      #facet_grid(.~SURVIVED, labeller=label_both) + # Same as facet_wrap but with a label.
      #facet_grid(PCLASS~SURVIVED, labeller=label_both) +
      labs(x="Active Energy Consumer Per Minute", y="Global Active Power") +
      layer(data=df2(), 
            mapping=aes(x=as.numeric(as.character(ACTIVEENERGYCONSUMEDPERMINUTE)), y=as.numeric(as.character(GLOBALACTIVEPOWER)), color=VOLTAGE), 
            stat="identity", 
            stat_params=list(), 
            geom="point",
            geom_params=list(), 
            #position=position_identity()
            position=position_jitter(width=0.3, height=0)
      )
    plot
  })
  
  # Begin code for Third Tab:
  df3 <- eventReactive(input$clicks1, {df_Data3 <- data.frame(fromJSON(getURL(URLencode('skipper.cs.utexas.edu:5001/rest/native/?query="Select * from HOUSEHOLD_POWER_CONSUMPTION"'),httpheader=c(DB='jdbc:oracle:thin:@sayonara.microlab.cs.utexas.edu:1521:orcl', USER='C##cs329e_jzp78', PASS='orcl_jzp78', MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON'), verbose = TRUE), ))
  df_Data3 <- df_Data3 %>% mutate(DayMonthYear = strsplit(as.character(DateFull), "/")) 
  df_Data3 <- df_Data3 %>% separate(DayMonthYear, c("c", "DAY", "MONTH", "YEAR"))
  df_Data3 <- df_Data3 %>% group_by(YEAR) %>% summarise(AVGGLOBALACTIVEPOWER = mean(GLOBALACTIVEPOWER))
  })
  
  output$distPlot3 <- renderPlot(height=1000, width=2000, {
    plot3 <- ggplot() + 
      coord_cartesian() + 
      scale_x_discrete() +
      scale_y_continuous() +
      #facet_wrap(~CLARITY, ncol=1) +
      labs(x=paste("Region Sales"), y=paste("Sum of Sales")) +
      layer(data=df3(), 
            mapping=aes(x=YEAR, y=AVGGLOBALACTIVEPOWER), 
            stat="identity", 
            stat_params=list(), 
            geom="bar",
            geom_params=list(colour="blue"), 
            position=position_identity()
      )
    plot3
  })
}) 