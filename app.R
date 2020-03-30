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
             marginTop=40)
)

# Price Slider

price.mrks <- as.character(round(quantile(df$price, probs=seq(0, 100, 10)/100)))
price.mrks <- setNames(as.list(price.mrks), nm=1:11)
price_slider <- htmlDiv(
  list(htmlLabel('Filter Listings by Price'),
       dccRangeSlider(id='price-slider',
                      min=1,
                      max=11,
                      marks=price.mrks,
                      value=list(1, 11))
       ),
  style=list('width'='80%',
             'padding-left'='10%',
             'padding-right'='20%',
             marginTop=0)
)

# Minimum Night Stay Slider

stay.mrks <- as.character(levels(df$min_stay))
stay.mrks <- setNames(as.list(stay.mrks), nm=seq_along(levels(df$min_stay)))
stay_slider <- htmlDiv(
  list(htmlLabel('Filter Listings by Minimum Night Stay'),
       dccSlider(id='stay-slider',
                      min=1,
                      max=length(stay.mrks),
                      marks=stay.mrks,
                      value=length(stay.mrks))
  ),
  style=list('width'='80%',
             'padding-left'='10%',
             'padding-right'='20%',
             marginTop=0)
)

# Distance Percentile Slider

dist.mrks <- as.character(quantile(df$distance, probs=seq(0, 100, 25)/100))
dist.mrks <- setNames(as.list(paste0(seq(0, 100, 25), '%')), nm=1:5)
dist_slider <- htmlDiv(
  list(htmlLabel('Filter Listings by Distance from City Center (Percentile)'),
       dccSlider(id='dist-slider',
                 min=1,
                 max=5,
                 marks=dist.mrks,
                 value=length(dist.mrks))
  ),
  style=list('width'='80%',
             'padding-left'='10%',
             'padding-right'='20%',
             marginTop=0)
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
  list(htmlDiv(list(htmlLabel('Apply Transform to Independent Variable'),
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
  htmlDiv(
    list(
      #LHS of dashboard with group dropdown and density plot
      htmlDiv(list(htmlLabel("Data Exploration"),
                   group_density, 
                   dens.graph),
              style=list('width'='50%')), #end of LHS of Dashboard
      htmlDiv(list(htmlLabel("Data Analysis"),
                   price_slider, 
                   stay_slider,
                   dist_slider,
                   htmlDiv(list(scatterplot_xaxis,
                                scatterplot_trans),
                           style=list('display'='flex'))),
              style=list('width'='50%'))
      ),
    style=list('display'='flex')
    )
)

## App Callbacks ####

app$callback(
  #update density plot whose id is dens-graph
  output=list(id = 'dens-graph', property='figure'),
  #based on the x-axis dropdown for grouping
  params=list(input(id = 'group', property='value')),
  #this translates your list of params into function arguments
  function(xaxis_value) {
    make_violin(xaxis_value)
  })

## Run App ####
app$run_server(debug=TRUE)