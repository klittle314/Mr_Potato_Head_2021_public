
# ui.R
# Kevin Little, Ph.D. Informing Ecological Design, LLC  11 June 2015

library(shiny)

shinyUI(navbarPage("Mr Potato Head Data Display",
      tabPanel("Overview",
               img(src='iedlogo.png', align = "top"),
                   fluidRow(
                     column(3,
                            h3("Intro Text"),
                            helpText("Your task is to learn how to build a specific version of Mr. Potato Head in less than 20 seconds."),
                            br(),
                            helpText("With a few rounds of testing, can you learn enough to describe 
             work standards that define the desired appearance and meet the time requirement?"),
                            br(),
                            helpText("We will apply Plan-Do-Study-Act test cycles to learn how to build Mr Potato Head to look 'just like' the photo to the right.
    There is one defined process measure, the time it takes to build Mr Potato Head"),
                            br(),
                            helpText("Can you think of other measures that might help you understand the work?"),
                            br(),
                            helpText("In terms of standardized work, your task is to learn enough to outline work standards for building Mr Potato Head."),
                            br(),
                            helpText("You can use Plan-Do-Study-Act testing to inform standardized work:   how can you make it easy for people building Mr Potato Head see differences from the work standards?   
    How can you continue to make it easier to build Mr Potato head through revisions to your work standards?"),
                            br(),
                            helpText("This app and the accompanying exercise is derived from the Mr. Potato Head simulation developed by Dr. Dave Williams,
                        at TrueSimple, LLC."),
                            br(),
                            helpText("Visit www.truesimple.com for the Mr. Potato Head PDSA exercise.")
                            
                     ),
                     column(1),
                     column(8,
                            #h4("Mr PH picture"),
                            
                            #insert the picture
                            br(),
                            img(src = 'MrPH.png', alt = 'Mr Potato Head', style = 'width:500px;height=600px;')
                            )
                     )
      ),
                   

  # # Sidebar explanation
  # tabPanel("Overview",
  # 
  #   img(src='iedlogo.png', align = "top"),
  #  h4("Your task is to learn how to build a specific version of Mr. Potato Head in less than 20 seconds.  With a few rounds of testing, can you learn enough to describe 
  #            work standards that define the desired appearance and meet the time requirement?"),
  #   br(),
  #   h4("We will apply Plan-Do-Study-Act test cycles to learn how to build Mr Potato Head to look 'just like' the photo below.
  #   There is one defined process measure, the time it takes to build Mr Potato Head.  Can you think of other measures that might help you understand the work?
  #   In terms of standardized work, your task is to learn enough to outline work standards for building Mr Potato Head.   
  #   You can use Plan-Do-Study-Act testing to inform standardized work:   how can you make it easy for people building Mr Potato Head see differences from the work standards?   
  #   How can you continue to make it easier to build Mr Potato head through revisions to your work standards?"),
  #  
  #   img(src = 'MrPH.png', alt = 'Mr Potato Head', style = 'width:500px;height=600px;')
  #     
  #   ),

  tabPanel("Main Display",
           
           img(src='iedlogo.png', align = "top"),
           sidebarLayout(
             
             sidebarPanel(
               h3("App Purpose"),
               helpText("This app is designed to be used during the simulation if Time and Accuracy data from team tests",
                        "are using appropriate data files on Google Drive.  Visit www.truesimple.com for the Mr. Potato Head PDSA exercise."
               ),
               h3("For questions about this web app"),
               helpText("Kevin Little, Ph.D., Informing Ecological Design, LLC, klittle@iecodesign.com.  Last update 19 January 2022",
                        "code available on GitHub."),
               h3(""),
               
               h4("Click the Update! button to refresh the input data file"),
               uiOutput("update_button"),
               
               br(),
               br(),
              
               h4("Click to download a .png picture of this display"),
               br(),
               downloadButton('downloadMPlot', 'Download'),
               downloadButton('downloadMPlot_pdf', 'Download PDF')
               
             ),
             
             mainPanel(plotOutput("ResultsPlot")
                       
                       
           )
         )
      )
  
    )
  )
    