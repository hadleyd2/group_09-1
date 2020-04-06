# author: Daniel Hadley
# date: 2020-04-04
# Dash app for STAT547M Final Project

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
               col_types=cols()) %>% 
  mutate(min_stay = factor(min_stay))

## Load Functions ####
source('dash_functions.R')

## Load Components ####
source('dash_components.R')

## Create Dash Instance ####

app <- Dash$new()

## Create Layout Elements ####

# Header
div_header <- htmlDiv(
  list(heading_title,
       heading_name),
  style = list(backgroundColor = '#337DFF',
               textAlign='center',
               color='white',
               margin=5,
               marginTop=0)
)

# Grouping Dropdown
group_density <- htmlDiv(
  list(htmlLabel('Select Grouping'),
       group.Dropdown),
  style=list('width'='40%',
             margin=40)
)

## X-axis Dropdown for Scatterplot
scatterplot_xaxis <- htmlDiv(
  list(htmlLabel('Select Independent Variable'),
       xaxis.Dropdown),
  style=list('width'='40%',
             margin=10)
)

## Transformation Radio Button for Independent Variable
scatterplot_trans <- htmlDiv(
  list(htmlDiv(list(htmlLabel(id='trans-label'),
                    x.button),
               style=list(margin=5)),
       htmlDiv(list(htmlLabel('Apply Transform to Price'),
                    y.button),
               style=list(margin=5))),
  style=list('width'='50%')
)

## Specify App layout ####

app$layout(
  # Add Title
  div_header,
  # This Div is for the entire dashboard
  main_tabs
)

## App Callbacks ####

#Callback for Tabs and their Content
app$callback(
  output = list(id='tabs-content', property='children'),
  
  params = list(input(id='tabs', 'value')),
  
  function(tab) {
    render_content(tab)
  }
)

# Grouped Density Plot
app$callback(
  #update density plot whose id is dens-graph
  output=list(id = 'dens-graph', property='figure'),
  #based on the x-axis dropdown for grouping
  params=list(input(id = 'group', property='value')),
  #this translates your list of params into function arguments
  function(xaxis_value) {
    make_violin(xaxis_value)
  })

# Scatterplot with Trendline
app$callback(
  #update scsatterplot
  output=list(id = 'scatter', property='figure'),
  #based on the x-axis dropdown for selecting independent variable
  params=list(input(id = 'x-axis', property='value'),
              input(id = 'price-slider', property='value'),
              input(id = 'stay-slider', property='value'),
              input(id = 'dist-slider', property='value'),
              input(id = 'xaxis-transform', property='value'),
              input(id = 'yaxis-transform', property='value')),
  #this translates your list of params into function arguments
  function(xaxis_value, price_filter, stay_filter, dist_filter, x_trans, y_trans) {
    make_scatter(xaxis=xaxis_value, 
                 pricerange=unlist(price_filter), 
                 stayfilter=unlist(stay_filter),
                 distancefilter=unlist(dist_filter),
                 x.trans=x_trans,
                 y.trans=y_trans)
  })

app$callback(
  #update scsatterplot
  output=list(id = 'trans-label', property='children'),
  #based on the x-axis dropdown for selecting independent variable
  params=list(input(id = 'x-axis', property='value')),
  #this translates your list of params into function arguments
  function(xaxis_value) {
    x_label <- xaxisKey$label[xaxisKey$value==xaxis_value]
    return((paste0("Apply Transform to ", x_label)))
  })

## Run App ####
app$run_server(debug=TRUE)