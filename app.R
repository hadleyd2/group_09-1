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
df <- read_csv(file='https://raw.githubusercontent.com/hadleyd2/group_09-1/master/data/clean_listings.csv',
               col_types=cols()) %>% 
  mutate(min_stay = factor(min_stay))

## Load Functions ####
## Grouped Density Plot Function ####
make_violin <- function(xaxis="all") {
  
  #get label matching grouping factor
  x_label <- groupKey$label[groupKey$value==xaxis]
  
  if (xaxis == "min_stay") df$min_stay <- paste0(df$min_stay, " Night")
  
  #create ggplot when no grouping is selected
  if (x_label == "No Grouping") {
    p <- df %>% 
      ggplot(aes(x=price)) + 
      geom_density() +
      theme_bw(14) +
      theme(plot.title = element_text(size = 14)) +
      ggtitle(label="Price Density for All Listings") +
      scale_x_continuous(paste0("Listing Price (", "\u20AC", ") per Night")) +
      ylab("Density")
  } else {
    p <- ggplot(df, aes(x=!!sym(xaxis), y=price, color=!!sym(xaxis))) +
      geom_violin(stat = "ydensity") +
      scale_y_log10() +  # change to log10 scale since density of price is skewed
      ylab(paste("Price (", "\u20AC", ")", sep='')) +
      xlab(x_label) +
      ggtitle("Distribution of Listing Price") +
      theme_bw(14) +
      theme(plot.title = element_text(size = 14), 
            axis.text.x = element_blank())
  }
  
  ggplotly(p)
}

## Scatterplot with Trendline
make_scatter <- function(xaxis='reviews', 
                         pricerange=c(0,0), 
                         stayfilter=c(1, 5), 
                         distancefilter=c(1, 5),
                         x.trans='none',
                         y.trans='none') {
  
  ## Find label for X-axis variable
  x_label <- xaxisKey$label[xaxisKey$value==xaxis]
  
  ## Make filter via pricerange argument
  if (sum(pricerange) == 0) pricerange <- c(min(df$price), max(df$price))
  
  ## Load data, filter, and select variables
  df.tmp <- df %>%
    filter(price >= pricerange[1],
           price <= pricerange[2],
           as.numeric(min_stay) >= stayfilter[1],
           as.numeric(min_stay) <= stayfilter[2],
           distance >= quantile(df$distance)[distancefilter[1]],
           distance <= quantile(df$distance)[distancefilter[2]]) %>% 
    select(!!sym(xaxis), price) %>%
    mutate(xaxis = switch(x.trans,
                          none = !!sym(xaxis),
                          log = log(!!sym(xaxis)),
                          root = sqrt(!!sym(xaxis)),
                          reciprocal = 1/(!!sym(xaxis)))) %>% 
    mutate(price = switch(y.trans,
                          none = price,
                          log = log(price),
                          root = sqrt(price),
                          reciprocal = 1/(price))) 
  
  if (x_label == 'Minimum Stay') {
    if (stayfilter[1] == stayfilter[2]) {
      p <- df.tmp %>% 
        ggplot(aes(x=!!sym(xaxis), y=price)) +
        geom_jitter(alpha=0.3, width=0.25) + 
        geom_abline(intercept=mean(df.tmp$price), slope=0) +
        xlab(x_label) +
        scale_y_continuous(paste0("Price (", "\u20AC", ")")) +
        ggtitle(paste0("Scatterplot of ", x_label, " vs Price with Trendline")) +
        theme_bw(14)
    } else {
      p <- df.tmp %>% 
        mutate(xaxis = as.numeric(as.character(!!sym(xaxis)))) %>% 
        ggplot(aes(x=!!sym(xaxis), y=price)) +
        geom_jitter(alpha=0.3,width=0.1) +
        geom_smooth(method='lm') + 
        scale_x_discrete(name=x_label,
                         breaks=c(as.character(stayfilter[1]:stayfilter[2])),
                         labels=c(as.character(stayfilter[1]:stayfilter[2]))) +
        scale_y_continuous(paste0("Price (", "\u20AC", ")")) +
        ggtitle(paste0("Scatterplot of ", x_label, " vs Price with Trendline")) +
        theme_bw(14)
    }
  } else {
    p <- ggplot(df.tmp, aes(x=!!sym(xaxis), y=price)) +
      geom_point(alpha=0.3) + 
      geom_smooth(method='lm') + 
      xlab(x_label) +
      scale_y_continuous(paste0("Price (", "\u20AC", ")")) +
      ggtitle(paste0("Scatterplot of ", x_label, " vs Price with Trendline")) +
      theme_bw(14)
  }
  
  ggplotly(p)
}

