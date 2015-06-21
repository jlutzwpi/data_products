library(shiny)

# Coursera Developing Data Products Course Project
# Justin Lutz
# June 19, 2015

shinyUI(pageWithSidebar(
  
  # Application title
  headerPanel("Developing Data Products Course Project"),
  
  # Sidebar with controls to select Roll Value and other values to predict lift
  sidebarPanel(
    h4('This data is used to predict the biceps curl lifting motion based on motion
        data from wearable sensors on the participant.'),
    h4('Please enter the data below, then press Submit.'),
    selectInput("rollBelt", "Select a roll belt value:", 
                choices = c(123, 1.02, -5.92, 0.43)),
    
    numericInput("pitchBelt", "Enter a pitch belt value:", 27),
    numericInput("yawBelt", "Enter a yaw belt value:", -4.75),
    numericInput("totAccBelt", "Enter total belt acceleration:", 20, min=2, max=21, step=1),
    actionButton("goButton", "Submit"),
    
    h5('Note: Please be patient.  Large datasets are being downloaded and a computation-
        intensive calculation is being run.  The prediction might take up to 20 seconds
        to run.  Thanks!')
  ),
  
  # Show a summary of what the user entered plus the predicted value based on the input.
  mainPanel(
    
    h4('You entered the following data:'),
    verbatimTextOutput("oRollBelt"),
    verbatimTextOutput("oPitchBelt"),
    verbatimTextOutput("oYawBelt"),
    verbatimTextOutput("oTotAccBelt"),
    
    h4('This results in a predicted lifting motion of:'),
    verbatimTextOutput("oPredict"),
    
    h5('For more information on this topic, please see the Weight Lifting Exercises
        Dataset at:'),
    h5('http://groupware.les.inf.puc-rio.br/har#sbia_paper_section#ixzz3YRDLWxEV')
  )
))