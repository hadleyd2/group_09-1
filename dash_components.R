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
There are two options to aid you in this quest!
Use the **Data Exploration** tab to get an idea of the price density of all listings or the price density of listings by group.
Use the **Data Analysis** tab to help pick the variables in a possible linear regression model by viewing how they are related to price under various transformations.

## Data Exploration

  - The default value shows the price density for all listings in the dataset.
  
  - Select a grouping variable from the dropdown to view a violin plot, which shoes the price density for each group of the chosen grouping variable side-by-side.

## Data Analysis

  - Filters are provided to help narrow down the listings to those of interest based on price, minimum night stay, and distance from city center.
  These filters are range filters, so you can select values for any of the three criteria 
  and include all listings whose characteristics fall within the upper and lower limits of those criteria. 
  The default limits listing to aid in the loading speed of this tab.
  
    - The dataset only includes listings priced at under 500 Euro's per night. Select an applicable range of prices on a continuous scale. 
      Note that you cannot select a value lower than the minimum listing price.
      
    - Listings may have a minimum number of nights that a guest must book. Use this filter to select a range of minimum night stays of interest.
      
    - The city center is determined by Google maps when typing in Barcelona, Spain. 
      The distance from this point is calculated as the Euclidean distance using longitude and latitude coordinates.
      Since the raw value of these distances can be hard to interpret, the options are the listings within a range of percentile values for distance.
  
  - The scatterplot shows the price and independent variable coordinates as chosen from the dropdown. 
  You can then apply transformations to price, the independent variable, or both.
  A trendline is shown to aid in your visual assessment of the linear fit.
  
    - If the independent variable is chosen as Minimum Night Stay, then this is treated as a grouping variable in the regression, 
      where the lowest minimum night stay is considered the reference group. 
      The resulting scatterplot uses jittered points to avoid overplotting.
    
    - If the independent variable is Minimum Night Stay and the limits of the minimum night stay filter are the same, the trendline is the mean price.
    
    - When the independent variable is chosen as any other variable, it is treated as a continuous, numeric variable with the usual interpretations
    of the ratio level of measurement.
                            
")

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
                               value=list(0, 50))

# Minimum Night Stay Slider

stay.mrks <- as.character(levels(df$min_stay))
stay.mrks <- setNames(as.list(stay.mrks), nm=seq_along(levels(df$min_stay)))
stay_slider <- dccRangeSlider(id='stay-slider',
                         min=1,
                         max=5,
                         marks=stay.mrks,
                         value=list(1, 2)) ## be sure to change back to 1, 5

# Distance Percentile Slider

dist.mrks <- as.character(quantile(df$distance, probs=seq(0, 100, 25)/100))
dist.mrks <- setNames(as.list(paste0(seq(0, 100, 25), '%')), nm=1:5)
dist_slider <- dccRangeSlider(id='dist-slider',
                         min=1,
                         max=5,
                         marks=dist.mrks,
                         value=list(1, 2))

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
  value = "latitude"
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





