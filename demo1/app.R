####This app is for interactive map view of GSOD climate data###

##load library
library(shiny)
library(leaflet)
library(RESS)

##readin info for weather stations
geo       <- read.csv("geograph.csv")
latitude  <- geo[which(geo$CTRY == "US"),]$LAT
longitude <- geo[which(geo$CTRY == "US"),]$LON
ids       <- geo[which(geo$CTRY == "US"),]$STATIONNAME
unitdef   <- read.csv("unitdef.csv",
                      stringsAsFactors = FALSE)
row.names(unitdef) <- unitdef$var
###Shiny app starts here
shinyApp(
  ui <- fluidPage(   #nested R function HTML user interface
    fluidRow(
      h2("GSOD climate data explorer provided by ESSENTIA"),
      leafletMap(
        "map", "100%", 500,
        initialTileLayer = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
        initialTileLayerAttribution = HTML('Maps by <a href="http://www.mapbox.com/">Mapbox</a>'),
        options = list(
          center = c(37.45, -93.85),
          zoom = 4,
          maxBounds = list(list(17, -180), list(59, 180))))),
    fluidRow(verbatimTextOutput("Click_text")),
    h4("Data summary"),
    fluidRow(verbatimTextOutput("summary")),
    absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                  draggable = TRUE, top = 10, left = "auto", right = 5, bottom = 5,
                  width = 415, height = "auto",
                  
                  #h3("Scatter plot"),
                  h3(verbatimTextOutput("station")),
                  selectInput("X","choose a variable as X:",
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
                              selected = "YearMonDay"),
                  selectInput("Y","choose a variable as Y:",
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
                              selected = "Temperature_in_F (temp)"),
                  #submitButton("Update View"),
                  plotOutput("scatterplot")
    )
         ),

  server <- function(input, output, session){ #instructions
        map = createLeafletMap(session, 'map')
        session$onFlushed(once=T, function(){
           map$addCircleMarker(lat = latitude, lng = longitude, 
                               radius = 6, layerId=ids)
        })        

        observe({
          click <- input$map_marker_click
          if(is.null(click))
            return()
          text<-paste("Station: ", click$id, "Lat: ", click$lat, "Long: ", click$lng)
          map$clearPopups()
          map$showPopup( click$lat, click$lng, text)

        ####using click info to stream data using essentia###
         station <- geo[which(geo$LAT == click$lat & geo$LON == click$lng),]
         usaf  <- sprintf("%06d",station$USAF)
         wban  <- sprintf("%05d",station$WBAN)
         text2 <- paste0("Category (USAF-WBAN): ", usaf, "-", wban,sep='\n')
         rfile <- paste0("t",usaf,wban) ##consistent to bash
         nameid <- click$id
         output$Click_text<-renderText({
           text2
         })

        output$station<-renderText({
           sprintf("Station: %s scatterplot", click$id)
         })
       ###get unique usaf-wban, create category,stream data into ubdb
         shfile  <- paste0(usaf,"-",wban, sep='\n')
         write(shfile,"shfile")
         system("./multiline.sh shfile")
         
      ###pass ubdb data to R###
         for (i in seq(rfile)) {
           assign(sprintf("%s",rfile[i]),essQuery('ess exec',sprintf("aq_udb -exp climate:%s",rfile[i]),'--master'))
           if (i == 1) {assign(sprintf("%s",nameid),get(rfile[i]))}
           else {assign(sprintf("%s",nameid),rbind(get(nameid),get(rfile[i])))}
         }
         
         system("ess udbd stop")
         
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
         
        
        output$scatterplot <- renderPlot({
          data <- na.omit(subset(data,select=c(input$X,input$Y)))
          model <- lm(data[[input$Y]] ~ data[[input$X]])
          plot(data[[input$X]], data[[input$Y]], 
               xlab = unitdef[input$X,c("Fullname","unit")], 
               ylab = unitdef[input$Y,c("Fullname","unit")], 
               xlim = range(c(data[[input$X]],data[[input$X]])),
               ylim = range(c(data[[input$Y]],data[[input$Y]])),
               col  = "black")
          abline(model, col= "red", lwd = 2.5)
          legend("topleft",c(sprintf("y= %.4f + %.4f * x R-squared: %.4f", 
                                     model$coef[1],model$coef[2]
                                     , summary(model)$r.squared)))
        })
        })
  } 
)