## Tabs

render_content <- function(tab) {
  if (tab == 'tab-1') {
    ## Markdown Text and Image
    htmlDiv(list(instructions),
            style=list('justify-content'='center'))
  } else if (tab == 'tab-2') {
    ## Histogram with dropdown for diamond clarity and
    ## radio option for y-axis scale
    htmlDiv(list(htmlDiv(list(group_density),
                         style=list('flex-basis'='30%')), 
                 htmlDiv(list(dens.graph),
                         style=list('flex-basis'='70%'))),
    )
  } else if (tab == 'tab-3') {
    ## Two diamond cut plots controlled by slider
    # htmlDiv(list(htmlDiv(
    #                list(htmlLabel('Filter Listings by Price'),
    #                     price_slider),
    #                style=list('width'='80%',
    #                           'padding-left'='10%',
    #                           'padding-right'='20%',
    #                           margin=5)), 
    #              htmlDiv(
    #                list(htmlLabel('Filter Listings by Minimum Night Stay'),
    #                     stay_slider),
    #                style=list('width'='80%',
    #                           'padding-left'='10%',
    #                           'padding-right'='20%',
    #                           margin=5)),
    #              htmlDiv(
    #                list(htmlLabel('Filter Listings by Distance from City Center (Percentile)'),
    #                     dist_slider),
    #                style=list('width'='80%',
    #                           'padding-left'='10%',
    #                           'padding-right'='20%',
    #                           margin=5)),
    #              htmlDiv(list(scatterplot_xaxis,
    #                           scatterplot_trans),
    #                      style=list('display'='flex')),
    #              scat_graph),
    #         style=list('width'='80%'))
    htmlDiv(list(
      ## Slider Filters
      htmlDiv(list(
        htmlDiv(list(htmlLabel('Filter Listings by Price'),
                     price_slider),
                style=list(margin=5)),
        htmlDiv(list(htmlLabel('Filter Listings by Minimum Night Stay'),
                     stay_slider),
                style=list(margin=5)),
        htmlDiv(list(htmlLabel('Filter Listings by Distance from City Center (Percentile)'),
                     dist_slider),
                style=list(margin=5)),
        htmlDiv(list(htmlLabel(id='trans-label'),
                     x.button),
                style=list(margin=5)),
        htmlDiv(list(htmlLabel('Apply Transform to Price'),
                     y.button),
                style=list(margin=5))),
        style=list('flex-basis'='33%')
      ),
      htmlDiv(list(htmlLabel('Select Independent Variable'),
                   xaxis.Dropdown,
                   scat_graph),
              style=list(margin=5,
                         'flex-basis'='65%'))
    ),
    style=list('display'='flex')
    )
  }
}

## Load Components ####
## Create dash components

## Header Components (including text) ####

# Title
heading_title <- htmlH1('Airbnb.com Listing Prices in Barcelona, Spain') 

#Sub-title for Author
heading_name <- htmlH3('STAT547M Project by: Daniel Hadley')

