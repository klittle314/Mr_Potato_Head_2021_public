#function to download and read in a team's Mr PH data
get_df <- function(index,file_list,type1){
  f1 <- file_list
  path1 <- paste0("data_test/",f1$name[index])
  file_id <- f1$id[index]
  if(type1 == "Excel"){
    drive_download(file= file_id, path = path1, overwrite=TRUE )
    df_out <- read_excel(path1, 
                         sheet = "Data")
  } else if(type1 == "GoogleSheets") {
    df_out <- read_sheet(file_id, 
                         sheet = "Data")
  }
  
  df_out <- df_out  %>% drop_na(c(Time,Accuracy))
  
}




#function to plot the Mr PH data across teams
plot_maker <- function(data_frame,yvar,title1,size1 = 3.0) {
  if(yvar == "Time"){
    title1 <- "Time (seconds)"
    
  } else title1 <- "Accuracy"
  
  p1 <- ggplot(data=data_frame,aes(x=Test_Cycle,y=!!sym(yvar)))+
    theme_bw()+
    geom_point(size=size1)+
    geom_line()+
    labs(title = title1,
         x = "",
         y ="")+
    ggtitle(title1)+
    theme(plot.title=element_text(size=rel(2.0)))+
    theme(axis.text.y=element_text(size=rel(2.0)))+
    theme(axis.text.x=element_text(size=rel(2.0)))+
    #theme(axis.title.y =element_text(size=rel(1.75), angle = 0))+
    # scale_x_continuous(breaks=c(1:max(df10$Cycle)))+
    facet_wrap(~Team_Name)+
    theme(strip.text=element_text(size=rel(1.25)))+
    coord_cartesian(xlim=c(0,10))+ scale_x_continuous(breaks=seq(0,10,2))
  
  if(yvar == "Accuracy"){
    p1 <- p1 + ylim(1,3)+xlab("Cycle")+ theme(axis.title.x =element_text(size=rel(2.0)))
  }
  
  return(p1)
}