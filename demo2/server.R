library(shiny)
library(maps)
library(ggplot2)

CARLISLE  <- read.csv("CARLISLE.csv")
LJUNGBY   <- read.csv("LJUNGBY.csv")
geo       <- read.csv("geograph.csv")
unitdef   <- read.csv("unitdef.csv",
                       stringsAsFactors = FALSE)
row.names(unitdef) <- unitdef$var
map.world <- map_data(map = "world")


shinyServer(function(input, output) {
  datasetInputA <- reactive({
    switch(input$datasetA,
           "CARLISLE"   = CARLISLE,
            "LJUNGBY"   = LJUNGBY)
  })
    
  datasetInputB <- reactive({
    switch(input$datasetB,
           "CARLISLE" = CARLISLE,
           "LJUNGBY" = LJUNGBY)
  })

 output$map <- renderPlot({ 
  points <- geo[which(geo$STATIONNAME %in% c(input$datasetA,input$datasetB)),]
  LAT <- points$LAT
  LON <- points$LON
  p <- ggplot(map.world)
  p <- p + geom_polygon(aes(x=long, y=lat, group=group), fill=NA, color="grey50",alpha=1)
  p <- p + geom_point(data = points,aes(x = LON, y = LAT, color = STATIONNAME),size = 5)
  p <- p + coord_cartesian(xlim = c(-185, 185),ylim=c(-85,85))
  p <- p + scale_y_continuous(breaks = seq(-90,90,30))  
  p <- p + scale_x_continuous(breaks=seq(-180,180,60))
   plot(p)
})
    

  formulaText <- reactive({
    paste(input$Y, " ~ ", input$X)
  })
  formulaA <- reactive({
    paste("Summary ",input$datasetA)
  })
  formulaB <- reactive({
    paste("Summary ", input$datasetB)
  })
  
  output$summarya <- renderText({
    formulaA()
  })
  output$summaryb <- renderText({
    formulaB()
  })
  
  output$summary1 <- renderPrint({
    datasetA <- datasetInputA()
    datasetA$date <- paste0(datasetA$year,sprintf("%04d",datasetA$moda))
    datasetA$date <- as.Date(datasetA$date,"%Y %m %d")
#    summary(datasetA[,c("temp","dewp","slp","stp","visib","wdsp","mxspd","gust","max","min"                     ,"prcp","sndp")])
    summary(datasetA[,c(input$X,input$Y)])
    })
  
  output$summary2 <- renderPrint({
    datasetB <- datasetInputB()
    datasetB$date <- paste0(datasetB$year,sprintf("%04d",datasetB$moda))
    datasetB$date <- as.Date(datasetB$date,"%Y %m %d")
   # summary(datasetB[,c("temp","dewp","slp","stp","visib","wdsp","mxspd","gust","max","min"                     ,"prcp","sndp")])
   # summary(datasetA[,c(input$X,input$Y)])
    summary(datasetB[,c(input$X,input$Y)])
  })
  
  output$plot <- renderPlot({
    datasetA <- datasetInputA()
    datasetB <- datasetInputB()
    datasetA$date <- paste0(datasetA$year,sprintf("%04d",datasetA$moda))
    datasetB$date <- paste0(datasetB$year,sprintf("%04d",datasetB$moda))
    datasetA$date <- as.Date(datasetA$date,"%Y %m %d")
    datasetB$date <- as.Date(datasetB$date,"%Y %m %d")
    datasetA <- na.omit(subset(datasetA,select=c(input$X,input$Y)))
    datasetB <- na.omit(subset(datasetB,select=c(input$X,input$Y)))
    modelA <- lm(datasetA[[input$Y]] ~ datasetA[[input$X]])
    modelB <- lm(datasetB[[input$Y]] ~ datasetB[[input$X]])
    plot(datasetA[[input$X]], datasetA[[input$Y]], 
         xlab = unitdef[input$X,c("Fullname","unit")], 
         ylab = unitdef[input$Y,c("Fullname","unit")], 
         xlim = range(c(datasetA[[input$X]],datasetB[[input$X]])),
         ylim = range(c(datasetA[[input$Y]],datasetB[[input$Y]])),
         col  = "red",main = formulaText())
    abline(modelA, col= "red", lwd = 2.5)
    par(new=TRUE)
    plot(datasetB[[input$X]], datasetB[[input$Y]], 
         xlab ="", 
         ylab = "",
         col  = "black", 
         main = "",
         xlim = range(c(datasetA[[input$X]],datasetB[[input$X]])),
         ylim = range(c(datasetA[[input$Y]],datasetB[[input$Y]]))                 )
    abline(modelB,col = "black",lwd = 2.5)
    legend("topleft",c(sprintf("%s : y= %.4f + %.4f * x R-squared: %.4f"           , input$datasetA,modelA$coef[1],modelA$coef[2]
           , summary(modelA)$r.squared)
           , sprintf("%s : y= %.4f + %.4f * x R-squared: %.4f"
           , input$datasetB,modelB$coef[1],modelB$coef[2]
           , summary(modelB)$r.squared)),lty=c(1,1),col=c("red","black")          )
  
  })
  
}
  )
