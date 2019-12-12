library(ggplot2)
library(tidyverse)
library(plotly)

# Function to make the heatmap
make_heatmap <- function(xaxis="price"){
  
  # Selection component for heatmap
  xaxisKey <- tibble(label = c("Price", "Rating"),
                     value = c("price", "points"))
  
  xaxisDropdown <- dccDropdown(
    id = 'x-axis',
    options = map(
      1:nrow(xaxisKey), 
      function(i){list(label=xaxisKey$label[i], value=xaxisKey$value[i])}
    ),
    value = "price"
  )
  
  # gets the label matching the column value
  x_label <- xaxisKey$label[xaxisKey$value==xaxis]
  
  # make the plot!
  if (xaxis == 'price'){
    p <- ggplot(heatmap_data, aes(price, variety, z = value_scaled)) + 
      stat_summary_2d(fun = mean, bins = 10) +
      scale_fill_gradient(low = '#C9DBEB', high = '#740F73') +
      labs(x = 'Price ($)', 
           y = 'Grape Variety', 
           fill = "Average Value", 
           title = "Average Value Scores for Popular Grape Varieties, by Price")
  }
  
  if (xaxis == 'points'){
    p <- ggplot(heatmap_data, aes(points, variety, z = value_scaled)) + 
      stat_summary_2d(fun = mean, bins = 10) +
      scale_fill_gradient(low = '#C9DBEB', high = '#740F73') +
      labs(x = 'Rating', y = 'Grape Variety', fill = "Average Value")
  }
  
  ggplotly(p)
}