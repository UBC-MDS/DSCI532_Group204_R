library(ggplot2)
# library(tidyverse)
library(plotly)

# Function to make the heatmap
plot_heatmap <- function(xaxis="price"){
  
  # Selection components for heatmap
  xaxisKey_hm <- tibble(label = c("Price", "Rating"),
                     value = c("price", "points"))
  
  # gets the label matching the column value
  x_label <- xaxisKey_hm$label[xaxisKey_hm$value==xaxis]
  
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