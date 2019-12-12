library(dash)
library(dashCoreComponents)
library(dashHtmlComponents)
library(dashTable)
library(tidyverse)
library(plotly)
library(scales)
library(rlang)

app <- Dash$new(external_stylesheets = "https://codepen.io/chriddyp/pen/bWLwgP.css")

############################################
##### Making the interactive bar plot ######
############################################

### Read in data
wine_data <- read_csv('../data/cleaned_data.csv')
wine_data <- wine_data %>%
  drop_na() %>%
  select(-X1)

#### Load necessary function

source("barplot.R")

### Selection components ###

# Slider bar for number of observations
#obsSlider <- dccSlider(
#  id = "num_obs",
#  min = 5,
#  max = 50,
#  step = 5,
#  value = 15
#)

descButton <- dccRadioItems(
  id = "desc_radiobutton",
  options = list(
    list("label" = "Highest to Lowest", "value" = TRUE),
    list("label" = "Lowest to Highest", "value" = FALSE)
  ),
  value = TRUE
)

# X Axis dropdown
xaxisKey <- tibble(label = c("Winery", "Region", "Variety"),
                   value = c("winery", "region_1", "variety"))

xaxisDropdown <- dccDropdown(
  id = "x_axis",
  options = map(
    1:nrow(xaxisKey), function(i){
      list(label=xaxisKey$label[i], value=xaxisKey$value[i])
    }),
  value = "winery"
)

yaxisKey <- tibble(label = c("Rating", "Price ($)", "Value"),
                   value = c("points", "price", "value_scaled"))

yaxisDropdown <- dccDropdown(
  id = "y_axis",
  options = map(
    1:nrow(yaxisKey), function(i){
      list(label=yaxisKey$label[i], value=yaxisKey$value[i])
    }),
  value = "points"
)

### Chart components ###

# Define graph as a dash component
bar_plot <- dccGraph(
  id = "bar_chart",
  figure = bar_plot1()
)

### App Layout ###

app$layout(
  htmlDiv(
    list(
      htmlH1('Bar Chart Test2'),
      descButton,
      htmlLabel('Select X axis'),
      xaxisDropdown,
      htmlLabel('Select Y axis'),
      yaxisDropdown,
      bar_plot,
    )
  )
)

### Adding callbacks

app$callback(
    output=list(id='bar_chart', property='figure'),
    params=list(input(id='x_axis', property='value'),
                input(id='y_axis', property='value'),
                input(id='desc_radiobutton', property='value')),
    function(x_value, y_value, desc_value) {
        bar_plot1(x_value, y_value, desc = desc_value)
    }
)


app$run_server(host = "0.0.0.0", port = Sys.getenv('PORT', 8050))
