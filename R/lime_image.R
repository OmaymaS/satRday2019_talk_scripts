library(keras)
library(lime)
library(magick)
library(here)

## image processing function
image_prep <- function(x) {
  arrays <- lapply(x, function(path) {
    img <- image_load(path, target_size = c(224,224))
    x <- image_to_array(img)
    x <- array_reshape(x, c(1, dim(x)))
    x <- imagenet_preprocess_input(x)
  })
  do.call(abind::abind, c(arrays, list(along = 1)))
}

## create model from pre-trained weights
model <- application_vgg16(
  # weights = "imagenet",
  weights = here("pre_trained/vgg16_weights_tf_dim_ordering_tf_kernels.h5"),
  include_top = TRUE
)

## read image
img <- image_read(here("data/test_img/3817.jpg"))  # 3817, 159, 4156
img_path <- file.path(tempdir(), '3817.jpg')
image_write(img, img_path)
# plot(as.raster(img))

## get model label
model_labels <- readRDS(system.file('extdata', 'imagenet_labels.rds', package = 'lime'))

## create explainer
explainer <- lime(img_path, as_classifier(model, model_labels), image_prep)

## explain new instance
explanation <- explain(img_path, explainer, n_labels = 1, n_features = 20)

## plot feature weights
explanation %>%
  ggplot(aes(x = feature_weight)) +
  geom_density()

## plot explanation
plot_image_explanation(explanation, display = 'block', threshold  = 0.015)

