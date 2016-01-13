####This app is for interactive map  of GSOD climate data#######
### using R and essentia########################################

setwd('/home/essentia/ShinyApps/Democache/')
##load library
library(shiny)
library(leaflet)
library(RESS)

##readin info for weather stations

geo <- read.csv("geoUS.csv")
latitude  <- geo$LAT
longitude <- geo$LON
ids       <- geo$STATIONNAME
unitdef   <- read.csv("unitdef.csv",stringsAsFactors = FALSE)
row.names(unitdef) <- unitdef$var

###Shiny app starts here
shinyApp(
  ui <- fluidPage(   
 
    titlePanel("US GSOD climate explorer provided by ESSENTIA"),

    fluidRow(
      column(5,
         h6( a("AuriQ ESSENTIA Doc",target="_blank", href="http://www.auriq.com/documentation/")),
         h6( a("GSOD AWS open data Doc",target="_blank", 
               href="https://aws.amazon.com/datasets/daily-global-weather-measurements-1929-2009-ncdc-gsod/")),
         hr(),
         tags$div(tags$b("Step 1: Choose a station (click a blue circle) from MAP")),
         verbatimTextOutput("station"),
         tags$div(tags$b("Step 2: Click Go to retrieve data for the selected station")),
         actionButton("retrieveButton","Go!",class="btn btn-primary",style='height:34px;color:white;font-size: 115%')),
          
      column(7, 
        leafletMap(
         "map", "100%", 250,
         initialTileLayer = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
         options = list(
            center = c(40., -100.),
            zoom = 3,
            maxBounds = list(list(10, -180), list(70, 180)))))),
    
   tabsetPanel( 
     tabPanel(tags$b("Step 3: Data view and download"),
              column(2,downloadButton('downloadData','Download',class="btn btn-primary")),
              column(4,offset = 1, tags$b(verbatimTextOutput("station1"))),
              dataTableOutput("table")),
    tabPanel(tags$b("Step 4: Data summary"),
             verbatimTextOutput("summary")),
    
    tabPanel(
       tags$b("Step 5: Interactive scatter plot"),
        fluidRow(
         column(2," "),
         column(5, selectInput("X","choose a variable as X:",
                               choices = c("YearMonDay"  = "date",
                                           "Temperature_in_F (temp)" = "temp",
                                           "Dewp point_in_F (dewp)"  = "dewp",
                                           "Sea_level_pressure_in_mb (slp)" = "slp",
                                           "Station_Pressure_in_mb (stp)" = "stp",
                                           "Visibility_in_mi (visib)" = "visib",
                                           "Wind_in_knots (wdsp)" = "wdsp",
                                           "Max_wind_in_knots (mxspd)" = "mxspd",
                                           "Max_gust_in_knots (gust)" = "gust",
                                           "Max_temperature_in_F (max)" = "max",
                                           "Min_temperature_in_F (min)" = "min",
                                           "Precipiation_in_inch (prcp)" = "prcp",
                                           "Snow_depth_in_inch (sndp)" = "sndp"),
                               selected = "YearMonDay")),
         column(5, selectInput("Y","choose a variable as Y:",
                               choices = c(
                                           "Temperature_in_F (temp)" = "temp",
                                           "Dewp point_in_F (dewp)"  = "dewp",
                                           "Sea_level_pressure_in_mb (slp)" = "slp",
                                           "Station_Pressure_in_mb (stp)" = "stp",
                                           "Visibility_in_mi (visib)" = "visib",
                                           "Wind_in_knots (wdsp)" = "wdsp",
                                           "Max_wind_in_knots (mxspd)" = "mxspd",
                                           "Max_gust_in_knots (gust)" = "gust",
                                           "Max_temperature_in_F (max)" = "max",
                                           "Min_temperature_in_F (min)" = "min",
                                           "Precipiation_in_inch (prcp)" = "prcp",
                                           "Snow_depth_in_inch (sndp)" = "sndp"),
                               selected = "Temperature_in_F (temp)"))),
        
       plotOutput("scatterplot", click = "plot_click"),
       verbatimTextOutput("info")
        ),
    
    conditionalPanel(condition="$('html').hasClass('shiny-busy')",
                     absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                   draggable = FALSE, top = 10, left = "auto", right = 3, bottom = 3,
                                   width = 2000, height = 1000,
                                   style = "opacity: 0.9; background-color: white;border:white"
                     )
    ),
    
    conditionalPanel(condition="$('html').hasClass('shiny-busy')",
                     absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                   draggable = FALSE, top = 200, left = "auto", right = 530, bottom = 60,
                                   width = 110, height = 120,
                                   h4("Retrieving...", style = "color:grey"),
                                   textOutput("a"),
                                   img(src="ajax_loader_blue_256.gif", height = 100, width = 100),
                                   style = "opacity: 0.99;border:white"
                     )
    )
    
   )        
  ),
  
  server <- function(input, output, session){ #instructions
    map = createLeafletMap(session, 'map')
    session$onFlushed(once=T, function(){
      map$addCircleMarker(lat = latitude, lng = longitude, 
                          radius = 3, layerId=ids)
    }) 
    
    observe({
      click1 <- input$map_marker_click
      if(is.null(click1))
        return()
      text<-paste("Station: ", click1$id, "Lat: ", click1$lat, "Long: ", click1$lng)
      map$clearPopups()
      map$showPopup(click1$lat, click1$lng, text)
      
      output$station <- renderText({
             click1$id
         })
      
    })
    
    ##########create DB and tables######
    ##for the very first time of this app, execute createdb.sh and 
    ##comment out the "ess udbd restart", thereafter comment out
    ##createdb.sh, and use "ess udbd restart"
    # system("./createdb.sh")
    system("ess udbd restart")
    
   observe({
      input$retrieveButton
      ####using click info to stream data with essentia###
      isolate({
        click <- input$map_marker_click
        if(is.null(click))
          return()
        
        station <- geo[which(geo$LAT == click$lat & geo$LON == click$lng),]
        usaf  <- sprintf("%06d",station$USAF)
        wban  <- sprintf("%05d",station$WBAN)
        text2 <- paste0("Category (USAF-WBAN): ", usaf, "-", wban,sep='\n')
        rfile <- paste0("t",usaf,wban) ##consistent to bash
        nameid <- click$id
        
        
        output$Click_text<-renderText({
          text2
        })
        
        output$station1 <-renderText({
          sprintf("Station: %s", click$id)
        })
        
        ###get unique usaf-wban, create category,stream data into ubdb
        shfile  <- paste0(usaf,"-",wban, sep='\n')
        write(shfile,"shfile")
        
        system("./multitables.sh shfile")
        
        ###pass ubdb data to R###
        for (i in seq(rfile)) {
          rfile[i] <- paste0("table",i)
          assign(sprintf("%s",rfile[i]),essQuery('ess exec',sprintf("aq_udb -exp climate:%s",rfile[i]),'--master'))
          if (i == 1) {assign(sprintf("%s",nameid),get(rfile[i]))}
          else {assign(sprintf("%s",nameid),rbind(get(nameid),get(rfile[i])))}
        }
        
        
        data <- get(nameid)[-1] ##get rid of artifical skey
        
        ###process data
        colnames(data) <- c("stn","wban","year","moda","temp","Tobs","dewp","Dobs","slp","Sobs","stp","Pobs","visib","Vobs","wdsp","Wobs","mxspd",
                            "gust","max","xf","min","nf","prcp","pf","sndp","frshtt")
        
        data$frshtt <- sprintf("%06d",data$frshtt)
        data$date <- paste0(data$year,sprintf("%04d",data$moda))
        data$date <- as.Date(data$date,"%Y %m %d")
        data[data==99.99] <- NA
        data[data==999.9] <- NA
        data[data==9999.9] <- NA
        feature.names <- c("date","temp","dewp","slp","stp","visib","wdsp","mxspd",
                           "gust","max","min","prcp","sndp")
        
        
        output$summary<-renderPrint({
          summary(data[,feature.names])    
        })
        
        output$table <- renderDataTable(data[,feature.names],options=list(pageLength = 10,searching=FALSE))
        
        output$downloadData <- downloadHandler(
          filename <- function () { paste(sprintf("Station-%s", click$id),"csv",sep = ".")},
          content <- function(file) {
            write.table(data, file, sep = ",", row.names = FALSE)
          }
        )
     
        
         output$scatterplot <- renderPlot({
          
          data <- na.omit(subset(data,select=c(input$X,input$Y)))
          model <- lm(data[[input$Y]] ~ data[[input$X]])
          plot(data[[input$X]], data[[input$Y]], 
               xlab = unitdef[input$X,c("Fullname","unit")], 
               ylab = unitdef[input$Y,c("Fullname","unit")], 
               xlim = range(c(data[[input$X]],data[[input$X]])),
               ylim = range(c(data[[input$Y]],data[[input$Y]])),
               col  = "black",cex = 0.75,col.main="black",font.main=1,cex.main=0.95,
               main=c(sprintf("%s: y= %.4f + %.4f * x R-squared: %.4f", 
                              click$id,  model$coef[1],model$coef[2]
                              , summary(model)$r.squared)))
          abline(model, col= "blue", lwd = 2.5, lty=2)
          
          output$info <- renderText({
            inputx <- input$plot_click$x
            if (input$X == "date") { 
              inputx <- as.Date(as.numeric(inputx), origin = "1970-01-01")
              sprintf("%s = %s %s, %s = %.2f %s",unitdef[input$X,c("Fullname")],inputx,unitdef[input$X,c("unit")],
                  unitdef[input$Y,c("Fullname")],input$plot_click$y,unitdef[input$Y,c("unit")])
            } else {
              sprintf("%s = %.2f %s, %s = %.2f %s",unitdef[input$X,c("Fullname")],inputx,unitdef[input$X,c("unit")],
                      unitdef[input$Y,c("Fullname")],input$plot_click$y,unitdef[input$Y,c("unit")])
              }
          })
        })
      
     })
      
     
    })
    time_consuming <- reactive({
      if(input$retrieveButton>0) Sys.sleep(1)
      return(input$retrieveButton)
    })
    
  output$a <- renderText(sprintf("%i",time_consuming()))
    
  } 
)
