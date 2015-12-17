library(shiny)

shinyUI(
  ##use a fluid bootstrap layout
  fluidPage(
    titlePanel('GSOD Climate data  analysis'),
    sidebarLayout(
    sidebarPanel(
      selectInput("datasetA", "choose a station A:",
                  choices = c("CARLISLE","LJUNGBY"),
                  selected= "CARLISLE"),
      selectInput("datasetB", "choose a station B:",
                  choices = c("CARLISLE","LJUNGBY"),
                  selected= "LJUNGBY"),
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
     # numericInput("obs", "Number of observations to view:", 5),
      submitButton("Update View")
      ),
      #show plot of the dataset
      mainPanel (
        plotOutput("map"),

        plotOutput("plot"),

        h4(textOutput("summarya")),
        verbatimTextOutput("summary1"), 
        
        h4(textOutput("summaryb")),
        verbatimTextOutput("summary2")
        

        
      )
    
  )
  
))
