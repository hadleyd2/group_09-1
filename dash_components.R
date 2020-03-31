## Create dash components

## Header Components (including text) ####

# Title
heading_title <- htmlH1('Airbnb.com Listing Prices in Barcelona, Spain') 

#Sub-title for Author
heading_name <- htmlH3('Daniel Hadley')

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
                               value=list(0, 500))

# Minimum Night Stay Slider

stay.mrks <- as.character(levels(df$min_stay))
stay.mrks <- setNames(as.list(stay.mrks), nm=seq_along(levels(df$min_stay)))
stay_slider <- dccRangeSlider(id='stay-slider',
                         min=1,
                         max=5,
                         marks=stay.mrks,
                         value=list(1, 5))

# Distance Percentile Slider

dist.mrks <- as.character(quantile(df$distance, probs=seq(0, 100, 25)/100))
dist.mrks <- setNames(as.list(paste0(seq(0, 100, 25), '%')), nm=1:5)
dist_slider <- dccRangeSlider(id='dist-slider',
                         min=1,
                         max=5,
                         marks=dist.mrks,
                         value=list(1, 5))

# X-axis options for Scatter Plot
xaxisKey <- tibble(label = c("Latitude", "Longitude", "Reviews", "Reviews Per Month", "Host Listings", "Distance"),
                   value = c("latitude", "longitude", "reviews", "reviews_per_month", "host_listings", "distance"))

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