# Instructions
instructions <- dccMarkdown("

Welcome to my dashboard where we explore Airbnb listings for Barcelona! 
In particular, this dashboard should help you find variables linearly related to listing prices.

Under **Data Exploration**, you can view the price density for all listings or select a grouping variable from the dropdown and view the price density by group.

Under **Data Analysis**, you can filter listings by price, minimum night stay, or the distance from city center. 
You can select a range of values for all three filters, and the filters work together to filter listings meeting all criteria.
Additionally, a scatterplot is presented with a trendline to allow you to view the linear relationship between price 
and the variable you select from the *Select Independent Variable* dropdown.
Finally, you can apply transformations to either price or the independent variable to see if this improves
the linear relationship.")

## Grouped Density Plot Components (and its dependencies) ####

# Group options for Violin Plot
groupKey <- tibble(label = c("No Grouping", "District", "Room Type", "Minimum Stay"),
                   value = c("all", "district", "room_type", "min_stay"))

# Group dropdown for Violin Plot
group.Dropdown <- dccDropdown(
  id = "x-axis",
  options = map(
    1:nrow(groupKey), function(i){
      list(label=groupKey$label[i], value=groupKey$value[i])
    }),
  value = "all"
)

# Density Plot
dens.graph <- dccGraph(
  id = 'dens-graph',
  figure=make_violin() # gets initial data using argument defaults
)

# Group options for Violin Plot
groupKey <- tibble(label = c("No Grouping", "District", "Room Type", "Minimum Stay"),
                   value = c("all", "district", "room_type", "min_stay"))

# Group dropdown for Violin Plot
group.Dropdown <- dccDropdown(
  id = "group",
  options = map(
    1:nrow(groupKey), function(i){
      list(label=groupKey$label[i], value=groupKey$value[i])
    }),
  value = "all"
)

## Scatterplot with Trendline (and dependencies) ####

# Price Slider as Filter for Scatterplot
price.mrks <- as.character(seq(0, 500, by=50))
price.mrks <- setNames(as.list(price.mrks), nm=price.mrks)
price_slider <- dccRangeSlider(id='price-slider',
                               min=0,
                               max=500,
                               marks=price.mrks,
                               value=list(0, 100))

# Minimum Night Stay Slider

stay.mrks <- as.character(levels(df$min_stay))
stay.mrks <- setNames(as.list(stay.mrks), nm=seq_along(levels(df$min_stay)))
stay_slider <- dccRangeSlider(id='stay-slider',
                              min=1,
                              max=5,
                              marks=stay.mrks,
                              value=list(5, 5)) ## be sure to change back to 1, 5

# Distance Percentile Slider

dist.mrks <- as.character(quantile(df$distance, probs=seq(0, 100, 25)/100))
dist.mrks <- setNames(as.list(paste0(seq(0, 100, 25), '%')), nm=1:5)
dist_slider <- dccRangeSlider(id='dist-slider',
                              min=1,
                              max=5,
                              marks=dist.mrks,
                              value=list(1, 5))

# X-axis options for Scatter Plot
xaxisKey <- tibble(label = c("Latitude", "Longitude", "Reviews", "Reviews Per Month", "Minimum Stay", "Host Listings", "Distance"),
                   value = c("latitude", "longitude", "reviews", "reviews_per_month", "min_stay", "host_listings", "distance"))

# X-axis dropdown for Scatterplot
xaxis.Dropdown <- dccDropdown(
  id = "x-axis",
  options = map(
    1:nrow(xaxisKey), function(i){
      list(label=xaxisKey$label[i], value=xaxisKey$value[i])
    }),
  value = "reviews"
)


# Scatterplot with Trendline
scat_graph <- dccGraph(id='scatter',
                       figure=make_scatter())

## Radio Buttons ####

# Independent Variable Transformation
x.button <- dccRadioItems(
  id = 'xaxis-transform', #assign id to component
  options = list(list(label = 'None', value = 'none'),
                 list(label = 'Log', value = 'log'),
                 list(label = 'Square Root', value = 'root'),
                 list(label = 'Reciprocal', value = 'reciprocal')),
  value = 'none'
)

# Dependent Variable Transformation
y.button <- dccRadioItems(
  id = 'yaxis-transform', #assign id to component
  options = list(list(label = 'None', value = 'none'),
                 list(label = 'Log', value = 'log'),
                 list(label = 'Square Root', value = 'root'),
                 list(label = 'Reciprocal', value = 'reciprocal')),
  value = 'none'
)

# Tabs
main_tabs <- htmlDiv(
  list(dccTabs(id="tabs", value='tab-1',
               children=list(
                 dccTab(label="Welcome", value='tab-1'),
                 dccTab(label="Data Exploration", value='tab-2'),
                 dccTab(label="Data Analysis", value='tab-3')) #end of children
  ), #end of dccTabs()
  htmlDiv(id='tabs-content')
  ) #end of list()
) #end of htmlDiv()

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
  style=list(margin=10)
)

## Transformation Radio Button for Independent Variable
# scatterplot_trans <- htmlDiv(list(htmlLabel(id='trans-label'),
#                     x.button),
#                style=list(margin=5))
#        htmlDiv(list(htmlLabel('Apply Transform to Price'),
#                     y.button),
#                style=list(margin=5))

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