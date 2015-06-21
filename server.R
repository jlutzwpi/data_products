library(shiny)
library(caret)
library(randomForest)

#read in the data sets
setInternet2(use = TRUE)
train.url <- "https://d396qusza40orc.cloudfront.net/predmachlearn/pml-training.csv"
test.url <- "https://d396qusza40orc.cloudfront.net/predmachlearn/pml-testing.csv"
train.file.name <- "./pml-training.csv"
test.file.name <- "./pml-testing.csv"
if(!file.exists(train.file.name))
{
  download.file(train.url, train.file.name)
}
if(!file.exists(test.file.name))
{
  download.file(test.url, test.file.name)
}
training.data <- read.csv(train.file.name)
testing.data <- read.csv(test.file.name)

#clean the training data (19216 is the number of NAs in many columns, so just remove them)
training.data[training.data==""] <- NA
training.data <- training.data[,colSums(is.na(training.data))<19216]
drop.cols <- c("X","user_name","cvtd_timestamp", "raw_timestamp_part_1","raw_timestamp_part_2", "new_window", "num_window")
training.data <- training.data[,!(names(training.data) %in% drop.cols)]
training.data$classe <- factor(training.data$classe)
#clean testing data
testing.data[testing.data==""] <- NA
#get rid of NA columns
testing.data <- testing.data[,colSums(is.na(testing.data))<20]
testing.data <- testing.data[,!(names(testing.data) %in% drop.cols)]

#create training and testing data partitions
train.part <- createDataPartition(y=training.data$classe, p=0.75, list=FALSE)
training <- training.data[train.part,]
testing <- training.data[-train.part,]
set.seed(1000)

#training the data with 3 fold cross validation and Random Forest
fitControl <- trainControl(method = "cv", number = 3)
modelFit <- train(classe ~., data=training, trControl=fitControl, 
                  method="rf", tuneGrid = data.frame(mtry = 6), ntree=100)

predict.row <<- testing.data[1,]

#now that we have our model, use the input from below to create and observation, the predict
#that
# Define server logic required to display prediction
shinyServer(function(input, output) {
  
  #set the input to output to display in main panel
  output$oRollBelt <- renderText({input$rollBelt})
  output$oPitchBelt <- renderText({input$pitchBelt})
  output$oYawBelt <- renderText({input$yawBelt})
  output$oTotAccBelt <- renderText({input$totAccBelt})
  #kind of a hack, but didn't want user to enter all 52 data points
  #I just ask for the belt data, and fill in the rest from the first row of the testing data
  #predict.row
  #makeReactiveBinding("predict.row")
  #now we have the first row of testing data, replace the first columns of data with
  #the data from the web page
  mod.data <- reactive({
    predict.row$roll_belt <- as.numeric(input$rollBelt)
    predict.row$pitch_belt <- as.numeric(input$pitchBelt)
    predict.row$yaw_belt <- as.numeric(input$yawBelt)
    predict.row$total_accel_belt <<- as.numeric(input$totAccBelt)
    final.predict <- predict(modelFit,predict.row)
    cat(final.predict)
    txt <- list("A" = "A - Correct Form",
                "B" = "B - Throwing elbows to front",
                "C" = "C - Lifting dumbbell only halfway",
                "D" = "D - Lowering dumbbell only halfway",
                "E" = "E - Throwing hips to front")
    final.txt <- txt[final.predict]
  })
  
  #predict the lift based on the input data
  liftText <- "The classification of the lift based on your input data is: "
  #final.predict <<- mod.pred()
  pred.text <- eventReactive(input$goButton, {
    final.txt <- mod.data()
    paste(liftText, final.txt)
  })
  
  output$oPredict <- renderText({
    pred.text()
  })
})