library(tidyverse)
library(caret)
library(iml)

## load data
load(here::here("data/bike_data/bike.RData"))

## particition data
intrain <- createDataPartition(y = bike$cnt, p = 0.9, list = F)

## create train and test data
train_data <- bike[intrain, ] 
test_data <- bike[-intrain, ] 

train_x <-  select(train_data, -cnt)
test_x <- select(test_data, -cnt)

## train model
model <- train(x = train_x, y = train_data$cnt,
               method = 'rf', ntree = 30, maximise = FALSE)


## define instance to explain
new_istance <- test_x[16,]

## calculate average, actual prediction and the difference
avg_prediction = mean(predict(model))
actual_prediction = predict(model, newdata = new_istance)
diff_prediction <-  actual_prediction - avg_prediction


## create predictor
predictor = Predictor$new(model, data = train_x)

## calculate shapley values for the new instance
shapley_values <-  Shapley$new(predictor, x.interest = new_istance)

## plot shapley values
plot(shapley_values)