library(dash)
library(dashCoreComponents)
library(dashHtmlComponents)
library(dashTable)
library(tidyverse)
library(plotly)
source('src/choropleth_maps.r')

# Read in the Wine Data
DATA <- read_csv("data/cleaned_data.csv")
DATA <- subset(DATA, select = -c(X1))

# Wrangle the County and State data to speed up map rendering
STATE_DATA <- wrangle_states(DATA)
COUNTY_DATA <- wrangle_counties(DATA)

APP <- Dash$new(external_stylesheets = "https://codepen.io/chriddyp/pen/bWLwgP.css")

statesDropdown <- dccDropdown(
  id = "state_choropleth",
  options = lapply(unique(DATA$state), function(x){
	  list(label=x, value=x)
  }),
  value = "California" # Default Value
)

states_graph <- dccGraph(
  id = 'states_graph',
  figure = plot_states(DATA, STATE_DATA)
)

state_graph <- dccGraph(
	id = 'state_graph',
	figure = plot_state(DATA, 'california', COUNTY_DATA)
)

APP$layout(
  htmlDiv(
    list(
      htmlH1('States'),
      htmlLabel('Select State:'),
      statesDropdown,
	  state_graph,
      htmlIframe(height=20, width=10, style=list(borderWidth = 0)), #space
      states_graph
    #   dccMarkdown("[Data Source](https://cran.r-project.org/web/packages/gapminder/README.html)")
    )
  )
)

# Adding callbacks for interactivity
APP$callback(
  # update figure of states_graph
  output=list(id = 'state_graph', property='figure'),
  params=list(input(id = 'state_choropleth', property='value')),
  # this translates your list of params into function arguments
  function(state_value) {
    plot_state(DATA, state_value, COUNTY_DATA)
  })

APP$run_server(port=8000, host='127.0.0.1')

### App created by Kate Sedivy-Haley as part of the DSCI 532 Teaching Team
