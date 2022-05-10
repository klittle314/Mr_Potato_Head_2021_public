get_db_connection <- function(dbname) {
  
  library(RPostgreSQL)
  
  drv <- dbDriver('PostgreSQL')
  
  dbConnect(drv,
            user = 'db_admin',
            password = 'pw',
            host = 'host url',
            dbname = dbname,
            port = 1000)
}


initialize_db <- function() {
  
  confirm <- ''
  
  while (confirm != 'y' && confirm != 'n') {
    confirm <- readline(prompt = 'WARNING: This will drop ALL data in the database, and re-initialize an empty table structure. Do you want to proceed? (y/n): ')
  }
  
  if (confirm == 'y') {
    
    db_con_init <- get_db_connection(dbname = 'postgres')
    
    drop <- try({
      dbGetQuery(db_con_init, 'DROP DATABASE mr_potato_head;')
    })
    
    dbGetQuery(db_con_init, 'CREATE DATABASE mr_potato_head;')
    dbDisconnect(db_con_init)
  
    db_con_main <- get_db_connection(dbname = 'mr_potato_head')
    
    dbGetQuery(db_con_main,
              "CREATE TABLE project_table (
              project_id     SERIAL PRIMARY KEY,
              project_name   VARCHAR(100) NOT NULL,
              date           DATE DEFAULT CURRENT_DATE,
               
              UNIQUE(project_name));")
    
    dbGetQuery(db_con_main,
              "CREATE TABLE team_table (
              team_id       SERIAL PRIMARY KEY,
              team_name     VARCHAR(100) NOT NULL,
              
              UNIQUE(team_name));")
    
    dbGetQuery(db_con_main,
              "CREATE TABLE project_team_xref (
              project_id   INT NOT NULL,
              team_id      INT NOT NULL,
  
              UNIQUE(project_id, team_id),
               
              CONSTRAINT fk_project_team_xref_project_id
               FOREIGN KEY (project_id) 
               REFERENCES project_table(project_id),
               
               CONSTRAINT fk_project_team_xref_team_id
               FOREIGN KEY (team_id) 
               REFERENCES team_table(team_id));")
    
    dbGetQuery(db_con_main,
              "CREATE TABLE measure_table (
              measure_id       SERIAL PRIMARY KEY,
              measure_name     VARCHAR(100) NOT NULL,
              measure_units    VARCHAR(100) NOT NULL,
               
              UNIQUE(measure_name, measure_units));")
    
    dbGetQuery(db_con_main,
              "CREATE TABLE data_table (
              data_id         SERIAL PRIMARY KEY,
              team_id         INT NOT NULL,
              measure_id      INT NOT NULL,
              test_cycle      INT NOT NULL,
              meas_value      NUMERIC,
               
              CONSTRAINT fk_data_table_team_id
               FOREIGN KEY (team_id)
               REFERENCES team_table(team_id),
               
              CONSTRAINT fk_data_table_measure_id
               FOREIGN KEY (measure_id)
               REFERENCES measure_table(measure_id));")
    
    dbGetQuery(db_con_main,
              "CREATE TABLE note_table (
               team_id     INT NOT NULL,
               measure_id  INT NOT NULL,
               cycle       INT NOT NULL,
               note_text   VARCHAR(1000),
               
               CONSTRAINT fk_note_table_team_id
               FOREIGN KEY (team_id)
               REFERENCES team_table(team_id),
               
               CONSTRAINT fk_note_table_measure_id
               FOREIGN KEY (measure_id)
               REFERENCES measure_table(measure_id));")
    
    dbDisconnect(db_con_main)
  }
}

set_up_project <- function(
  project_name,
  team_names)
{
  if (missing(project_name) || project_name == '') {
    stop('Argument `project_name` is required and must be non-blank.')
  } 
  
  if (missing(team_names) || length(team_names) == 0) {
    stop('Argument `team_names` is required and must have length of at least 1')
  }
  
  set_up_project_db(
    project_name = project_name,
    team_names = team_names)
  
  set_up_project_excel(
    project_name = project_name,
    team_names = team_names)
}  

