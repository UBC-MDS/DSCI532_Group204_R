library(dash)
library(dashCoreComponents)
library(dashHtmlComponents)
library(dashTable)
library(plotly)
library(scales)
library(rlang)
library(readr)
library(stringr)
library(scales)
library(rlang)
library(dplyr)
library(purrr)

source('src/choropleth_maps.r')
source('src/barplot.r')
source('src/heatmap.r')


app <- Dash$new(external_stylesheets = "https://codepen.io/chriddyp/pen/bWLwgP.css")

#### LOAD DATA

# Read in data for choropleth
DATA <- read_csv("data/cleaned_data.csv") %>%
  select(-X1)

# Wrangle the County and State data to speed up map rendering
STATE_DATA <- wrangle_states(DATA)
COUNTY_DATA <- wrangle_counties(DATA)

# Read in pre-filetered data for heatmap
heatmap_data <- read_csv('data/heatmap_filtered_data.csv')

### INTERACTIVE ELEMENTS

# Choropleth state selection 
statesDropdown <- dccDropdown(
 id = "state_choropleth",
 options = lapply(unique(DATA$state), function(x){
   list(label=x, value=x)
 }),
 value = "California" # Default Value
)

# Bar plot order radio buttons
descButton <- dccRadioItems(
  id = "desc_radiobutton",
  options = list(
    list("label" = "Highest to Lowest", "value" = TRUE),
    list("label" = "Lowest to Highest", "value" = FALSE)
  ),
  value = TRUE
)

# Bar plot axis selections
xaxisKey_bp <- tibble(label = c("Winery", "Region", "Variety"),
                   value = c("winery", "region_1", "variety"))

xaxisDropdown_bp <- dccDropdown(
  id = "x_axis_bp",
  options = lapply(
    1:nrow(xaxisKey_bp), function(i){
      list(label=xaxisKey_bp$label[i], value=xaxisKey_bp$value[i])
    }),
  value = "winery"
)

yaxisKey_bp <- tibble(label = c("Rating", "Price ($)", "Value"),
                   value = c("points", "price", "value_scaled"))

yaxisDropdown_bp <- dccDropdown(
  id = "y_axis_bp",
  options = lapply(
    1:nrow(yaxisKey_bp), function(i){
      list(label=yaxisKey_bp$label[i], value=yaxisKey_bp$value[i])
    }),
  value = "points"
)

# Heatmap axis selection
xaxisKey_hm <- tibble(label = c("Price", "Rating"),
                   value = c("price", "points"))

xaxisDropdown_hm <- dccDropdown(
  id = 'x-axis_hm',
  options = lapply(
    1:nrow(xaxisKey_hm), 
    function(i){list(label=xaxisKey_hm$label[i], value=xaxisKey_hm$value[i])}
  ),
  value = "price"
)



# CREATE PLOTS

# Call functions to create each plot
states_graph <- dccGraph(
 id = 'states_graph',
 figure = plot_states(DATA, STATE_DATA)
)

state_graph <- dccGraph(
 id = 'state_graph',
 figure = plot_state(DATA, 'california', COUNTY_DATA)
)

bar_plot <- dccGraph(
  id = "bar_chart",
  figure = bar_plot1(DATA) 
)

heatmap_graph <- dccGraph(
 id = 'heatmap_graph',
 figure = plot_heatmap()
)


### DEFINE APP LAYOUT

app$layout(
  htmlDiv(
    list(
      htmlH1('V IS FOR VINO'), # Title and app description
      htmlH3('Explore the best wines the United States has to offer using our interactive dashboard'),
      dccMarkdown("This app allows you visualize details of over 50,000 wine reviews from across the \
                 United States, using data scraped from Wine Enthusiast on November 22nd, 2017. \
                 Given the data source, the wines tend to be of relatively high quality, with \
                 each receiving a rating score between 80 and 100. We’ve used these ratings to \
                 assign a ‘value’ score to each wine, which is essentially a ratio of its rating \
                 to price. Each review also contains details such as grape variety, winery, region, \
                 county, and state."),
      dccMarkdown("---"),
      
      htmlH2('WINE REVIEWS BY GEOGRAPHIC LOCATION'), # Geographic title and description
      dccMarkdown("See how wine is distributed across the U.S. Hover over a particular state or \
                 county to see some summary information for things like average price, points, \
                 or value rating. Use the dropdown menu to take a closer look at a particular \
                 state, where you can see a breakdown by county. Hover over a county to get more \
                 summary information. In no time at all you'll be an expert on where you can find \
                 the best wine's at the best prices in America."),
      
      htmlH3('TOTAL NUMBER OF REVIEWS'), # choropleth elements section
      htmlH4('States'),
      htmlLabel('Select State:'),
      statesDropdown,
      state_graph,
      states_graph,
      dccMarkdown("---"),
      
      htmlH2('WINE FEATURE COMPARISONS'), # header and description for barchart and heatmap sections
      dccMarkdown("These interactive graphs allow you to explore the price, rating and value for \
                 different wineries, grape varieties, and regions. The bar chart shows dynamically \
                 ranked results for calculated averages, while the heat map shows the distribution \
                 of value (scaled rating / dollar) for popular grape varieties."),
      
      htmlH3('WINE RANKINGS'), # barchart elements section
      descButton,
      htmlLabel('Select X axis'),
      xaxisDropdown_bp,
      htmlLabel('Select Y axis'),
      yaxisDropdown_bp,
      bar_plot,
      dccMarkdown("---"),
      
      htmlH3('PRICE AND RATING ANALYSIS'), # heatmap elements section
      htmlLabel('Select X axis'),
      xaxisDropdown_hm,
      heatmap_graph
    )
  )
)



### CALLBACKS

#Choropleth callback
app$callback(
  #update figure of states_graph
 output=list(id = 'state_graph', property='figure'),
 params=list(input(id = 'state_choropleth', property='value')),
  #this translates your list of params into function arguments
 function(state_value) {
   plot_state(DATA, state_value, COUNTY_DATA)
 })

# Barplot callback
app$callback(
  output=list(id='bar_chart', property='figure'),
  params=list(input(id='x_axis_bp', property='value'),
              input(id='y_axis_bp', property='value'),
              input(id='desc_radiobutton', property='value')),
  function(x_value, y_value, desc_value) {
    bar_plot1(DATA, x_value, y_value, desc = desc_value)
  }
)

# Heatmap callback
app$callback(
  #update figure of heatmap_graph
 output=list(id = 'heatmap_graph', property = 'figure'),
  #based on value of x-axis component
 params=list(input(id = 'x-axis_hm', property = 'value')),
 function(xaxis_value) {
   make_heatmap(xaxis_value)
 })

#app$run_server(port=8000, host='127.0.0.1')
app$run_server(host = "0.0.0.0", port = Sys.getenv('PORT', 8050))