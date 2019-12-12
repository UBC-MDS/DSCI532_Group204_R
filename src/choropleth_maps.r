library("ggplot2")
library("sf")
library("tidyverse")
library("maps")
library("rnaturalearth")
library("rnaturalearthdata")
library("tools")
library("RColorBrewer")
library("plotly")

# # Read in the Wine Data
# data <- read_csv("data/cleaned_data.csv")
# data <- subset(data, select = -c(X1))

print("PRINTING IN CHOROPLETH")

wrangle_states <- function(data) {
	# Get the states mapping data
	states <- st_as_sf(map("state", plot = FALSE, fill = TRUE))
	
	# Capitalize the state names
	states$ID <- toTitleCase(states$ID)

	# Add area to states
	states$area <- as.numeric(st_area(states))

	# Join the Geometry and area data to Wine Data
	states_data <- rename(data, ID = state)
	states_data <- left_join(states_data, states, by = c("ID" = "ID"))
	
	states_data <- states_data %>%
	    group_by(ID) %>%
	    drop_na(price) %>%
	    summarise(mean_price = mean(price),
	              mean_rating = mean(points),
	              mean_value = mean(value),
	              area = mean(area),
	              num_reviews = n()) %>%
	    drop_na(area)

	states_data <- left_join(states, states_data, by = c("ID" = "ID", "area" = "area"))
	states_data <- states_data[, c(7, 1, 2, 3, 4, 5, 6)]
}

wrangle_counties <- function(data) {
	# Get the mapping data
	counties <- st_as_sf(map("county", plot=FALSE, fill=TRUE))

	county_data <- data
	county_data$state <- lapply(county_data$state, function(x) str_to_lower(x))
	county_data$county <- lapply(county_data$county, function(x) str_to_lower(x))
	county_data <- unite(county_data, ID, c('state', 'county'), sep=',', remove = FALSE)
	county_data <- county_data %>%
	    mutate(ID = gsub(' county', "", ID))

	county_data <- county_data %>%
	    group_by(ID) %>%
	    drop_na(price) %>%
	    summarise(mean_price = mean(price),
	              mean_rating = mean(points),
	              mean_value = mean(value),
	              num_reviews = n()) %>%
	    drop_na(num_reviews)
	county_data <- left_join(counties, county_data, by = c("ID" = "ID"))
	county_data <- county_data[, c(6, 1, 2, 3, 4, 5)]
}

plot_states <- function(data) {
	states_data <- wrangle_states(data)
	wine_colors <- c('#C7DBEA', '#CCCCFF', '#C1BDF4',
                     '#B6AEE9', '#948EC0', '#8475B2',
                     '#735BA4', '#624296', '#512888')

	states <- ggplot(data = states_data, aes(label = num_reviews)) +
	    geom_sf(data = states_data,
	            aes(fill = num_reviews)
	    ) +
	    scale_fill_gradientn(
	        colors = wine_colors,
	        space = "Lab",
	        trans="log10"
	    ) +
	    theme_void() +
	    labs(title = "Number of Wine Reviews by State",
	         fill = 'Num Reviews')

	ggplotly(states, width = 750, hoverinfo = "Num Reviews") %>%
	    style(hoveron = "fill")
}

plot_state <- function(data, state_value) {
	state_value <- tolower(state_value)
	county_data <- wrangle_counties(data)
	print(state_value)
	california <- county_data %>%
	    filter(grepl(state_value, ID))

	wine_colors <- c('#C7DBEA', '#CCCCFF', '#C1BDF4',
	                 '#B6AEE9', '#948EC0', '#8475B2',
	                 '#735BA4', '#624296', '#512888')

	state <- ggplot(data = california, aes(label = num_reviews)) +
	    geom_sf(data = california,
	            aes(fill = num_reviews)
	    ) +
	    scale_fill_gradientn(
	        colors = wine_colors,
	        space = "Lab",
	        trans="log10"
	    ) +
	    theme_void() +
	    labs(title = "Number of Wine Reviews by State",
	         fill = 'Num Reviews')
	ggplotly(state, width = 450, hoverinfo = "Num Reviews") %>%
	    style(hoveron = "fill")
}