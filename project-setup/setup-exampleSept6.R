source('project-setup/functions.R')

# only run initialize_db once BEFORE adding any projects
# It will clear all contents of database and set up empty table structure
# initialize_db()

project_name <- 'Test Project Feb 2022'
team_names <- paste0('Test Team_Feb_2022 ', 1:2)

set_up_project(
  project_name = project_name,
  team_names = team_names)

