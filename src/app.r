

library(dash)
library(dashCoreComponents)
library(dashHtmlComponents)
library(dashTable)
library(tidyverse)
library(plotly)

source('src/choropleth_maps.r')

# Read in the Wine Data
data <- read_csv("data/cleaned_data.csv")
data <- subset(data, select = -c(X1))

app <- Dash$new(external_stylesheets = "https://codepen.io/chriddyp/pen/bWLwgP.css")

statesDropdown <- dccDropdown(
  id = "state_choropleth",
  options = lapply(unique(data$state), function(x){
	  list(label=x, value=x)
  }),
  value = "California" # Default Value
)

states_graph <- dccGraph(
  id = 'states_graph',
  figure = plot_states(data)
)

state_graph <- dccGraph(
	id = 'state_graph',
	figure = plot_state(data, 'california')
)

app$layout(
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
app$callback(
  # update figure of states_graph
  output=list(id = 'state_graph', property='figure'),
  params=list(input(id = 'state_choropleth', property='value')),
  # this translates your list of params into function arguments
  function(state_value) {
    plot_state(data, state_value)
  })

app$run_server()

### App created by Kate Sedivy-Haley as part of the DSCI 532 Teaching Team
