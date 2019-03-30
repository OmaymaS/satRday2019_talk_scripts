set.seed(5658)

## load libraries
library(caret)
library(lime)

## partition the data
intrain <- createDataPartition(y = iris$Species,  p = 0.8, list = F)

## create train and test data
train_data <- iris[intrain, ]
test_data <- iris[-intrain, ]

# Create Random Forest model on iris data
model <- train(x = train_data[, 1:4], y = train_data[, 5],  method = 'rf')

## Create an explainer object
explainer <- lime(train_data, model)

## explain new observations in test data
explanation <- explain(test_data[, 1:4],
                       explainer, n_labels = 1, n_features = 4)
