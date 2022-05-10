
# server.R 
# 
#

library(shiny)

shinyServer(function(input, output) {
  
 values <- reactiveValues()
 
 values$df_use <- df_use
  
  
  
  
  output$update_button <- renderUI({
      
      click_message <- tags$h5("Click the Update! button to pull data from Google Drive")
      
      action_ui <- actionButton(
        inputId = "update_data_button", 
        label = "Update!", 
        class = NULL)
  })
 
  
  observeEvent(input$update_data_button, {
    values$df_use <- bind_rows(lapply(1:nrow(sheet_files),get_df, type1= "GoogleSheets",file_list = sheet_files),.id = "team_id") 
  }
               )
  
 
 #browser() 
  
  p_time <- reactive({
    inFile <- values$df_use
    size_dot <- 3
    if(is.null(inFile)) {
      #user has not yet uploaded a file yet
      return(NULL)
    } else {
        p_out <- plot_maker(data_frame = inFile,
                                  yvar = "Time",
                                  title1 = NULL,
                                  size1 = size_dot)
    }
  })
  
   p_accuracy <- reactive({
     inFile <- values$df_use
     size_dot <- 3
     if(is.null(inFile)) {
       #user has not yet uploaded a file yet
       return(NULL)
     } else { 
        p_out <- plot_maker(data_frame = inFile,
                            yvar = "Accuracy",
                            title1 = "Mr PH Test",
                            size1 = size_dot) 
     }
   })
  
   p_both <- reactive({
     inFile <- values$df_use
     if(is.null(inFile)) {
       #user has not yet uploaded a file yet
       return(NULL)
     } else { 
       title1 <- "Mr Potato Head Performance"
       # p_out <- grid.arrange(p_time(),
       #                       p_accuracy(),
       #                       top=textGrob(title1,gp=gpar(fontsize=16)),
       #                       ncol=1,
       #                       nrow=3,
       #                      widths=unit(width1,c("cm")),
       #                      heights=c(unit(height1,c("cm")),
       #                                unit(height1,c("cm")),
       #                                unit(3,c("cm")))
       #                                
       # )
       p_out <- grid.arrange(plot_grid(p_time(),p_accuracy(),ncol=1),top=textGrob(title1,gp=gpar(fontsize=20)))
     }
   })

  output$ResultsPlot <- renderPlot({
        print(p_both())
    
  },width=600,height=800)
 
  #suggestion https://groups.google.com/forum/#!topic/shiny-discuss/u7gwXc8_vyY by Patrick Renschler 2/26/14
  p_both2 = function(){
    inFile <- values$df_use
    if(is.null(inFile)) {
      #user has not yet uploaded a file yet
      return(NULL)
    } else { 
      title1 <- "input$text"   
      p_out <- grid.arrange(p_time(),p_accuracy(),top= textGrob(title1,
                                                                 gp=gpar(fontsize=16)))
    }
  }

  output$downloadDisplay <- downloadHandler(
#     filename = function() {
#       paste0(input$text,"_plot_",Sys.Date(),".png")},
    filename=paste0("Mr_Potato_Head_display_",Sys.Date(),".png"),
    content <- function(file) {
      png(file,width=600,height=800)
      p_both2()
      dev.off()},
    contentType = "image/png"
  )   
# }
#    })
})
