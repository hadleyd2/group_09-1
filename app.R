# author: Daniel Hadley
# date: 2020-03-21

"This script is the main file that creates a Dash app.

Usage: app.R
"

## Libraries ####

suppressPackageStartupMessages(library(dash))
suppressPackageStartupMessages(library(dashCoreComponents))
suppressPackageStartupMessages(library(dashHtmlComponents))
suppressPackageStartupMessages(library(dashTable))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(plotly))

## Load Data ####
df <- read_csv(file=here::here("data", "clean_listings.csv"),
               col_types=cols())

## Plot Functions ####
make_violin <- function(xaxis="all") {
  
  #get label matching grouping factor
  x_label <- xaxisKey$label[xaxisKey$value==xaxis]
  
  #create ggplot when no grouping is selected
  if (x_label == "All") {
    p <- df %>% 
      ggplot(aes(x=price)) + 
      geom_density() +
      theme_bw(14) +
      theme(plot.title = element_text(size = 14)) +
      ggtitle(label="Price Density for All Listings") +
      scale_x_continuous("Listing Price per Night", labels=scales::dollar_format(suffix="\u20AC", prefix='')) +
      ylab("Density")
  } else {
    p <- ggplot(df, aes(x=!!sym(xaxis), y=price)) +
      geom_violin(stat = "ydensity") +
      scale_y_log10() +  # change to log10 scale since density of price is skewed
      ylab(paste("Price (", "\u20AC", ")", sep='')) +
      xlab(x_label) +
      ggtitle("Distribution of Listing Price") +
      theme_bw(14) +
      theme(plot.title = element_text(size = 14), 
            axis.text.x = element_text(angle = 60, hjust = 1))
  }
  
  ggplotly(p)
}

## Assign Components to Variables ####

# Title of Dashboard
heading_title <- htmlH1('Airbnb.com Listing Prices in Barcelona, Spain')

# x-axis options for Violin Plot
xaxisKey <- tibble(label = c("All", "District", "Room Type"),
                   value = c("all", "district", "room_type"))

# x-axis dropdown for Violin Plot
xaxis.Dropdown <- dccDropdown(
  id = "x-axis",
  options = map(
    1:nrow(xaxisKey), function(i){
      list(label=xaxisKey$label[i], value=xaxisKey$value[i])
    }),
  value = "all"
)

# Density Plot
dens.graph <- dccGraph(
  id = 'dens-graph',
  figure=make_violin() # gets initial data using argument defaults
)

## Create Dash Instance ####

app <- Dash$new()

## Specify App layout ####

app$layout(
  htmlDiv(
    list(
      # Add Title
      heading_title,
      
      # Add Label for Grouping Dropdown for Density plot
      htmlLabel('Select Grouping'),
      xaxis.Dropdown,
      htmlIframe(height=50, width=0, style=list(borderWidth = 0)),
      dens.graph
    )
  )
)

## App Callbacks ####

app$callback(
  #update density plot whose id is dens-graph
  output=list(id = 'dens-graph', property='figure'),
  #based on the x-axis dropdown for grouping
  params=list(input(id = 'x-axis', property='value')),
  #this translates your list of params into function arguments
  function(xaxis_value) {
    make_violin(xaxis_value)
  })

## Run App ####
app$run_server(debug=TRUE)