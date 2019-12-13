library(ggplot2)
# library(tidyverse)
library(rlang)
library(plotly)

# Taken from Hadley Wickam Advanced R
cement <- function(...) {
  args <- ensyms(...)
  paste(purrr::map(args, as_string), collapse = " ")
}

# Function to make the bar plot
bar_plot1 <- function(wine_data, x_name="winery", y_name="points", desc=TRUE) {
  # Unquoting variables to use with dplyr functions
  x_name <- sym(x_name)
  y_name <- sym(y_name)
  print(identity(n))
  
  # Specifying axes titles here
  xaxisKey_bp <- tibble(label = c("Winery", "Region", "Variety"),
                     value = c("winery", "region_1", "variety"))
  x_title <- xaxisKey_bp$label[xaxisKey_bp$value == cement(!!x_name)]
  
  yaxisKey_bp <- tibble(label = c("Rating", "Price ($)", "Value"),
                     value = c("points", "price", "value_scaled"))
  y_title <- yaxisKey_bp$label[yaxisKey_bp$value == cement(!!y_name)]
  
  # If the user specifies Highest to Lowest, use this plot
  if (desc==TRUE) {
    # Wrangling and sorting
    new_data <- wine_data %>%
      group_by(!!x_name) %>%
      summarize(rating = mean(!!y_name)) %>%
      arrange(desc(rating)) %>%
      head(20) %>%
      mutate(highlight_flag = ifelse(rating == max(rating), T, F))
    
    # Plotting wrangled data
    new_plot <- ggplot(new_data, aes(x=reorder(!!x_name, -rating),
                                     rating, fill=highlight_flag)) +
      geom_bar(stat='identity') +
      scale_fill_manual(name = x_name, values=c('lightgrey',"#512888")) +
      scale_y_continuous(limits = c(min(new_data$rating),
                                    max(new_data$rating)),
                         oob=rescale_none) +
      xlab(x_title) +
      ylab(y_title) +
      ggtitle(paste0(y_title, ' by ', x_title)) +
      theme_bw() +
      theme(axis.text.x = element_text(angle=60, hjust=1),
            legend.position = 'none',
            panel.grid.major = element_blank())
    
    ggplotly(new_plot, tooltip="")
    
  } else {
    new_data <- wine_data %>%
      group_by(!!x_name) %>%
      summarize(rating = mean(!!y_name)) %>%
      arrange(rating) %>%
      tail(20) %>%
      mutate(highlight_flag = ifelse(rating == min(rating), T, F)) 
    
    new_plot <- ggplot(new_data, aes(x=reorder(!!x_name, rating), rating,
                                     fill=highlight_flag)) +
      geom_bar(stat='identity') +
      scale_fill_manual(name = x_name, values=c('lightgrey',"#512888")) +
      scale_y_continuous(limits = c(min(new_data$rating),
                                    max(new_data$rating)),
                         oob=rescale_none) +
      xlab(x_title) +
      ylab(y_title) +
      ggtitle(paste0(y_title, ' by ', x_title)) +
      theme_bw() +
      theme(axis.text.x = element_text(angle=60, hjust=1),
            legend.position = 'none',
            panel.grid.major = element_blank())
    
    ggplotly(new_plot, tooltip="")
  }
}