set_up_project_db <- function(
  project_name,
  team_names)
{
  db_con <- get_db_connection(dbname = 'mr_potato_head')
  
  # insert new project
  sql <- sprintf("INSERT INTO project_table (project_name) VALUES ('%s') ON CONFLICT DO NOTHING",
                 project_name)
  
  dbGetQuery(db_con, sql)
  
  # insert new teams
  sql <- sprintf("INSERT INTO team_table (team_name) VALUES %s ON CONFLICT DO NOTHING",
                 paste0(sprintf("('%s')", team_names), collapse=', '))
  
  dbGetQuery(db_con, sql)
  
  # insert project-team reference
  sql <- sprintf("INSERT INTO project_team_xref (project_id, team_id)
                  SELECT * 
                    FROM (
                      (SELECT project_id FROM project_table WHERE project_name = '%s') projects
                      LEFT JOIN (SELECT team_id FROM team_table WHERE team_name IN (%s)) teams ON 1 = 1)
                  ON CONFLICT DO NOTHING;",
                 project_name,
                 paste0(sprintf("'%s'", team_names), collapse = ', '))
  
  dbGetQuery(db_con, sql)
  
  dbDisconnect(db_con)
}

set_up_project_excel <- function(
  project_name,
  team_names)
{
  library(openxlsx)
  
  output_folder_confirmed <- FALSE
  
  output_folder <- paste0(getwd(), '/', project_name, '-', Sys.Date())
  
  while (!output_folder_confirmed) {
    
    message(paste0('Excel workbooks will be written to ', output_folder))
    
    confirm <- readline(prompt = 'Confirm by typing (y) and pressing enter, or enter different output folder:')
    
    output_folder_confirmed <- confirm == 'y'
    
    if (output_folder_confirmed) {
      create_result <- try(dir.create(output_folder))
      
      if ('try-error' %in% class(create_result)) {
        stop(' -- Output folder could not be created')
      }
    } else {
      
      output_folder <- confirm
    }
  }
  
  
  results <- lapply(team_names,
         FUN = function(team_name) {
           
           wb <- openxlsx::createWorkbook()
           
           addWorksheet(wb,
                        sheetName = 'ID')
           
           writeData(wb,
                     sheet = 'ID',
                     x = team_name,
                     startCol = 1,
                     startRow = 1)
           
           writeData(wb,
                     sheet = 'ID',
                     x = as.character(Sys.Date()),
                     startCol = 1,
                     startRow = 2)
           
           addWorksheet(wb,
                        sheetName = 'Data')
           
           data_headers <- c('Team_Name', 'Test_Cycle', 'Time', 'Accuracy', 'Note_Text')
           
           df_out <- data.frame(team_name, 0:10, rep(as.numeric(NA),11),rep(as.numeric(NA),11),rep(as.character(NA),11))
           
           names(df_out) <- data_headers
           
           setColWidths(wb, sheet = 'Data', cols = 1:5, widths = c(20,rep(12,3),15))
           
           writeData(wb,
                     sheet = 'Data',
                     x = df_out)
                     
           # for (header_i in seq_along(data_headers)) {
           #   
           #   writeData(wb,
           #             sheet = 'Data',
           #             x = data_headers[header_i],
           #             startCol = header_i,
           #             startRow = 1)
           # }
           style1 <- createStyle(wrapText = TRUE)
           
           addWorksheet(wb,
                        sheetName = 'PDSA_Table')
           
           table_headers <- c('PDSA Cycle #',
                              'Plan: What change will you test?',
                              'Plan: What question(s) are you trying to answer?',
                              'Plan: What do you predict will happen when you run the test? (at minimum, predict Time & Accuracy)',
                              'Do: What issue or unexpected events did you encounter?',
                              'Do: Compare predictions to actual data',
                              'Study: What did you learn in this test?  Did you answer your questions?',
                              'Act: Adapt? Adopt? Abandon?',
                              'Act: Did you get any new ideas to test? Build these into your next test cycle')
           
           df_table_out <- data.frame(matrix("",ncol=9, nrow = 10))
           
           df_table_out[1] <- c(1:10)
           
           names(df_table_out) <- table_headers
           
           addStyle(wb, sheet = 'PDSA_Table', style1, rows = 1:10, cols = 1:10, gridExpand = TRUE)
           
           setColWidths(wb, sheet = 'PDSA_Table', cols = 2:10, widths = 40)
           
           writeData(wb,
                     sheet = 'PDSA_Table',
                     x = df_table_out)
           
           message(' -- Writing workbook for ', team_name)
           
           saveWorkbook(wb, 
                        file = paste0(output_folder, '/', team_name, '.xlsx'),
                        overwrite = TRUE)
           
         })
}

