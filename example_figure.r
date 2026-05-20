library(CAST)
library(terra)
library(sf)
library(dplyr)
library(ggplot2)

data(splotdata)

predictors <- rast("data/predictors.tif")
training_data <- splotdata |> st_drop_geometry() # reference samples without coordinates
modeldomain <- st_read("data/modeldomain.gpkg", quiet = TRUE)



predictor_names <- names(predictors)
response_name <- "Species_richness"

# define color palette
Okabe_Ito <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#CC79A7") 

p = predictors[[c("bio_4", "bio_12", "bio_8", "elev")]]
names(p) = c("Temp. Seasonality", "Annual Precipitation", "Temp. wettest quarter", "Elevation")

set.seed(6502)
rfmodel_rcv <- caret::train(x = training_data |> select(all_of(predictor_names)),
                            y = training_data |> pull(response_name),
                            method = "ranger",
                            num.trees = 100,
                            trControl = trainControl(method = "cv",
                                                     savePredictions = TRUE))

prediction_rcv <- predict(predictors, rfmodel_rcv, na.rm = TRUE)