
library(Rcpp)
library(ggplot2)
library(scales)
library(grid)
library(gridExtra)
library(gtable)
library(GGally)
library(plyr)
library(dplyr)
library(reshape2)
library(stats)
library(tidyr)
library(shiny)
library(DT)
library(openxlsx)
library(zoo)
library(shinyBS)
library(RODBC)
library(stringi)
library(cowplot)
library(googledrive)
library(googlesheets4)
library(readxl)

#just need to read files that are world-readable.   Have to get token otherwise.

gs4_deauth()

drive_deauth()

source("project-setup/functions.R")
source("helper.R")

#create db connection

db_con <- get_db_connection(dbname = 'mr_potato_head')

#set project ID here

project_id <- 2

df_team_project_query <- sprintf("SELECT TT.team_id AS team_id,
                                  TT.team_name FROM team_table AS TT
                                  INNER JOIN project_team_xref AS TX
                                  ON TT.team_id = TX.team_id and TX.project_id = %d",
                                 project_id)

df_teams <- dbGetQuery(db_con,df_team_project_query)

dbDisconnect(db_con)


#Read in tables using Google Sheet method



#get URL of the folder containing the files of interest
folder_path3 <- "https://drive.google.com/drive/folders/1fERf_rrL3JHJmmUwqSRQAx1zcTjH7GNk"

# folder_path1 <- "https://drive.google.com/drive/folders/1kFit2aJ6SH5CXz4aeQoZ2D-FxCui_h2f?usp=sharing"
# 
# folder_path2 <- "https://drive.google.com/drive/folders/1kFit2aJ6SH5CXz4aeQoZ2D-FxCui_h2f"

#xlsx_files <- drive_ls(folder_path3, type = "xlsx")

sheet_files <- drive_ls(folder_path3, type = "spreadsheet")


df_use <- bind_rows(lapply(1:nrow(sheet_files),get_df, type1= "GoogleSheets",file_list = sheet_files),.id = "team_id") 


