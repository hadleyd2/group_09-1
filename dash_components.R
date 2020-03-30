## Create dash components

# Title ####
heading_title <- htmlH1('Airbnb.com Listing Prices in Barcelona, Spain') 

#Sub-title for Author ####
heading_name <- htmlH3('Daniel Hadley')

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
  value = "Reviews"
)

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